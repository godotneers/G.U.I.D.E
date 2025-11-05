## Input from two joy axes.
class_name GUIDEInputJoyAxis2D
extends GUIDEInputJoyBase

## The joy axis to sample for x input.
@export var x:JoyAxis = JOY_AXIS_LEFT_X:
	set(value):
		if value == x:
			return
		x = value
		emit_changed()
		
		
## The joy axis to sample for y input.
@export var y:JoyAxis = JOY_AXIS_LEFT_Y:
	set(value):
		if value == y:
			return
		y = value
		emit_changed()

func _begin_usage() -> void:
	_state.joy_axis_state_changed.connect(_refresh)
	_refresh()
	
func _end_usage() -> void:	
	_state.joy_axis_state_changed.disconnect(_refresh)

	
func _refresh():
	_value.x = _state.get_joy_axis_value(joy_index, x)
	_value.y = _state.get_joy_axis_value(joy_index, y)
	
	
func is_same_as(other:GUIDEInput) -> bool:
	return other is GUIDEInputJoyAxis2D and \
		other.x == x and \
		other.y == y and \
		other.joy_index == joy_index

func _to_string() -> String:
	return "(GUIDEInputJoyAxis2D: x=" + str(x) + ", y=" + str(y) + ", joy_index="  + str(joy_index) + ")"


func _editor_name() -> String:
	return "Joy Axis 2D"
	
func _editor_description() -> String:
	return "The input from two Joy axes. Usually from a stick."
	

func _native_value_type() -> GUIDEAction.GUIDEActionValueType:
	return GUIDEAction.GUIDEActionValueType.AXIS_2D
