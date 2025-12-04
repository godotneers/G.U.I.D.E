@tool
class_name GUIDEInputTouchPosition
extends GUIDEInputTouchBase


func _begin_usage():
	# subscribe to touch events
	_state.touch_state_changed.connect(_refresh)
	_refresh()
	
func _end_usage():
	# unsubscribe from touch events
	_state.touch_state_changed.disconnect(_refresh)

func _refresh() -> void:
	# update finger position
	var position:Vector2 = _state.get_finger_position(finger_index, finger_count)
	if not position.is_finite():
		_value = Vector3.INF
		return
		
	_value = Vector3(position.x, position.y, 0) 

		
func is_same_as(other:GUIDEInput):
	return other is GUIDEInputTouchPosition and \
		other.finger_count == finger_count and \
		other.finger_index == finger_index


func _to_string():
	return "(GUIDEInputTouchPosition finger_count=" + str(finger_count) + \
		" finger_index=" + str(finger_index) +")"


func _editor_name() -> String:
	return "Touch Position"

	
func _editor_description() -> String:
	return "Position of a touching finger."


func _native_value_type() -> GUIDEAction.GUIDEActionValueType:
	return GUIDEAction.GUIDEActionValueType.AXIS_2D

