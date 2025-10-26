@tool
## Renders a virtual button using two textures for idle and actuated states.
## The textures are uniformly scaled so they fully cover the button area
## defined by the parent's `button_radius`.
class_name GUIDEVirtualButtonTextureRenderer
extends GUIDEVirtualButtonRenderer

## Texture shown when the button is NOT actuated.
@export var idle_texture: Texture2D = preload("idle.svg"):
	set(value):
		idle_texture = value
		_rebuild()

## Texture shown when the button IS actuated.
@export var actuated_texture: Texture2D = preload("actuated.svg"):
	set(value):
		actuated_texture = value
		_rebuild()

var _idle_sprite: Sprite2D
var _actuated_sprite: Sprite2D

func _ready() -> void:
	_rebuild()

## React to configuration changes from the parent button.
func _on_configuration_changed() -> void:
	_rebuild()

## (Re)build child sprites and apply textures.
func _rebuild() -> void:
	_idle_sprite = _ensure_sprite(_idle_sprite, idle_texture)
	_actuated_sprite = _ensure_sprite(_actuated_sprite, actuated_texture)
	_update(is_button_actuated)

## Update the visibility based on actuation.
## @param is_actuated Whether or not the button is currently actuated.
func _update(is_actuated: bool) -> void:
	_idle_sprite.visible = not is_actuated
	_actuated_sprite.visible = is_actuated

## Ensure a sprite exists, has the given texture, and is scaled to cover the
## circular button area based on the current `button_radius`.
## @param sprite The existing sprite (may be null/invalid).
## @param texture The texture to assign to the sprite.
## @return the existing sprite instance or a new one if it was invalid.
func _ensure_sprite(sprite: Sprite2D, texture: Texture2D) -> Sprite2D:
	if not is_instance_valid(sprite):
		sprite = Sprite2D.new()
		sprite.centered = true
		add_child(sprite)
	
	sprite.texture = texture
	
	# Apply uniform scaling so the sprite fully covers the circular button area.
	var diameter: float = button_radius * 2.0
	if diameter > 0.0:
		var tex: Texture2D = sprite.texture
		if is_instance_valid(tex):
			var tex_size: Vector2 = tex.get_size()
			if tex_size.x > 0.0 and tex_size.y > 0.0:
				var shortest: float = min(tex_size.x, tex_size.y)
				var factor: float = diameter / shortest
				sprite.scale = Vector2(factor, factor)
				sprite.position = Vector2.ZERO
	
	return sprite

