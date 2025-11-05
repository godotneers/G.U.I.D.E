## This is  the player script. Note how it has no clue about controllers, axis inversion
## etc. This is all handled by GUIDE and the remapping dialog.
extends Node2D

@export var speed:float = 300
@export var move_action:GUIDEAction
@export var fire_action:GUIDEAction

@export var fireball_scene:PackedScene

func _ready() -> void:
	fire_action.triggered.connect(_shoot_fireball)


func _process(delta:float) -> void:
	position += move_action.value_axis_2d.normalized() * speed * delta


func _shoot_fireball() -> void:
	var fireball:Node = fireball_scene.instantiate()
	fireball.direction = Vector2.UP
	get_parent().add_child(fireball)
	
	fireball.global_transform = global_transform
