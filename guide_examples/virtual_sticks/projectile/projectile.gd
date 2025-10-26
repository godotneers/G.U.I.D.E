## A fast-flying laser projectile.
## The projectile moves straight in the provided direction and despawns after its lifetime.
## @param speed Units per second to travel.
## @param lifetime Seconds to live before freeing.
class_name LaserProjectile
extends Node2D

@export var speed: float = 900.0
@export var lifetime: float = 1.5

var _age: float = 0.0

func _process(delta: float) -> void:
	translate(transform.x * speed * delta)
	_age += delta
	if _age >= lifetime:
		queue_free()

