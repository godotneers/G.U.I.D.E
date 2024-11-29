@tool
## Maps an input range to an output range and optionally clamps the output.
class_name GUIDEModifierMapRange
extends GUIDEModifier

## Should the output be clamped to the range?
@export var apply_clamp:bool = false

## The minimum input value
@export var input_min:float = 0.0

## The maximum input value
@export var input_max:float = 1.0

## The minimum output value
@export var output_min:float = 0.0

## The maximum output value
@export var output_max:float = 1.0


func _modify_input(input:Vector3, delta:float, value_type:GUIDEAction.GUIDEActionValueType) -> Vector3:
	var x:float = remap(input.x, input_min, input_max, output_min, output_max)
	var y:float = remap(input.y, input_min, input_max, output_min, output_max)
	var z:float = remap(input.z, input_min, input_max, output_min, output_max)
	
	if apply_clamp:
		x = clamp(x, output_min, output_max)
		y = clamp(y, output_min, output_max)
		z = clamp(z, output_min, output_max)

	return Vector3(x, y, z)


func _editor_name() -> String:
	return "Map Range"


func _editor_description() -> String:
	return "Maps an input range to an output range and optionally clamps the output"
