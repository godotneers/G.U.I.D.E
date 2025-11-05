@tool
## A filter that converts a 2D input into a boolean that is true when the 
## input direction matches the selected direction. Note, that north is negative Y, 
## because in Godot negative Y is up.
class_name GUIDEModifier8WayDirection
extends GUIDEModifier

enum GUIDEDirection {
 	EAST = 0, 
	NORTH_EAST = 1,
	NORTH = 2, 
	NORTH_WEST = 3,
	WEST = 4, 
	SOUTH_WEST = 5,
	SOUTH = 6, 
	SOUTH_EAST = 7
}

## The direction in which the input should point.
@export var direction:GUIDEDirection = GUIDEDirection.EAST

func is_same_as(other:GUIDEModifier) -> bool:
	return other is GUIDEModifier8WayDirection and \
		direction == other.direction

func _modify_input(input:Vector3, delta:float, value_type:GUIDEAction.GUIDEActionValueType) -> Vector3:
	if not input.is_finite():
		return Vector3.INF
		
	if input.is_zero_approx():
		return Vector3.ZERO
		
	
		
	# get the angle in which the direction is pointing in radians.
	var angle_radians := atan2( -input.y, input.x );
	var octant := roundi( 8 * angle_radians / TAU + 8 ) % 8;
	if octant == direction:
		return Vector3.RIGHT # (1, 0, 0) indicating boolean true
	else:
		return Vector3.ZERO

			
func _editor_name() -> String:
	return "8-way direction"


func _editor_description() -> String:
	return "Converts a 2D input into a boolean that is true when the\n" + \
		"input direction matches the selected direction. Note, that north is negative Y,\n" + \
		"because in Godot negative Y is up."
