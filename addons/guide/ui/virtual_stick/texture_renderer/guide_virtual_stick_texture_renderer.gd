@tool
class_name GUIDEVirtualStickTextureRenderer
extends GUIDEVirtualStickRenderer

enum ShowMode {
	ALWAYS,
	ON_ACTUATE
}

## When the sticks should be shown on screen.
@export var show_stick:ShowMode = ShowMode.ON_ACTUATE:
	set(value):
		show_stick = value
		_rebuild()

## The outline texture to use for the stick.
@export var outline_texture:Texture2D = preload("stick_outline.svg"):
	set(value):
		outline_texture = value
		_rebuild()
		
## The stick texture to use for the stick.		
@export var stick_texture:Texture2D = preload("stick.svg"):
	set(value):
		stick_texture = value
		_rebuild()
		
## The texture to show when the stick is hidden (optional).		
@export var hidden_texture:Texture2D = preload("stick_hidden.svg"):
	set(value):
		hidden_texture = value
		_rebuild()

var _outline_sprite:Sprite2D
var _stick_sprite:Sprite2D
var _hidden_sprite:Sprite2D

func _ready():
	_rebuild()
	
	
func _rebuild():
	if not is_instance_valid(_outline_sprite):
		_outline_sprite = Sprite2D.new()
		add_child(_outline_sprite)
	
	_outline_sprite.texture = outline_texture
	
	
	if not is_instance_valid(_stick_sprite):
		_stick_sprite = Sprite2D.new()
		add_child(_stick_sprite)
		
	_stick_sprite.texture = stick_texture
	
	if not is_instance_valid(_hidden_sprite):
		_hidden_sprite = Sprite2D.new()
		add_child(_hidden_sprite)
		
	_hidden_sprite.texture = hidden_texture
	
	_update(Vector2.ZERO, Vector2.ZERO, false)
	
	
func _update(joy_position: Vector2, joy_offset:Vector2, is_actuated:bool) -> void:
	_stick_sprite.position = joy_position
	
	var should_be_visible := is_actuated or show_stick == ShowMode.ALWAYS 
	
	_stick_sprite.visible = should_be_visible
	_outline_sprite.visible = should_be_visible
	_hidden_sprite.visible = not should_be_visible
		
		
