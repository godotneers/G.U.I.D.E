## Input from two virtual joy axes.
class_name GUIDEInputVirtualJoyAxis2D
extends GUIDEInputVirtualJoyBase

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
	GUIDEInternalVirtualJoyRelay.Instance.joy_axis_changed.connect(_on_joy_axis_changed)
	
func _end_usage() -> void:
	GUIDEInternalVirtualJoyRelay.Instance.joy_axis_changed.disconnect(_on_joy_axis_changed)
	
	
func _on_joy_axis_changed(joy_index:int, axis:int, value:float) -> void:
	if self.joy_index > -1 and self.joy_index != joy_index:
		return
		
	if axis != x and axis != y:
		return
		
	if axis == x:
		_value.x = value
		return
		
	if axis == y:
		_value.y = value


func is_same_as(other:GUIDEInput) -> bool:
	return other is GUIDEInputVirtualJoyAxis2D and \
		other.x == x and \
		other.y == y and \
		other.joy_index == joy_index

func _to_string():
	return "(GUIDEInputVirtualJoyAxis2D: x=" + str(x) + ", y=" + str(y) + ", joy_index="  + str(joy_index) + ")"


func _editor_name() -> String:
	return "Virtual Joy Axis 2D"
	
func _editor_description() -> String:
	return "The input from two virtual joy axes. Usually from a stick."
	

func _native_value_type() -> GUIDEAction.GUIDEActionValueType:
	return GUIDEAction.GUIDEActionValueType.AXIS_2D
