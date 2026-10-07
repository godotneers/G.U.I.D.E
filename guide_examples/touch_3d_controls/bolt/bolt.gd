extends Node3D

@export var speed:float = 10
@export var lifetime:float = 2.0

func _process(delta: float) -> void:
	position += -basis.z * delta * speed
	lifetime -= delta
	if lifetime <= 0:
		queue_free()
