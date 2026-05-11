## Input interpreting joy axis value as a direction.
@tool
class_name GUIDEInputJoyDirection
extends GUIDEInputJoyBase

## The direction of the joy axis.
enum Direction {
	## The posititive direction - right for horizontal axis, down for vertical axis.
	POSITIVE,
	## The negative direction - left for horizontal axis, up for vertical axis.
	NEGATIVE
}

## The joy axis to sample
@export var axis:JoyAxis = JOY_AXIS_LEFT_X:
	set(value):
		if value == axis:
			return
		axis = value
		emit_changed()	


## The direction of the joy axis.
@export var direction:Direction = Direction.POSITIVE:
	set(value):
		if value == direction:
			return
		direction = value
		emit_changed()


## The minimum axis value that must be reached to consider the input actuated.	
@export var actuation_threshold:float = 0.5:
	set(value):
		if value == actuation_threshold:
			return
		actuation_threshold = value
		emit_changed()		


func _begin_usage() -> void:
	_state.joy_axis_state_changed.connect(_refresh)

	
func _end_usage() -> void:
	_state.joy_axis_state_changed.disconnect(_refresh)
	

func _refresh() -> void:
	var axis_value:float = _state.get_joy_axis_value(joy_index, axis)
	match direction:
		Direction.POSITIVE:
			_value.x = 1.0 if axis_value > 0 and abs(axis_value) >= actuation_threshold else 0.0
		Direction.NEGATIVE:
			_value.x = 1.0 if axis_value < 0 and abs(axis_value) >= actuation_threshold else 0.0


func is_same_as(other:GUIDEInput) -> bool:
	return other is GUIDEInputJoyDirection and \
		other.axis == axis and \
		other.direction == direction and \
		is_equal_approx(other.actuation_threshold, actuation_threshold) and \
		other.joy_index == joy_index


func _to_string() -> String:
	return "(GUIDEInputJoyDirection: axis=" + str(axis) + ", direction=" + str(direction) + ", joy_index="  + str(joy_index) + ")"


func _editor_name() -> String:
	return "Joy Direction"

	
func _editor_description() -> String:
	return "The direction of a joy axis."

	
func _native_value_type() -> GUIDEAction.GUIDEActionValueType:
	return GUIDEAction.GUIDEActionValueType.BOOL
