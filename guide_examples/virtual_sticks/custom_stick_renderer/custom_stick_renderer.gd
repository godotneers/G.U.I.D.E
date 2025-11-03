## This is an example of a custom renderer for virtual sticks.
## This renderer uses a shader to render the stick rather than predefined
## textures. 
@tool
extends GUIDEVirtualStickRenderer

@export_range(0,1,0.001) var outline_thickness:float = 0.025:
	set(value):
		outline_thickness = value
		_rebuild()

var _rect:ColorRect
var _material:ShaderMaterial

var _multiplier:float = 1.0


func _on_configuration_changed():
	_rebuild()

func _rebuild():	
	if not is_node_ready():
		return
		
	if not is_instance_valid(_rect):
		_rect = ColorRect.new()
		get_parent().add_child(_rect)
		_material = ShaderMaterial.new()
		_material.shader = preload("custom_stick_renderer.gdshader")
		_rect.material = _material
	
	# make the control big enough to render the joy fully without
	# cutting 
	var half_size := max_actuation_radius + stick_radius
	half_size += half_size * outline_thickness 
	
	# the multiplier tells us which fraction of the total half size is 
	# the max actuation radius. this prevents us from moving the stick too
	# far.
	_multiplier = max_actuation_radius / half_size
	_rect.custom_minimum_size = Vector2(2 * half_size, 2 * half_size)
		
	_material.set_shader_parameter("stick_radius", stick_radius / (2.0 * half_size))
	_material.set_shader_parameter("outline_thickness", outline_thickness)	
		
func _update(joy_position: Vector2, joy_offset:Vector2, is_actuated:bool) -> void:
	_material.set_shader_parameter("stick_position", Vector2(0.5, 0.5) + _multiplier * joy_offset / 2.0)
