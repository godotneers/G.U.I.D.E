@tool
class_name GUIDEInputMouseAxis2D
extends GUIDEInput


# we don't get mouse updates when the mouse is not moving, so this needs to be 
# reset every frame
func _needs_reset() -> bool:
	return true

func _begin_usage() -> void:
	# subscribe to mouse movement events
	_state.mouse_position_changed.connect(_refresh)
	_refresh()

func _end_usage() -> void:
	# unsubscribe from mouse movement events
	_state.mouse_position_changed.disconnect(_refresh)

func _refresh() -> void:
	var delta:Vector2 = _state.get_mouse_delta_since_last_frame()
	_value.x = delta.x
	_value.y = delta.y
		
func is_same_as(other:GUIDEInput) -> bool:
	return other is GUIDEInputMouseAxis2D


func _to_string() -> String:
	return "(GUIDEInputMouseAxis2D)"


func _editor_name() -> String:
	return "Mouse Axis 2D"

	
func _editor_description() -> String:
	return "Relative mouse movement on 2 axes."


func _native_value_type() -> GUIDEAction.GUIDEActionValueType:
	return GUIDEAction.GUIDEActionValueType.AXIS_2D

func _device_type() -> DeviceType:
	return DeviceType.MOUSE
