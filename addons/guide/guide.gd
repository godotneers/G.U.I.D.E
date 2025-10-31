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
var _active_inputs:GUIDESet = GUIDESet.new()

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

## A lock, preventing a mapping context change while a mapping
## context change is currently in progress.
var _locked:bool = false

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	_reset_node = GUIDEReset.new()
	_input_state = GUIDEInputState.new()
	_input_state._reset()
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
	# notify listeners that the context was enabled
	context.enabled.emit()
	
	
## Disables the given mapping context.
func disable_mapping_context(context:GUIDEMappingContext):
	if not is_instance_valid(context):
		push_error("Null context given. Ignoring.")
		return

	_active_contexts.erase(context)
	_update_caches()
	# notify listeners that the context was disabled
	context.disabled.emit()


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
			# print("%s - %s -> %s" % [Engine.get_process_frames(), consolidated_value, consolidated_trigger_state])
		
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

						
## This updates the caches of active inputs, action mappings and modifiers. It's sort of expensive to run
## but it is only run when contexts are enabled/disabled or remapping configs are applied and it saves
## a lot of processing time during the actual input processing. It also simplifies the input processing
## code as all the rules for how inputs, actions and modifiers are consolidated are already applied here.
## This is called automatically when contexts are enabled/disabled or remapping configs are applied.
func _update_caches():
	if _locked:
		push_error("Mapping context changed again while processing a change. Ignoring to avoid endless loop.")
		return
	
	_locked = true	
	
	var sorted_contexts:Array[GUIDEMappingContext] = []
	sorted_contexts.assign(_active_contexts.keys())
	sorted_contexts.sort_custom( func(a,b): return _active_contexts[a] < _active_contexts[b] )
	
	# The actions we already have processed. Same action may appear in different
	# contexts, so if we find the same action twice, only the first instance wins.
	var processed_actions:GUIDESet = GUIDESet.new()
	# The new inputs that we will use for the action mappings.
	var new_inputs:GUIDESet = GUIDESet.new()
	# The new action mappings that we will use from now on.
	var new_action_mappings:Array[GUIDEActionMapping] = []
	# The new modifiers that we will use
	var new_modifiers:GUIDESet = GUIDESet.new()

	# Step 0: walk over the new contexts and save over all inputs and modifiers that we
	# are going to keep. This is needed to ensure that we don't reset inputs and that if
	# new mappings don't create copies of existing inputs if they have a higher priority
	# than the existing ones (see https://github.com/godotneers/G.U.I.D.E/issues/94).
	for context:GUIDEMappingContext in sorted_contexts:
		for action_mapping:GUIDEActionMapping in context.mappings:
			for existing_mapping:GUIDEActionMapping in _active_action_mappings:
				if _is_same_action_mapping(existing_mapping, action_mapping):
					# we will keep using this mapping, so we will make sure its inputs and modifiers
					# are kept and not duplicated. We don't add the action mapping to the new action mappings
					# yet, because the order of the action mappings is important and we will
					# add it later when we process the action mappings.
					
					for input_mapping:GUIDEInputMapping in existing_mapping.input_mappings:
						if input_mapping.input != null:
							new_inputs.add(input_mapping.input)
						
						for modifier:GUIDEModifier in input_mapping.modifiers:
							new_modifiers.add(modifier)


	# Step 1: Collect all action mappings from the currently enabled contexts.
	for context:GUIDEMappingContext in sorted_contexts:
		var position:int = 0
		for action_mapping:GUIDEActionMapping in context.mappings:
			position += 1
			var action := action_mapping.action
			
			# Mapping may be misconfigured, so we need to handle the case
			# that the action is missing.
			if action == null:
				push_warning("Mapping at position %s in context %s has no action set. This mapping will be ignored." % [position, context.resource_path])
				continue
			
			# If the action was already configured in a higher priority context,
			# we'll skip it.
			if processed_actions.has(action):
				# skip
				continue
				
			processed_actions.add(action)
		
			# If the action mapping is the same as one that is already active,
			# we use the existing one instead of creating a new one.
			# We do this to avoid losing state in the  triggers and modifiers when
			# switching contexts. See https://github.com/godotneers/G.U.I.D.E/issues/67
			# for details. In addition there is no need to create new objects
			# if we already have a functional one (though the comparison of the mappings
			# is likely more expensive than the creation of a new one).
			var found_existing:bool = false
			for existing_mapping:GUIDEActionMapping in _active_action_mappings:
				if _is_same_action_mapping(existing_mapping, action_mapping):
					# we found an existing mapping, so we can just use it
					# and we can skip the rest of the processing for this mapping.
					new_action_mappings.append(existing_mapping)
					found_existing = true
					break
					
			if found_existing:
				# we already have this action mapping, so we can skip it
				continue
			
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
			
			var effective_mapping  = GUIDEActionMapping.new()
			effective_mapping.action = action
		
			# the trigger hold threshold is the minimum time that the input must be held
			# down before the action triggers. This is used to hint the UI about
			# how long the input must be held down. We collect this while iterating
			# over the input mappings.
			var trigger_hold_threshold:float = -1.0

			# now update the action and input mappings
			for index in action_mapping.input_mappings.size():
				# get the input that is assigned to this action mapping
				var bound_input:GUIDEInput = action_mapping.input_mappings[index].input
				
				# if the re-mapping has an override for the input (e.g. the player has changed
				# the default binding to something else), apply it.
				if _active_remapping_config != null and \
						_active_remapping_config._has(context, action, index):
					bound_input = _active_remapping_config._get_bound_input_or_null(context, action, index)

				# make a new input mapping
				var new_input_mapping:GUIDEInputMapping = GUIDEInputMapping.new()

				# bound_input can be null for combo mappings, so check that
				if bound_input != null:
					# check if we already have this kind of input
					# first try to find it in the currently active inputs, this way we don't need to recreate
					# inputs that are already active.
					var existing:GUIDEInput = _active_inputs.first_match(func(it:GUIDEInput): return it.is_same_as(bound_input))
					if existing == null:
						# try to find it in the consolidated inputs
						existing = new_inputs.first_match(func(it:GUIDEInput): return it.is_same_as(bound_input))
					
					if existing != null:
						# if we already use this input, we can just use the existing one
						bound_input = existing
						
					# ensure that the input is initialized and ready to be used
					if not _is_used(bound_input):
						bound_input._state = _input_state
						bound_input._begin_usage()
						_mark_used(bound_input, true)

					new_inputs.add(bound_input)
					
				new_input_mapping.input = bound_input
				# modifiers cannot be re-bound so we can just use the one
				# from the original configuration. this is also needed for shared
				# modifiers to work.
				new_input_mapping.modifiers = action_mapping.input_mappings[index].modifiers
				# track the modifiers, so we can later only disable the ones we don't need anymore.
				for modifier:GUIDEModifier in new_input_mapping.modifiers:
					# new_modifiers is a set so we can just add the modifier,
					# if we already have it, it will not be added again.
					new_modifiers.add(modifier)
					
					# initialize the modifier if it is not already in use
					if not _is_used(modifier):
						modifier._begin_usage()
						_mark_used(modifier, true)
						
				# triggers also cannot be re-bound but we still make a copy
				# to ensure that no shared triggers exist.
				new_input_mapping.triggers = []
				
				for trigger in action_mapping.input_mappings[index].triggers:
					new_input_mapping.triggers.append(trigger.duplicate())

				# now initialize the input mapping
				new_input_mapping._initialize(action.action_value_type)
				# collect the hold threshold
				var mapping_hold_threshold:float = new_input_mapping._trigger_hold_threshold
				# smallest hold threshold that isn't negative wins
				if trigger_hold_threshold < 0 or mapping_hold_threshold < trigger_hold_threshold:
					trigger_hold_threshold = mapping_hold_threshold
				
				# and add it to the new mapping
				effective_mapping.input_mappings.append(new_input_mapping)

			# finally we set the hold threshold for the action
			action._trigger_hold_threshold = trigger_hold_threshold
			
			# if any binding remains, add the mapping to the list of active
			# action mappings
			if not effective_mapping.input_mappings.is_empty():
				new_action_mappings.append(effective_mapping)

	# now we can clean up stuff, that we don't need anymore.
	# we start with the inputs that are no longer used.
	for input:GUIDEInput in _active_inputs.values():
		# because we consolidated inputs, we can do an instance check rather than
		# a is_same_as check.
		if new_inputs.has(input):
			continue

		# this input is no longer used, so we can reset it
		# and notify it that it is no longer used.
		input._reset()
		input._end_usage()
		input._state = null
		_mark_used(input, false)
		
	# and now the consolidated inputs are the new active inputs.
	_active_inputs = new_inputs
	
	# Now action mappings and their modifiers.
	for mapping:GUIDEActionMapping in _active_action_mappings:
		if new_action_mappings.has(mapping):
			# this mapping is still active, so we can skip it
			continue

		# Cancel all actions that are going away, so they don't end up in a weird state.
		match mapping.action._last_state:
			GUIDEAction.GUIDEActionState.ONGOING:
				mapping.action._cancelled(Vector3.ZERO)
			GUIDEAction.GUIDEActionState.TRIGGERED:
				mapping.action._completed(Vector3.ZERO)
		
		# notify all modifiers they are no longer in use
		for input_mapping in mapping.input_mappings:
			for modifier in input_mapping.modifiers:
				# because modifiers can be shared, we need to check if the modifier
				# is still in use by any other action mapping that remains in use.
				if not new_modifiers.has(modifier):
					modifier._end_usage()
					_mark_used(modifier, false)
	
	# and now we can assign the new action mappings
	_active_action_mappings = new_action_mappings
	
	# prepare the action input share lookup table
	_actions_sharing_input.clear()
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

	# collect which inputs we need to reset per frame
	_reset_node._inputs_to_reset.clear()
	for input:GUIDEInput in _active_inputs.values():
		if input._needs_reset():
			_reset_node._inputs_to_reset.append(input)
		
	# run a round of _process so we can be sure our actions are 
	# up-to-date
	_process(0.0)
	
	# unlock
	_locked = false
	
	# and notify interested parties that the input mappings have changed
	input_mappings_changed.emit()

## Helper function which determines whether two action mappings are the same.
## They are the same if they have the same action, the same input mappings
## the same modifiers and the same triggers. Same doesn't necessarily mean
## they are the same instance, but rather that they are equivalent in terms of
## their configuration.
static func _is_same_action_mapping(a:GUIDEActionMapping, b:GUIDEActionMapping) -> bool:
	# If its the same instance, we can just return true.
	if a == b:
		return true
		
	# If they don't have the same action, they cannot be the same.
	if a.action != b.action:
		return false
	
	# If they don't have the same number of input mappings, they cannot be the same.
	if a.input_mappings.size() != b.input_mappings.size():
		return false

	# Now check all input mappings.
	for i:int in range(a.input_mappings.size()):
		var input_mapping_a:GUIDEInputMapping = a.input_mappings[i]
		var input_mapping_b:GUIDEInputMapping = b.input_mappings[i]
		
		var input_a:GUIDEInput = input_mapping_a.input
		var input_b:GUIDEInput = input_mapping_b.input
		
		if input_a != null and input_b != null:
			# If the inputs are not the same, they cannot be the same.
			if not input_mapping_a.input.is_same_as(input_mapping_b.input):
				return false
		elif input_a != input_b:
			# If one input is null and the other is not, they cannot be the same.
			return false
		
		# If the modifiers are not the same, they cannot be the same.
		if input_mapping_a.modifiers.size() != input_mapping_b.modifiers.size():
			return false
		
		for j:int in range(input_mapping_a.modifiers.size()):
			var modifier_a:GUIDEModifier = input_mapping_a.modifiers[j]
			var modifier_b:GUIDEModifier = input_mapping_b.modifiers[j]
			
			if modifier_a != null and modifier_b != null:
				# If the modifiers are not the same, they cannot be the same.
				if not modifier_a.is_same_as(modifier_b):
					return false
			elif modifier_a != modifier_b:
				# If one modifier is null and the other is not, they cannot be the same.
				return false
		
		# If the triggers are not the same, they cannot be the same.
		if input_mapping_a.triggers.size() != input_mapping_b.triggers.size():
			return false
		
		for j:int in range(input_mapping_a.triggers.size()):
			var trigger_a:GUIDETrigger = input_mapping_a.triggers[j]
			var trigger_b:GUIDETrigger = input_mapping_b.triggers[j]
			
			if trigger_a != null and trigger_b != null:
				# If the triggers are not the same, they cannot be the same.
				if not trigger_a.is_same_as(trigger_b):
					return false
			elif trigger_a != trigger_b:
				# If one trigger is null and the other is not, they cannot be the same.
				return false
		
	return true

static func _mark_used(object: Object, value:bool) -> void:
	if value:
		object.set_meta("__guide_in_use", value)
	else:
		object.remove_meta("__guide_in_use")

static func _is_used(object: Object) -> bool:
	return object.has_meta("__guide_in_use")
	
