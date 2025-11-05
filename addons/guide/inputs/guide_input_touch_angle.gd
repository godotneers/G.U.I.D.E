## Input representing angle changes between two fingers. 
@tool
class_name GUIDEInputTouchAngle
extends GUIDEInput

## Unit in which the angle should be provided
enum AngleUnit {
	## Angle is provided in radians
	RADIANS = 0,
	## Angle is provided in degrees.
	DEGREES = 1
}

## The unit in which the angle should be provided
@export var unit:AngleUnit = AngleUnit.RADIANS

var _initial_angle:float = INF

# We use the reset call to calculate the angle for this frame
# so it can serve as reference for the next frame
func _needs_reset() -> bool:
	return true

func _reset() -> void:
	var angle := _calculate_angle()
	# update initial angle when input is actuated or stops being actuated
	if is_finite(_initial_angle) != is_finite(angle):
		_initial_angle = angle

func _begin_usage() -> void:
	# subscribe to relevant input events
	_state.touch_state_changed.connect(_refresh)
	_refresh()
	
func _end_usage() -> void:
	# unsubscribe from input events
	_state.touch_state_changed.disconnect(_refresh)
	
func _refresh():
	var angle := _calculate_angle()
	# if either current angle or initial angle is not set,
	# we are zero
	if not is_finite(angle) or not is_finite(_initial_angle):
		_value = Vector3.ZERO
		return
		
	# we assume that _initial_distance is never 0 because
	# you cannot have two fingers physically at the same place
	# on a touch screen (unless you're a ghost, which raises
	# the question how you are using a touch screen in the first place)
	var final_angle:float = angle - _initial_angle
	if unit == AngleUnit.DEGREES:
		final_angle = rad_to_deg(final_angle)
	
	_value = Vector3(final_angle, 0, 0)
		
	
func _calculate_angle() -> float:
	var pos1:Vector2 = _state.get_finger_position(0, 2)
	# if we have no position for first finger, we can immediately abort
	if not pos1.is_finite():
		return INF
		
	var pos2:Vector2 = _state.get_finger_position(1, 2)
	# if there is no second finger, we can abort as well
	if not pos2.is_finite():
		return INF
		
	# calculate distance for the fingers
	return -pos1.angle_to_point(pos2)
	
 		
func is_same_as(other:GUIDEInput):
	return other is GUIDEInputTouchAngle and \
		other.unit == unit


func _to_string():
	return "(GUIDEInputTouchAngle unit=" + ("radians" if unit == AngleUnit.RADIANS else "degrees") + ")"


func _editor_name() -> String:
	return "Touch Angle"

	
func _editor_description() -> String:
	return "Angle changes of two touching fingers."


func _native_value_type() -> GUIDEAction.GUIDEActionValueType:
	return GUIDEAction.GUIDEActionValueType.AXIS_1D
