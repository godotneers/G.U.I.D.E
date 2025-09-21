extends Node2D

@export var move_ship:GUIDEAction
@export var rotate_ship:GUIDEAction
@export var speed:float = 200
@export var rotation_speed_degrees:float = 360

func _process(delta):
	rotate(delta * rotate_ship.value_axis_1d * deg_to_rad(rotation_speed_degrees))

	var move = move_ship.value_axis_2d
	translate((transform.x * -move.y + transform.y * move.x) * speed * delta)	
