## This just keeps the sprite endlessly scrolling. It's not related to input.
extends Sprite2D


func _process(_delta:float) -> void:
	# get rect of visible screen in world coordinates
	var rect := get_viewport().canvas_transform.affine_inverse() * get_viewport_rect()
	# fit the bg into the viewport
	global_position = rect.position
	global_scale =  rect.size / texture.get_size()
	
	# update scaling so the texture scales according to zoom level
	material.set_shader_parameter("scale", global_scale)
	var shader_offset :=  rect.position / texture.get_size()
	# and offset so we pick a texture offset relative to the movement of the camera
	material.set_shader_parameter("offset", shader_offset)
