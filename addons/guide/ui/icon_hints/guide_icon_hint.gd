@tool
## Base class for icon composition hints that control how multiple inputs are arranged in a single icon.
class_name GUIDEIconHint
extends Resource

## Global configuration applied to all inputs in this hint
@export var global_config: IconDisplayConfig

## Per-input configurations - maps input index to IconDisplayConfig
@export var input_configs: Array[IconDisplayConfig] = []

## Returns a unique cache key for this hint configuration
func get_cache_key() -> String:
	var key = get_script().resource_path + ":"
	if global_config != null:
		key += global_config.get_cache_key() + ":"
	for config in input_configs:
		if config != null:
			key += config.get_cache_key() + ";"
	return key + _get_additional_cache_data()

## Override this to add additional cache data specific to the hint type
func _get_additional_cache_data() -> String:
	return ""

## Returns the layout information for positioning the inputs
## Should return Array[IconPosition] where IconPosition has properties: input, position, scale
## The action_mapping parameter contains the resolved inputs for the action
func get_layout(action_mapping: GUIDEActionMapping) -> Array:
	push_error("Subclasses must implement get_layout()")
	return []

## Returns whether this hint can be applied to the given action mapping
func can_apply_to(action_mapping: GUIDEActionMapping) -> bool:
	return action_mapping != null and action_mapping.input_mappings.size() > 0

## Helper method to apply configurations to an IconPosition
func _apply_config_to_position(position: IconPosition, input_index: int) -> void:
	# Only apply per-input configurations here
	# Global configurations that affect the whole composite (like global scale)
	# are handled at the composite renderer level
	if input_index < input_configs.size() and input_configs[input_index] != null:
		var config = input_configs[input_index]
		position.scale *= config.scale
		position.rotation += config.rotation
		position.position += config.offset
		position.tint = config.tint
		position.opacity = config.opacity
		position.flip_h = config.flip_h
		position.flip_v = config.flip_v

class IconPosition:
	var input: GUIDEInput
	var position: Vector2
	var scale: float = 1.0
	var rotation: float = 0.0
	var tint: Color = Color.WHITE
	var opacity: float = 1.0
	var flip_h: bool = false
	var flip_v: bool = false

	func _init(p_input: GUIDEInput, p_position: Vector2, p_scale: float = 1.0, p_rotation: float = 0.0):
		input = p_input
		position = p_position
		scale = p_scale
		rotation = p_rotation

class IconDisplayConfig:
	extends Resource

	## Scale multiplier for the individual icon (not global)
	@export var scale: float = 1.0
	## Rotation in radians
	@export var rotation: float = 0.0
	## Position offset
	@export var offset: Vector2 = Vector2.ZERO
	## Global offset for the entire composite (only used in global_config)
	@export var global_offset: Vector2 = Vector2.ZERO
	## Tint color
	@export var tint: Color = Color.WHITE
	## Opacity (0.0 to 1.0)
	@export_range(0.0, 1.0) var opacity: float = 1.0
	## Whether to flip horizontally
	@export var flip_h: bool = false
	## Whether to flip vertically
	@export var flip_v: bool = false

	func get_cache_key() -> String:
		var key = str(scale) + ":" + str(rotation) + ":" + str(offset.x) + "," + str(offset.y)
		key += ":" + str(global_offset.x) + "," + str(global_offset.y)
		key += ":" + str(tint.r) + "," + str(tint.g) + "," + str(tint.b) + "," + str(tint.a)
		key += ":" + str(opacity) + ":" + str(flip_h) + ":" + str(flip_v)
		return key
