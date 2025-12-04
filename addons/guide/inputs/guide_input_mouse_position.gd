@tool
class_name GUIDEInputMousePosition
extends GUIDEInput


func _begin_usage() -> void :
	# subscribe to mouse movement events
	_state.mouse_position_changed.connect(_refresh)
	_refresh()
	
func _end_usage() -> void:
	# unsubscribe from mouse movement events
	_state.mouse_position_changed.disconnect(_refresh)

func _refresh():
	var position:Vector2 = _state.get_mouse_position()

	_value.x = position.x
	_value.y = position.y
		
		
func is_same_as(other:GUIDEInput) -> bool:
	return other is GUIDEInputMousePosition


func _to_string() -> String:
	return "(GUIDEInputMousePosition)"


func _editor_name() -> String:
	return "Mouse Position"

	
func _editor_description() -> String:
	return "Position of the mouse in the main viewport."


func _native_value_type() -> GUIDEAction.GUIDEActionValueType:
	return GUIDEAction.GUIDEActionValueType.AXIS_2D

func _device_type() -> DeviceType:
	return DeviceType.MOUSE
