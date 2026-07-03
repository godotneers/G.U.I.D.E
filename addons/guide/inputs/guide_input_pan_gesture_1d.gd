@tool
class_name GUIDEInputPanGesture1D
extends GUIDEInput

enum GUIDEInputPanGestureAxis {
	X,
	Y
}

@export var axis:GUIDEInputPanGestureAxis:
	set(value):
		if value == axis:
			return
		axis = value
		emit_changed()

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
	match axis:
		GUIDEInputPanGestureAxis.X:
			_value.x = delta.x
		GUIDEInputPanGestureAxis.Y:
			_value.x = delta.y


func is_same_as(other:GUIDEInput) -> bool:
	return other is GUIDEInputPanGesture1D and other.axis == axis

func _to_string() -> String:
	return "(GUIDEInputPanGesture1D: axis=" + str(axis) + ")"


func _editor_name() -> String:
	return "Pan Gesture 1D"


func _editor_description() -> String:
	return "Two-finger pan gesture on a single axis."


func _native_value_type() -> GUIDEAction.GUIDEActionValueType:
	return GUIDEAction.GUIDEActionValueType.AXIS_1D

func _device_type() -> DeviceType:
	return DeviceType.MOUSE
