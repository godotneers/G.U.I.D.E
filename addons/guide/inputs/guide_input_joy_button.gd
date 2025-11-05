@tool
class_name GUIDEInputJoyButton
extends GUIDEInputJoyBase

@export var button:JoyButton = JOY_BUTTON_A:
	set(value):
		if value == button:
			return
		button = value
		emit_changed()		

func _begin_usage() -> void:
	_state.joy_button_state_changed.connect(_refresh)
	_refresh()
	
func _end_usage() -> void:
	_state.joy_button_state_changed.disconnect(_refresh)

func _refresh():
	_value.x = 1.0 if _state.is_joy_button_pressed(joy_index, button) else 0.0

	
func is_same_as(other:GUIDEInput) -> bool:
	return other is GUIDEInputJoyButton and \
		 other.button == button and \
		 other.joy_index == joy_index


func _to_string() -> String:
	return "(GUIDEInputJoyButton: button=" + str(button) + ", joy_index="  + str(joy_index) + ")"


func _editor_name() -> String:
	return "Joy Button"
	
func _editor_description() -> String:
	return "A button press from a joy button."
	

func _native_value_type() -> GUIDEAction.GUIDEActionValueType:
	return GUIDEAction.GUIDEActionValueType.BOOL
