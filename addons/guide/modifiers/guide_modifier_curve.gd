@tool
## Applies a separate curve to each input axis.
class_name GUIDEModifierCurve
extends GUIDEModifier


## The curve to apply to the x axis
@export var curve_x:Curve

## The curve to apply to the y axis
@export var curve_y:Curve

## The curve to apply to the z axis
@export var curve_z:Curve


## Create default curve resource with a smoothstep, 0.0 - 1.0 input/output range
static func default_curve() -> Curve:
	var curve = Curve.new()
	curve.add_point(Vector2(0.0, 0.0))
	curve.add_point(Vector2(1.0, 1.0))

	return curve


# Initialize this resource with default curves
func _init(_curve_x:Curve = null, _curve_y:Curve = null, _curve_z:Curve = null):
	if _curve_x == null:
		_curve_x = default_curve()

	if _curve_y == null:
		_curve_y = default_curve()

	if _curve_z == null:
		_curve_z = default_curve()

	curve_x = _curve_x
	curve_y = _curve_y
	curve_z = _curve_z


func _modify_input(input:Vector3, delta:float, value_type:GUIDEAction.GUIDEActionValueType) -> Vector3:
	var x:float = curve_x.sample(input.x) if curve_x != null else 0.0
	var y:float = curve_y.sample(input.y) if curve_y != null else 0.0
	var z:float = curve_z.sample(input.z) if curve_z != null else 0.0

	return Vector3(x, y, z)


func _editor_name() -> String:
	return "Curve"


func _editor_description() -> String:
	return "Applies a separate curve to each input axis."
