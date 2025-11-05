extends Area2D


var _is_spinning:bool = false

func spin() -> void:
	if _is_spinning:
		return
	_is_spinning = true
	var tween := create_tween()
	tween.tween_property(self, "rotation_degrees", 360, 0.5)
	await tween.finished
	
	rotation_degrees = 0
	_is_spinning = false
