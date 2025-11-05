@tool
## Applies a separate curve to each input axis.
class_name GUIDEModifierCurve
extends GUIDEModifier


## The curve to apply to the x axis
@export var curve: Curve = default_curve()

## Apply modifier to X axis
@export var x: bool = true

## Apply modifier to Y axis
@export var y: bool = true

## Apply modifier to Z axis
@export var z: bool = true


## Create default curve resource with a smoothstep, 0.0 - 1.0 input/output range
static func default_curve() -> Curve:
	var curve := Curve.new()
	curve.add_point(Vector2(0.0, 0.0))
	curve.add_point(Vector2(1.0, 1.0))

	return curve

	
func is_same_as(other: GUIDEModifier) -> bool:
	return other is GUIDEModifierCurve and \
		curve == other.curve and \
		x == other.x and \
		y == other.y and \
		z == other.z

func _modify_input(input: Vector3, delta: float, value_type: GUIDEAction.GUIDEActionValueType) -> Vector3:
	# Curve should never be null
	if curve == null:
		push_error("No curve added to Curve modifier.")
		return input

	if not input.is_finite():
		return Vector3.INF

	# Return vector with enabled axes modified, others remain unchanged.
	return Vector3(
		curve.sample(input.x) if x else input.x,
		curve.sample(input.y) if y else input.y,
		curve.sample(input.z) if z else input.z
	)


func _editor_name() -> String:
	return "Curve"


func _editor_description() -> String:
	return "Applies a curve to each input axis."
