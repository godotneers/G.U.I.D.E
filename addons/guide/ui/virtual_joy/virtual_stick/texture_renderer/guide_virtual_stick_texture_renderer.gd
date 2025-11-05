@tool
## Renders a virtual stick using textures for outline, stick, and an optional hidden state.
## Textures are uniformly scaled to match the current `stick_radius` so visuals
## always correspond to the stick size.
class_name GUIDEVirtualStickTextureRenderer
extends GUIDEVirtualStickRenderer

## When to show the joystick.
enum ShowMode {
	## Always show the joystick.
	ALWAYS = 0,
	## Only show the joystick when actuated.
	ON_ACTUATE = 1
}

## When the sticks should be shown on screen.
@export var show_stick: ShowMode = ShowMode.ON_ACTUATE:
	set(value):
		show_stick = value
		_rebuild()

## The outline texture to use for the stick.
@export var outline_texture: Texture2D = preload("stick_outline.svg"):
	set(value):
		outline_texture = value
		_rebuild()
		
## The stick texture to use for the stick.		
@export var stick_texture: Texture2D = preload("stick.svg"):
	set(value):
		stick_texture = value
		_rebuild()
		
## The texture to show when the stick is hidden (optional).		
@export var hidden_texture: Texture2D = preload("stick_hidden.svg"):
	set(value):
		hidden_texture = value
		_rebuild()

var _outline_sprite: Sprite2D
var _stick_sprite: Sprite2D
var _hidden_sprite: Sprite2D

func _ready() -> void:
	_rebuild()

## React to configuration changes on the parent stick (e.g., radius changes).
func _on_configuration_changed() -> void:
	_rebuild()

	
## (Re)build sprites and apply textures and scaling.
func _rebuild() -> void:
	_outline_sprite = _ensure_sprite(_outline_sprite, outline_texture)
	_stick_sprite = _ensure_sprite(_stick_sprite, stick_texture)
	_hidden_sprite = _ensure_sprite(_hidden_sprite, hidden_texture)
	_update(Vector2.ZERO, Vector2.ZERO, is_stick_actuated)
	
	
## Ensure a sprite exists, has the given texture, and is scaled to cover the
## circular stick area based on the current `stick_radius`.
## @param sprite The existing sprite (may be null/invalid).
## @param texture The texture to assign to the sprite.
## @return The ensured sprite instance.
func _ensure_sprite(sprite: Sprite2D, texture: Texture2D) -> Sprite2D:
	var ensured: Sprite2D = sprite
	if not is_instance_valid(ensured):
		ensured = Sprite2D.new()
		ensured.centered = true
		add_child(ensured)
	
	ensured.texture = texture
	
	# Scale uniformly so the sprite covers the stick circle based on stick_radius.
	var diameter: float = stick_radius * 2.0
	if diameter > 0.0:
		var tex: Texture2D = ensured.texture
		if is_instance_valid(tex):
			var tex_size: Vector2 = tex.get_size()
			if tex_size.x > 0.0 and tex_size.y > 0.0:
				var shortest: float = min(tex_size.x, tex_size.y)
				var factor: float = diameter / shortest
				ensured.scale = Vector2(factor, factor)
				ensured.position = Vector2.ZERO
	return ensured
		
		
	
## Update the visuals based on the new state.
## @param joy_position The position relative to this renderer.
## @param joy_offset Normalized offset from center using max actuation radius.
## @param is_actuated Whether or not the stick is currently actuated.
func _update(joy_position: Vector2, joy_offset: Vector2, is_actuated: bool) -> void:
	_stick_sprite.position = joy_position
	
	var should_be_visible: bool = is_actuated or show_stick == ShowMode.ALWAYS 
	
	_stick_sprite.visible = should_be_visible
	_outline_sprite.visible = should_be_visible
	_hidden_sprite.visible = not should_be_visible
		
		
