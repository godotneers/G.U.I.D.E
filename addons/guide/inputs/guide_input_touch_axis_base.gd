## Base class for axis-like touch input.
@tool
class_name GUIDEInputTouchAxisBase
extends GUIDEInputTouchBase

var _last_position:Vector2 = Vector2.INF

# We use the reset call to calculate the position for this frame
# so it can serve as reference for the next frame
func _needs_reset() -> bool:
	return true

func _reset() -> void:
	_last_position = _state.get_finger_position(finger_index, finger_count)
	_apply_value(_calculate_value(_last_position))

func _begin_usage() -> void:
	# subscribe to relevant input events	
	_state.touch_state_changed.connect(_refresh)
	_refresh()

func _end_usage() -> void:
	# unsubscribe from input events
	_state.touch_state_changed.disconnect(_refresh)
	
func _refresh() -> void:
	# calculate live position from the cache
	var new_position:Vector2 = _state.get_finger_position(finger_index, finger_count)

	_apply_value(_calculate_value(new_position))

func _apply_value(value:Vector2):
	pass	
			
func _calculate_value(new_position:Vector2) -> Vector2:
	# if we cannot calculate a delta because old or new position
	# are undefined, we say the delta is zero	
	if not _last_position.is_finite() or not new_position.is_finite():
		return Vector2.ZERO
	
	return new_position - _last_position

		
func is_same_as(other:GUIDEInput):
	return other is GUIDEInputTouchAxis2D and \
		other.finger_count == finger_count and \
		other.finger_index == finger_index

