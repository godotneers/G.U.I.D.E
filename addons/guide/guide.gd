extends Node

const GUIDESet = preload("guide_set.gd")
const GUIDEReset = preload("guide_reset.gd")
const GUIDEInputTracker = preload("guide_input_tracker.gd")

## This is emitted whenever input mappings change (either due to mapping
## contexts being enabled/disabled or remapping configs being re-applied or
## joystick devices being connected/disconnected).
## This is useful for updating UI prompts.
signal input_mappings_changed()

## The currently active contexts. Key is the context, value is the priority
var _active_contexts:Dictionary = {}
## The currently active action mappings.
var _active_action_mappings:Array[GUIDEActionMapping] = []

## The currently active remapping config.
var _active_remapping_config:GUIDERemappingConfig

## All currently active inputs as collected from the active input mappings
var _active_inputs:Array[GUIDEInput] = []

## A dictionary of actions sharing input. Key is the action, value
## is an array of lower-priority actions that share input with the 
## key action.
var _actions_sharing_input:Dictionary = {}

## A reference to the reset node which resets inputs that need a reset per frame
## This is an extra node because the reset should run at the end of the frame
## before new input is processed at the beginning of the frame.
var _reset_node:GUIDEReset

## The current input state. This is used to track the state of the inputs
## and serves as a basis for the GUIDEInputs.
var _input_state:GUIDEInputState


func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	_reset_node = GUIDEReset.new()
	_input_state = GUIDEInputState.new()
	add_child(_reset_node)
	# attach to the current viewport to get input events
	GUIDEInputTracker._instrument.call_deferred(get_viewport())
	
	get_tree().node_added.connect(_on_node_added)
	
	# Emit a change of input mappings whenever a joystick was connected
	# or disconnected.
	Input.joy_connection_changed.connect(func(ig, ig2): input_mappings_changed.emit())


## Called when a node is added to the tree. If the node is a window
## GUIDE will instrument it to get events when the window is focused.	
func _on_node_added(node:Node) -> void:
	if not node is Window:
		return
		
	GUIDEInputTracker._instrument(node)
	

## Injects input into GUIDE. GUIDE will call this automatically but 
## can also be used to manually inject input for GUIDE to handle 
func inject_input(event:InputEvent) -> void:
	if event is InputEventAction:
		return  # we don't react to Godot's built-in events

	# The input state is the sole consumer of input events. It will notify
	# GUIDEInputs when relevant input events happen. This way we don't need
	# to process input events multiple times and at the same time always have
	# the full picture of the input state.
	_input_state._input(event)


## Applies an input remapping config. This will override all input bindings in the 
## currently loaded mapping contexts with the bindings from the configuration.	
## Note that GUIDE will not track changes to the remapping config. If your remapping
## config changes, you will need to call this method again.
func set_remapping_config(config:GUIDERemappingConfig) -> void:
	_active_remapping_config = config
	_update_caches()
	
	
## Enables the given context with the given priority. Lower numbers have higher priority. If 
## disable_others is set to true, all other currently enabled mapping contexts will be disabled.
func enable_mapping_context(context:GUIDEMappingContext, disable_others:bool = false,  priority:int = 0):
	if not is_instance_valid(context):
		push_error("Null context given. Ignoring.")
		return
	
	if disable_others:
		_active_contexts.clear()	
	
	_active_contexts[context] = priority
	_update_caches()
	
	
## Enables multiple context simultaneously
func enable_mapping_contexts(context:Dictionary[GUIDEMappingContext, int], disable_others:bool = false):
	if disable_others:
		_active_contexts.clear()
	
	_active_contexts.merge(context, true)
	_update_caches()


## Disables the given mapping context.
func disable_mapping_context(context:GUIDEMappingContext):
	if not is_instance_valid(context):
		push_error("Null context given. Ignoring.")
		return

	_active_contexts.erase(context)
	_update_caches()


## Checks whether the given mapping context is currently enabled.
func is_mapping_context_enabled(context:GUIDEMappingContext) -> bool:
	return _active_contexts.has(context)


## Returns the currently enabled mapping contexts
func get_enabled_mapping_contexts() -> Array[GUIDEMappingContext]:
	var result:Array[GUIDEMappingContext] = []
	for key in _active_contexts.keys():
		result.append(key)
	return result


## Processes all currently active actions
func _process(delta:float) -> void:
	var blocked_actions:GUIDESet = GUIDESet.new()
	
	for action_mapping:GUIDEActionMapping in _active_action_mappings:
		
		var action:GUIDEAction = action_mapping.action
				
		# Walk over all input mappings for this action and consolidate state
		# and result value.
		var consolidated_value:Vector3 = Vector3.ZERO
		var consolidated_trigger_state:GUIDETrigger.GUIDETriggerState
		
		for input_mapping:GUIDEInputMapping in action_mapping.input_mappings:
			input_mapping._update_state(delta, action.action_value_type)
			consolidated_value += input_mapping._value
			consolidated_trigger_state = max(consolidated_trigger_state, input_mapping._state)
		
		# we do the blocking check only here because triggers may need to run anyways
		# (e.g. to collect hold times).
		if blocked_actions.has(action):
			consolidated_trigger_state = GUIDETrigger.GUIDETriggerState.NONE
		
		if action.block_lower_priority_actions and \
			consolidated_trigger_state == GUIDETrigger.GUIDETriggerState.TRIGGERED and \
			_actions_sharing_input.has(action):
			for blocked_action in _actions_sharing_input[action]:
				blocked_actions.add(blocked_action)
			
		
		# Now state change events.
		match(action._last_state):
			GUIDEAction.GUIDEActionState.TRIGGERED:
				match(consolidated_trigger_state):
					GUIDETrigger.GUIDETriggerState.NONE:
						action._completed(consolidated_value)
					GUIDETrigger.GUIDETriggerState.ONGOING:
						action._ongoing(consolidated_value, delta)
					GUIDETrigger.GUIDETriggerState.TRIGGERED:
						action._triggered(consolidated_value, delta)
						
			GUIDEAction.GUIDEActionState.ONGOING:
				match(consolidated_trigger_state):
					GUIDETrigger.GUIDETriggerState.NONE:
						action._cancelled(consolidated_value)
					GUIDETrigger.GUIDETriggerState.ONGOING:
						action._ongoing(consolidated_value, delta)
					GUIDETrigger.GUIDETriggerState.TRIGGERED:
						action._triggered(consolidated_value, delta)
						
			GUIDEAction.GUIDEActionState.COMPLETED:
				match(consolidated_trigger_state):
					GUIDETrigger.GUIDETriggerState.NONE:
						# make sure the value updated but don't emit any other events
						action._update_value(consolidated_value)
					GUIDETrigger.GUIDETriggerState.ONGOING:
						action._started(consolidated_value)
					GUIDETrigger.GUIDETriggerState.TRIGGERED:
						action._triggered(consolidated_value, delta)
						
func _update_caches():
	# Notify existing inputs that they aren no longer required
	for input:GUIDEInput in _active_inputs:
		input._reset()
		input._end_usage()
		
	# Cancel all actions, so they don't remain in weird states.
	for mapping:GUIDEActionMapping in _active_action_mappings:
		match mapping.action._last_state:
			GUIDEAction.GUIDEActionState.ONGOING:
				mapping.action._cancelled(Vector3.ZERO)
			GUIDEAction.GUIDEActionState.TRIGGERED:
				mapping.action._completed(Vector3.ZERO)
		# notify all modifiers they are no longer in use
		for input_mapping in mapping.input_mappings:
			for modifier in input_mapping.modifiers:
				modifier._end_usage()
		
	_active_inputs.clear()
	_active_action_mappings.clear()
	_actions_sharing_input.clear()
	
	var sorted_contexts:Array[Dictionary] = []
	
	for context:GUIDEMappingContext in _active_contexts.keys():
		sorted_contexts.append({"context": context, "priority": _active_contexts[context]})

	sorted_contexts.sort_custom( func(a,b): return a.priority < b.priority )
	
	# The actions we already have processed. Same action may appear in different
	# contexts, so if we find the same action twice, only the first instance wins.
	var processed_actions:Dictionary[GUIDEAction, GUIDEActionMapping]
	var consolidated_inputs:GUIDESet = GUIDESet.new()

	for entry:Dictionary in sorted_contexts:
		var context:GUIDEMappingContext = entry.context
		var position:int = 0
		for action_mapping:GUIDEActionMapping in context.mappings:
			position += 1
			var action := action_mapping.action
			
			# Mapping may be misconfigured, so we need to handle the case
			# that the action is missing.
			if action == null:
				push_warning("Mapping at position %s in context %s has no action set. This mapping will be ignored." % [position, context.resource_path])
				continue
			
			# If this is the first time we're seeing this action,
			# create a new action mapping for it.
			if action not in processed_actions:
				processed_actions[action] = GUIDEActionMapping.new()
				processed_actions[action].action = action
			
			# We consolidate the inputs here, so we'll internally build a new
			# action mapping that uses consolidated inputs rather than the
			# original ones. This achieves multiple things:
			# - if two actions check for the same input, we only need to
			#   process the input once instead of twice.
			# - it allows us to prioritize input, if two actions check for  
			#   the same input. This way the first action can consume the
			#   input and not have it affect further actions.
			# - we make sure nobody shares triggers as they are stateful and
			#   should not be shared.

			# now update the input mappings
			for index in action_mapping.input_mappings.size():
				var bound_input:GUIDEInput = action_mapping.input_mappings[index].input
				
				# if the mapping has an override for the input, apply it.
				if _active_remapping_config != null and \
						_active_remapping_config._has(context, action, index):
					bound_input = _active_remapping_config._get_bound_input_or_null(context, action, index)

				# make a new input mapping
				var new_input_mapping := GUIDEInputMapping.new()

				# can be null for combo mappings, so check that
				if bound_input != null:
					# check if we already have this kind of input
					var existing = consolidated_inputs.first_match(func(it:GUIDEInput): return it.is_same_as(bound_input))
					if existing != null:
						# if we have this already, use the instance we have
						bound_input = existing
					else:
						# otherwise register this input into the consolidated input
						consolidated_inputs.add(bound_input)
					
				new_input_mapping.input = bound_input
				# modifiers cannot be re-bound so we can just use the one
				# from the original configuration. this is also needed for shared
				# modifiers to work.
				new_input_mapping.modifiers = action_mapping.input_mappings[index].modifiers
				# triggers also cannot be re-bound but we still make a copy 
				# to ensure that no shared triggers exist.
				new_input_mapping.triggers = []
				
				for trigger in action_mapping.input_mappings[index].triggers:
					new_input_mapping.triggers.append(trigger.duplicate())
				
				new_input_mapping._initialize()
				
				# and add it to the new mapping
				processed_actions[action].input_mappings.append(new_input_mapping)

	# if any binding remains, add the mapping to the list of active
	# action mappings
	for action in processed_actions:
		if not processed_actions[action].input_mappings.is_empty():
			_active_action_mappings.append(processed_actions[action])

	# INVARIANT: all _active_action_mappings now have actions.

	# now we have a new set of active inputs		
	for input:GUIDEInput in consolidated_inputs.values():
		_active_inputs.append(input)
		
	# prepare the action input share lookup table
	for i:int in _active_action_mappings.size():
		
		var mapping = _active_action_mappings[i]
		
		if mapping.action.block_lower_priority_actions:
			# first find out if the action uses any chorded actions and 
			# collect all inputs that this action uses
			var chorded_actions:GUIDESet = GUIDESet.new()
			var inputs:GUIDESet = GUIDESet.new()
			var blocked_actions:GUIDESet = GUIDESet.new()
			for input_mapping:GUIDEInputMapping in mapping.input_mappings:
				if input_mapping.input != null:
					inputs.add(input_mapping.input)		
						
				for trigger:GUIDETrigger in input_mapping.triggers:
					if trigger is GUIDETriggerChordedAction and trigger.action != null:
						chorded_actions.add(trigger.action)
						
			# Now the action that has a chorded action (A) needs to make sure that
			# the chorded action it depends upon (B) is not blocked (otherwise A would 
			# never trigger) and if that chorded action (B) in turn depends on chorded actions. So 
			# if chorded actions build a chain, we need to keep the full
			# chain unblocked. In addition we need to add the inputs of all
			# these chorded actions to the list of blocked inputs.
			for j:int in range(i+1, _active_action_mappings.size()):
				var inner_mapping = _active_action_mappings[j]
				# this is a chorded action that is used by one other action
				# in the chain.
				if chorded_actions.has(inner_mapping.action):
					for input_mapping:GUIDEInputMapping in inner_mapping.input_mappings:
						# put all of its inputs into the list of blocked inputs
						if input_mapping.input != null:
							inputs.add(input_mapping.input)
			
						# also if this mapping in turn again depends on a chorded
						# action, ad this one to the list of chorded actions
						for trigger:GUIDETrigger in input_mapping.triggers:
							if trigger is GUIDETriggerChordedAction and trigger.action != null:
								chorded_actions.add(trigger.action)
			
			# now find lower priority actions that share input
			for j:int in range(i+1, _active_action_mappings.size()):
				var inner_mapping = _active_action_mappings[j]
				if chorded_actions.has(inner_mapping.action):
					continue
					
				for input_mapping:GUIDEInputMapping in inner_mapping.input_mappings:
					if input_mapping.input == null:
						continue
					
					# because we consolidated input, we can now do an == comparison
					# to find equal input.
					if inputs.has(input_mapping.input):
						blocked_actions.add(inner_mapping.action)
						# we can continue to the next action
						break 
										
			if not blocked_actions.is_empty():
				_actions_sharing_input[mapping.action] = blocked_actions.values()
				
	_reset_node._inputs_to_reset.clear()
	for input:GUIDEInput in _active_inputs:
		# finally collect which inputs we need to reset per frame
		if input._needs_reset():
			_reset_node._inputs_to_reset.append(input)

		# Give the state to the input
		input._state = _input_state		
		# Notify inputs that GUIDE is about to use them
		input._begin_usage()
	
	for mapping in _active_action_mappings:
		for input_mapping in mapping.input_mappings:
			# notify modifiers they will be used.
			for modifier in input_mapping.modifiers:
				modifier._begin_usage()
		
			# and copy over the hold time threshold from the mapping
			mapping.action._trigger_hold_threshold = input_mapping._trigger_hold_threshold
		
	# and notify interested parties that the input mappings have changed
	input_mappings_changed.emit()


