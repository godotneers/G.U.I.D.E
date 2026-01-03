@tool
extends Control

signal action_changed()

@onready var _line_edit:LineEdit = %LineEdit
@onready var _type_icon:TextureRect = %TypeIcon

var index:int

var action:GUIDEAction:
	set(value):
		if is_instance_valid(action):
			action.changed.disconnect(_refresh)
		
		action = value
	
		if is_instance_valid(action):
			action.changed.connect(_refresh)
	
		# action_changed can only be emitted by 
		# dragging an action into this, not when setting
		# the property
		_refresh()

		
func _refresh():
	if not is_instance_valid(action):
		_line_edit.text = "<none>"
		_line_edit.tooltip_text = ""
		_type_icon.texture = preload("missing_action.svg")
		_type_icon.tooltip_text = "Missing action"
	else:
		_line_edit.text = action._editor_name()	
		_line_edit.tooltip_text = action.resource_path
		## Update the icon to reflect the given value type.
		match action.action_value_type:
			GUIDEAction.GUIDEActionValueType.AXIS_1D:
				_type_icon.texture = preload("action_value_type_axis1d.svg")
				_type_icon.tooltip_text = "Axis1D"
			GUIDEAction.GUIDEActionValueType.AXIS_2D:
				_type_icon.texture = preload("action_value_type_axis2d.svg")
				_type_icon.tooltip_text = "Axis2D"
			GUIDEAction.GUIDEActionValueType.AXIS_3D:
				_type_icon.texture = preload("action_value_type_axis3d.svg")
				_type_icon.tooltip_text = "Axis3D"
			_:
				# fallback is bool
				_type_icon.texture = preload("action_value_type_bool.svg")
				_type_icon.tooltip_text = "Boolean"




func _gui_input(event):
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			if is_instance_valid(action):
				EditorInterface.edit_resource(action)



func _on_line_edit_action_dropped(new_action:GUIDEAction):
	action = new_action
	action_changed.emit()


func _on_line_edit_focus_entered():
	if is_instance_valid(action):
		EditorInterface.edit_resource(action)
