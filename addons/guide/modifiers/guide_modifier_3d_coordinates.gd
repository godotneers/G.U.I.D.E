## Converts a position input in viewport coordinates (e.g. from the mouse position input)
## into 3D coordinates (e.g. 3D world coordinates). Useful to get a 3D 'world' position.
## Returns a Vector3.INF if no 3D world coordinates can be determined.
@tool
class_name GUIDEModifier3DCoordinates
extends GUIDEModifier

## The maximum depth of the ray cast used to detect the 3D position.
@export var max_depth:float = 1000.0

## Whether the rays cast should collide with areas.
@export var collide_with_areas:bool = false

## Collision mask to use for the ray cast.
@export_flags_3d_physics var collision_mask:int

# The latest known input for this physics frame
var _input: Vector3 = Vector3.ZERO
# The output coordinates matching the latest known input
var _latest_update_input: Vector3 = Vector3.ZERO

func is_same_as(other:GUIDEModifier) -> bool:
	return other is GUIDEModifier3DCoordinates and \
		collide_with_areas == other.collide_with_areas and \
		collision_mask == other.collision_mask and \
		is_equal_approx(max_depth, other.max_depth)

func _needs_physics_process() -> bool:
	return true

func _physics_process(_delta: float) -> void:
	_latest_update_input = _update_input(_input)


func _modify_input(input:Vector3, delta:float, value_type:GUIDEAction.GUIDEActionValueType) -> Vector3:
	_input = input
	return _latest_update_input


func _update_input(input: Vector3) -> Vector3:
	# if we collide with nothing, no need to even try
	if collision_mask == 0:
		return Vector3.INF
		
	if not input.is_finite():
		return Vector3.INF
			
	var viewport = Engine.get_main_loop().root
	var camera:Camera3D = viewport.get_camera_3d()
	if camera == null:
		return Vector3.INF
		
	var input_position:Vector2 = Vector2(input.x, input.y)	
		
	var from:Vector3 = camera.project_ray_origin(input_position)
	var to:Vector3 = from + camera.project_ray_normal(input_position) * max_depth
	var query:= PhysicsRayQueryParameters3D.create(from, to, collision_mask)
	query.collide_with_areas = collide_with_areas
		
	var result = viewport.world_3d.direct_space_state.intersect_ray(query)
	if result.has("position"):
		return result.position
		
	return Vector3.INF	

func _editor_name() -> String:
	return "3D coordinates"


func _editor_description() -> String:
	return "Converts a position input in viewport coordinates (e.g. from the mouse position input)\n" + \
		"into 3D coordinates (e.g. 3D world coordinates). Useful to get a 3D 'world' position."
