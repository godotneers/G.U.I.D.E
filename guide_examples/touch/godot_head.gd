extends Node2D

@export var lifetime_seconds:float = 5.0
var _remaining_time_seconds:float = 0

func _ready() -> void:
	_remaining_time_seconds = lifetime_seconds

func _process(delta:float) -> void:
	_remaining_time_seconds -= delta
	if _remaining_time_seconds <= 0:
		queue_free()
		return
	
	modulate.a = _remaining_time_seconds / lifetime_seconds
