extends MarginContainer

@onready var _actions:Container = %Actions
@onready var _inputs:Container = %Inputs
@onready var _priorities:Container = %Priorities
@onready var _formatter:GUIDEInputFormatter = GUIDEInputFormatter.for_active_contexts()


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	GUIDE.input_mappings_changed.connect(_update_priorities)
	_update_priorities()

func _process(delta) -> void:
	if not is_visible_in_tree():
		return
		
	var index:int = 0
	for mapping in GUIDE._active_action_mappings:
		var action:GUIDEAction = mapping.action

		var action_name:String = action.name
		if action_name == "":
			action_name = action._editor_name()
			
		var action_state:String = ""
		match(action._last_state):
			GUIDEAction.GUIDEActionState.COMPLETED:
				action_state = "Completed"
			GUIDEAction.GUIDEActionState.ONGOING:
				action_state = "Ongoing"
			GUIDEAction.GUIDEActionState.TRIGGERED:
				action_state = "Triggered"
				
		var action_value:String = ""
		match(action.action_value_type):
			GUIDEAction.GUIDEActionValueType.BOOL:
				action_value = str(action.value_bool)
			GUIDEAction.GUIDEActionValueType.AXIS_1D:
				action_value = str(action.value_axis_1d)
			GUIDEAction.GUIDEActionValueType.AXIS_2D:
				action_value = str(action.value_axis_2d)
			GUIDEAction.GUIDEActionValueType.AXIS_3D:
				action_value = str(action.value_axis_3d)
				
				
				
		
		var label := _get_label(_actions, index)
		label.text = "[%s] %s - %s" % [action_name, action_state, action_value]
		
		index += 1
		
	# Clean out all labels we don't need anymore
	_cleanup(_actions, index)
	
	index = 0
	for input in GUIDE._active_inputs.values():
		var input_label := _formatter.input_as_text(input, false)	
		var input_value:String = str(input._value)

		var label := _get_label(_inputs, index)
		label.text = "%s - %s" % [input_label, input_value]
		index += 1
		
	_cleanup(_inputs, index)


func _get_label(container:Container, index:int) -> Label:
	var label:Label = null
	if container.get_child_count() > index:
		# reuse existing label
		label = container.get_child(index)
	else:
		# make a new one
		label = Label.new()
		label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		container.add_child(label)
	return label
	
func _cleanup(container:Container, index:int) -> void:
	while container.get_child_count() > index:
		var to_free := container.get_child(index)
		container.remove_child(to_free)		
		to_free.queue_free()	

func _update_priorities() -> void:
	# since we don't update these per frame, we can just clear them out and 
	# rebuild them when mapping contexts change
	_cleanup(_priorities, 0)
	
	for mapping:GUIDEActionMapping in GUIDE._active_action_mappings:
		var action := mapping.action
		if GUIDE._actions_sharing_input.has(action):
			var label := Label.new()
			var names := ", ".join(GUIDE._actions_sharing_input[action].map(func(it): return it._editor_name()))
			label.text = "[%s] > [%s]" % [action._editor_name(), names]
			_priorities.add_child(label)
			
			
	if _priorities.get_child_count() == 0:
		var label := Label.new()
		label.text = "<no overlapping input>"
		_priorities.add_child(label)
