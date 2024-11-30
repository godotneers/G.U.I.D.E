@tool
## Applies a separate curve to each input axis.
class_name GUIDEModifierCurve
extends GUIDEModifier


## The curve to apply to the x axis
@export var curve:Curve

## Apply modifier to X axis
@export var x:bool = true

## Apply modifier to Y axis
@export var y:bool = true

## Apply modifier to Z axis
@export var z:bool = true


## Create default curve resource with a smoothstep, 0.0 - 1.0 input/output range
static func default_curve() -> Curve:
	var curve = Curve.new()
	curve.add_point(Vector2(0.0, 0.0))
	curve.add_point(Vector2(1.0, 1.0))

	return curve


# Initialize this resource with default curves
func _init(_curve:Curve = null, _x:bool = true, _y:bool = false, _z:bool = false):
	if _curve == null:
		_curve = default_curve()

	curve = _curve


func _modify_input(input:Vector3, delta:float, value_type:GUIDEAction.GUIDEActionValueType) -> Vector3:
	# Curve should never be null
	assert(curve != null, "No curve added to Curve modifier")

	var x_value:float = curve.sample(input.x)
	var y_value:float = curve.sample(input.y)
	var z_value:float = curve.sample(input.z)

	return Vector3(
		x_value if x else input.x,
		y_value if y else input.y,
		z_value if z else input.z
	)


func _editor_name() -> String:
	return "Curve"


func _editor_description() -> String:
	return "Applies a separate curve to each input axis."
