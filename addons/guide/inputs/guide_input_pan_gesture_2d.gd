@tool
class_name GUIDEInputPanGesture2D
extends GUIDEInput

# we don't get pan gesture updates when no pan is happening, so this needs
# to be reset every frame
func _needs_reset() -> bool:
	return true


func _begin_usage() -> void:
	# subscribe to pan gesture events
	_state.pan_gesture_changed.connect(_refresh)
	_refresh()

func _end_usage() -> void:
	# unsubscribe from pan gesture events
	_state.pan_gesture_changed.disconnect(_refresh)

func _refresh() -> void:
	var delta:Vector2 = _state.get_pan_delta_since_last_frame()
	_value.x = delta.x
	_value.y = delta.y


func is_same_as(other:GUIDEInput) -> bool:
	return other is GUIDEInputPanGesture2D

func _to_string() -> String:
	return "(GUIDEInputPanGesture2D)"


func _editor_name() -> String:
	return "Pan Gesture 2D"


func _editor_description() -> String:
	return "Two-finger pan gesture on trackpad or touchscreen."


func _native_value_type() -> GUIDEAction.GUIDEActionValueType:
	return GUIDEAction.GUIDEActionValueType.AXIS_2D

func _device_type() -> DeviceType:
	return DeviceType.MOUSE
