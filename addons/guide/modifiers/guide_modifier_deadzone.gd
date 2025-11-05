@tool
## Inputs between the lower and upper threshold are mapped 0 -> 1.
## Values outside the thresholds are clamped.
class_name GUIDEModifierDeadzone
extends GUIDEModifier

## Lower threshold for the deadzone. 
@export_range(0, 1) var lower_threshold: float = 0.2:
	set(value):
		if value > upper_threshold:
			lower_threshold = upper_threshold
		else:
			lower_threshold = value
		emit_changed()

## Upper threshold for the deadzone.
@export_range(0, 1) var upper_threshold: float = 1.0:
	set(value):
		if value < lower_threshold:
			upper_threshold = lower_threshold
		else:
			upper_threshold = value
		emit_changed()


func is_same_as(other: GUIDEModifier) -> bool:
	return other is GUIDEModifierDeadzone and \
	is_equal_approx(lower_threshold, other.lower_threshold) and \
	is_equal_approx(upper_threshold, other.upper_threshold)


func _rescale(value: float) -> float:
	return min(1.0, (max(0.0, abs(value) - lower_threshold) / (upper_threshold - lower_threshold))) * sign(value)


func _modify_input(input: Vector3, _delta: float, value_type: GUIDEAction.GUIDEActionValueType) -> Vector3:
	if upper_threshold <= lower_threshold:
		return input
	
	if not input.is_finite():
		return Vector3.INF
	
	match value_type:
		GUIDEAction.GUIDEActionValueType.BOOL, GUIDEAction.GUIDEActionValueType.AXIS_1D:
			return Vector3(_rescale(input.x), input.y, input.z)
		
		GUIDEAction.GUIDEActionValueType.AXIS_2D:
			var v2d := Vector2(input.x, input.y)
			if v2d.is_zero_approx():
				return Vector3(0, 0, input.z)
			v2d = v2d.normalized() * _rescale(v2d.length())
			return Vector3(v2d.x, v2d.y, input.z)
		
		GUIDEAction.GUIDEActionValueType.AXIS_3D:
			if input.is_zero_approx():
				return Vector3.ZERO
			return input.normalized() * _rescale(input.length())
		_:
			push_error("Unsupported value type. This is a bug. Please report it.")
			return input


func _editor_name() -> String:
	return "Deadzone"


func _editor_description() -> String:
	return "Inputs between the lower and upper threshold are mapped 0 -> 1.\n" + \
	"Values outside the thresholds are clamped."
