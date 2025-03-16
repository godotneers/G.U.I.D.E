## This is an example on how to make your own virtual stick renderer
## to achieve any look you like.
extends GUIDEVirtualStickRenderer

@onready var stick:Sprite2D = $Stick

func _update(joy_position: Vector2, joy_offset:Vector2, is_actuated:bool) -> void:
	stick.material.set_shader_parameter("stick_offset", joy_offset)
