## Input from a single virtual joy axis.
@tool
class_name GUIDEInputVirtualJoyAxis1D
extends GUIDEInputVirtualJoyBase

## The joy axis to sample
@export var axis:JoyAxis = JOY_AXIS_LEFT_X:
	set(value):
		if value == axis:
			return
		axis = value
		emit_changed()	

func _begin_usage() -> void:
	GUIDEInternalVirtualJoyRelay.Instance.joy_axis_changed.connect(_on_joy_axis_changed)
	
func _end_usage() -> void:
	GUIDEInternalVirtualJoyRelay.Instance.joy_axis_changed.disconnect(_on_joy_axis_changed)

func _on_joy_axis_changed(joy_index:int, axis:int, value:float) -> void:
	if self.joy_index > -1 and self.joy_index != joy_index:
		return
		
	if axis != self.axis:
		return
		
	_value.x = value

func is_same_as(other:GUIDEInput) -> bool:
	return other is GUIDEInputVirtualJoyAxis1D and \
		other.axis == axis and \
		other.joy_index == joy_index

func _to_string():
	return "(GUIDEInputVirtualJoyAxis1D: axis=" + str(axis) + ", joy_index="  + str(joy_index) + ")"

func _editor_name() -> String:
	return "Virtual Joy Axis 1D"
	
func _editor_description() -> String:
	return "The input from a single virtual joy axis."
	

func _native_value_type() -> GUIDEAction.GUIDEActionValueType:
	return GUIDEAction.GUIDEActionValueType.AXIS_1D
