@tool
## Renderer for composite icons that combine multiple inputs using hints
class_name GUIDECompositeRenderer
extends GUIDEIconRenderer

var _current_hint: GUIDEIconHint
var _current_action_mapping: GUIDEActionMapping
var _sub_renderers: Array[GUIDEIconRenderer] = []

func _ready():
	super._ready()
	priority = -10 # Higher priority than individual renderers

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
	var typical_icon_size = Vector2(32, 32) # Default assumption

	# Get global tint
	var global_tint = _get_global_tint_from_hint()

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
			renderer_size = typical_icon_size
		else:
			# Update our understanding of typical icon size
			typical_icon_size = renderer_size

		# Apply visual configurations (per-input only)
		_apply_visual_config(sub_renderer, icon_pos)

		# Store info for second pass
		var info = {
			"renderer": sub_renderer,
			"position": icon_pos.position,
			"scale": icon_pos.scale,
			"rotation": icon_pos.rotation,
			"size": renderer_size
		}
		sub_renderer_infos.append(info)

	# Validate spacing against icon sizes to prevent viewport overflow
	if hint is GUIDELayoutHint:
		var layout_hint = hint as GUIDELayoutHint
		var max_safe_spacing = _calculate_max_safe_spacing(typical_icon_size, sub_renderer_infos.size())
		if layout_hint.spacing > max_safe_spacing:
			push_warning("Spacing ", layout_hint.spacing, " too large for icon size ", typical_icon_size, ". Max safe: ", max_safe_spacing)

	# Second pass: calculate bounds properly
	for info in sub_renderer_infos:
		var pos = info.position
		var scaled_size = info.size * info.scale

		# Calculate the bounds of this renderer
		min_pos.x = min(min_pos.x, pos.x)
		min_pos.y = min(min_pos.y, pos.y)
		max_pos.x = max(max_pos.x, pos.x + scaled_size.x)
		max_pos.y = max(max_pos.y, pos.y + scaled_size.y)

	# Calculate final size with safety limits
	var final_size = max_pos - min_pos
	if final_size.x <= 0 or final_size.y <= 0:
		final_size = typical_icon_size

	# Apply reasonable limits to prevent viewport issues
	var max_total_size = Vector2(1500, 1500) # Reduced from 2048 for safety
	final_size.x = min(final_size.x, max_total_size.x)
	final_size.y = min(final_size.y, max_total_size.y)

	# If size is still too large, scale down all positions
	if final_size.x > max_total_size.x or final_size.y > max_total_size.y:
		var scale_factor = min(max_total_size.x / final_size.x, max_total_size.y / final_size.y)
		for info in sub_renderer_infos:
			info.position *= scale_factor
		final_size *= scale_factor
		print("Scaled down composite layout by factor: ", scale_factor)

	# Third pass: position renderers
	var offset = Vector2(-min(min_pos.x, 0), -min(min_pos.y, 0))
	for info in sub_renderer_infos:
		var sub_renderer = info.renderer
		sub_renderer.position = info.position + offset
		sub_renderer.scale = Vector2.ONE * info.scale
		sub_renderer.rotation = info.rotation

	# Apply global tint to the entire composite
	if global_tint != Color.WHITE:
		modulate = global_tint

	# Adjust final size if we had to offset
	if offset != Vector2.ZERO:
		final_size += offset

	# Set our size
	custom_minimum_size = final_size
	size = final_size

	print("Final composite size: ", final_size)

func _apply_visual_config(sub_renderer: GUIDEIconRenderer, icon_pos: GUIDEIconHint.IconPosition) -> void:
	# Apply tint
	if icon_pos.tint != Color.WHITE:
		sub_renderer.modulate = icon_pos.tint

	# Apply opacity
	if icon_pos.opacity < 1.0:
		var current_color = sub_renderer.modulate
		sub_renderer.modulate = Color(current_color.r, current_color.g, current_color.b, current_color.a * icon_pos.opacity)

	# Apply flipping
	if icon_pos.flip_h:
		sub_renderer.scale.x *= -1
	if icon_pos.flip_v:
		sub_renderer.scale.y *= -1

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

func _calculate_max_safe_spacing(icon_size: Vector2, icon_count: int) -> float:
	# Calculate safe spacing based on icon size and count to prevent viewport overflow
	var max_viewport_size = 1200.0 # Conservative limit
	var estimated_layout_dimension = sqrt(icon_count) * 2 # Rough estimate of layout spread
	var max_safe = (max_viewport_size - icon_size.x * estimated_layout_dimension) / estimated_layout_dimension
	return max(16.0, min(max_safe, 200.0)) # Clamp between reasonable bounds

func _get_global_tint_from_hint() -> Color:
	if _current_hint != null and _current_hint.global_config != null:
		return _current_hint.global_config.tint
	return Color.WHITE
