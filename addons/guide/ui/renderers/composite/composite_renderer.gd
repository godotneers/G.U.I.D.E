@tool
## Renderer for composite icons that combine multiple inputs using hints
class_name GUIDECompositeRenderer
extends GUIDEIconRenderer

var _current_hint: GUIDEIconHint
var _current_action_mapping: GUIDEActionMapping
var _sub_renderers: Array[GUIDEIconRenderer] = []

func _ready():
	super._ready()

func supports(input: GUIDEInput) -> bool:
	# This renderer doesn't support individual inputs directly
	# It's used through the hint system
	return false

func supports_hint(hint: GUIDEIconHint, action_mapping: GUIDEActionMapping) -> bool:
	return hint != null and hint.can_apply_to(action_mapping)

func render_with_hint(hint: GUIDEIconHint, action_mapping: GUIDEActionMapping, available_renderers: Array[GUIDEIconRenderer]) -> void:
	_current_hint = hint
	_current_action_mapping = action_mapping
	_clear_children()

	var layout = hint.get_layout(action_mapping)
	if layout.is_empty():
		push_warning("Composite renderer: hint produced empty layout")
		return

	var min_pos = Vector2(INF, INF)
	var max_pos = Vector2(-INF, -INF)
	var sub_renderer_infos: Array = []

	# Get global configurations
	var global_tint = _get_global_tint_from_hint()
	var global_offset = _get_global_offset_from_hint()
	var global_scale = _get_global_scale_from_hint()

	# First pass: create all sub-renderers and collect size info
	for icon_pos in layout:
		var input = icon_pos.input
		var renderer = _find_renderer_for_input(input, available_renderers)
		if renderer == null:
			push_warning("No renderer found for input: ", input)
			continue

		var sub_renderer = renderer.duplicate()
		add_child(sub_renderer)
		sub_renderer.render(input)
		_sub_renderers.append(sub_renderer)

		# Wait a frame for the renderer to be properly sized
		await get_tree().process_frame

		var renderer_size = sub_renderer.get_rect().size
		if renderer_size == Vector2.ZERO:
			renderer_size = sub_renderer.custom_minimum_size
		if renderer_size == Vector2.ZERO:
			renderer_size = Vector2(32, 32) # Default fallback

		# Apply visual configurations (per-input only)
		_apply_visual_config(sub_renderer, icon_pos)

		# Store info for positioning (don't apply global scale to positions here)
		var info = {
			"renderer": sub_renderer,
			"position": icon_pos.position, # Use original positions
			"scale": icon_pos.scale,
			"rotation": icon_pos.rotation,
			"size": renderer_size
		}
		sub_renderer_infos.append(info)

	# Second pass: calculate bounds for proper sizing
	for info in sub_renderer_infos:
		var pos = info.position
		var scaled_size = info.size * info.scale

		# Calculate the bounds of this renderer
		min_pos.x = min(min_pos.x, pos.x)
		min_pos.y = min(min_pos.y, pos.y)
		max_pos.x = max(max_pos.x, pos.x + scaled_size.x)
		max_pos.y = max(max_pos.y, pos.y + scaled_size.y)

	# Calculate final size
	var final_size = max_pos - min_pos
	if final_size.x <= 0 or final_size.y <= 0:
		final_size = Vector2(64, 64) # Reasonable fallback

	# Third pass: position renderers relative to min_pos
	var offset = Vector2(-min(min_pos.x, 0), -min(min_pos.y, 0))
	for info in sub_renderer_infos:
		var sub_renderer = info.renderer
		sub_renderer.position = info.position + offset
		sub_renderer.scale = Vector2.ONE * info.scale
		sub_renderer.rotation = info.rotation

	# Apply global scale to the entire composite (this makes scale=2.0 double the size)
	if global_scale != 1.0:
		# Apply scale for all sub-renderers
		for info in sub_renderer_infos:
			var sub_renderer = info.renderer
			sub_renderer.scale *= global_scale

	# Apply global tint to the entire composite
	if global_tint != Color.WHITE:
		modulate = global_tint

	# Apply global offset to the entire composite
	if global_offset != Vector2.ZERO:
		position += global_offset

	# Adjust final size if we had to offset
	if offset != Vector2.ZERO:
		final_size += offset

	# Set our size - let icon_maker handle any scaling needed
	custom_minimum_size = final_size
	size = final_size

func _apply_visual_config(sub_renderer: GUIDEIconRenderer, icon_pos: GUIDEIconHint.IconPosition) -> void:
	# Apply basic visual configurations
	if icon_pos.tint != Color.WHITE:
		sub_renderer.modulate = icon_pos.tint

	if icon_pos.opacity < 1.0:
		var current_color = sub_renderer.modulate
		sub_renderer.modulate = Color(current_color.r, current_color.g, current_color.b, current_color.a * icon_pos.opacity)

	if icon_pos.flip_h:
		sub_renderer.scale.x *= -1
	if icon_pos.flip_v:
		sub_renderer.scale.y *= -1

	# Apply advanced styling if available
	_apply_advanced_styling(sub_renderer, icon_pos)

func _apply_advanced_styling(sub_renderer: GUIDEIconRenderer, icon_pos: GUIDEIconHint.IconPosition) -> void:
	# Get the input index to find the corresponding config
	var input_index = -1
	if _current_hint != null:
		var layout = _current_hint.get_layout(_current_action_mapping)
		for i in range(layout.size()):
			if layout[i].input == icon_pos.input:
				input_index = i
				break

	var config: GUIDEIconHint.IconDisplayConfig = null
	if input_index >= 0 and input_index < _current_hint.input_configs.size():
		config = _current_hint.input_configs[input_index]

	if config == null:
		return

	# Apply border effect
	if config.border_width > 0:
		_add_border_effect(sub_renderer, config.border_width, config.border_color)

	# Apply background
	if config.background_enabled:
		_add_background_effect(sub_renderer, config.background_color, config.background_radius)

func _add_border_effect(renderer: GUIDEIconRenderer, width: float, color: Color) -> void:
	var border = NinePatchRect.new()
	border.texture = _create_border_texture(width, color)
	border.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	border.mouse_filter = Control.MOUSE_FILTER_IGNORE
	renderer.add_child(border)
	renderer.move_child(border, 0) # Behind the main content

func _add_background_effect(renderer: GUIDEIconRenderer, color: Color, radius: float) -> void:
	var background = Panel.new()
	var style = StyleBoxFlat.new()
	style.bg_color = color
	style.corner_radius_top_left = radius
	style.corner_radius_top_right = radius
	style.corner_radius_bottom_left = radius
	style.corner_radius_bottom_right = radius
	background.add_theme_stylebox_override("panel", style)
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	renderer.add_child(background)
	renderer.move_child(background, 0) # Behind the main content

func _create_border_texture(width: float, color: Color) -> Texture2D:
	# Create a simple border texture
	var image = Image.create(32, 32, false, Image.FORMAT_RGBA8)
	image.fill(Color.TRANSPARENT)

	# Draw border
	for x in range(32):
		for y in range(32):
			if x < width or x >= 32 - width or y < width or y >= 32 - width:
				image.set_pixel(x, y, color)

	var texture = ImageTexture.new()
	texture.set_image(image)
	return texture

func _find_renderer_for_input(input: GUIDEInput, available_renderers: Array[GUIDEIconRenderer]) -> GUIDEIconRenderer:
	for renderer in available_renderers:
		if renderer != self and renderer.supports(input):
			return renderer
	return null

func _clear_children():
	for child in get_children():
		child.queue_free()
	_sub_renderers.clear()

func cache_key(input: GUIDEInput) -> String:
	if _current_hint != null and _current_action_mapping != null:
		return "composite:" + _current_hint.get_cache_key() + ":mapping:" + _get_mapping_cache_key()
	return "composite:no_hint"

func _get_mapping_cache_key() -> String:
	var key = ""
	if _current_action_mapping != null:
		for input_mapping in _current_action_mapping.input_mappings:
			if input_mapping.input != null:
				key += str(input_mapping.input.get_instance_id()) + ";"
	return key

func render(input: GUIDEInput) -> void:
	# This should not be called directly
	push_warning("CompositeRenderer.render() called directly. Use render_with_hint() instead.")

func _get_global_tint_from_hint() -> Color:
	if _current_hint != null and _current_hint.global_config != null:
		return _current_hint.global_config.tint
	return Color.WHITE

func _get_global_offset_from_hint() -> Vector2:
	if _current_hint != null and _current_hint.global_config != null:
		return _current_hint.global_config.global_offset
	return Vector2.ZERO

func _get_global_scale_from_hint() -> float:
	if _current_hint != null and _current_hint.global_config != null:
		return _current_hint.global_config.global_scale
	return 1.0
