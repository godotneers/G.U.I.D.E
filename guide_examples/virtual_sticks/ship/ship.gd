extends Node2D

@export var move_ship: GUIDEAction
@export var rotate_ship: GUIDEAction
@export var fire_projectile: GUIDEAction
@export var speed: float = 200.0
@export var rotation_speed_degrees: float = 360.0
@export var projectile_scene: PackedScene
@export var projectile_spawn_offset: float = 40.0

func _ready() -> void:
	fire_projectile.triggered.connect(_fire)

func _process(delta: float) -> void:
	rotate(delta * rotate_ship.value_axis_1d * deg_to_rad(rotation_speed_degrees))
	var move: Vector2 = move_ship.value_axis_2d
	translate((transform.x * -move.y + transform.y * move.x) * speed * delta)

func _fire() -> void:
	if not is_instance_valid(projectile_scene):
		return

	var projectile: LaserProjectile = projectile_scene.instantiate() as LaserProjectile
	get_parent().add_child(projectile)
	
	projectile.global_transform = global_transform.translated(transform.x.normalized() * projectile_spawn_offset)
	
