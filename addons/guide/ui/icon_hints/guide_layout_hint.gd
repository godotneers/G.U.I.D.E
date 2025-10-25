@tool
## Generic layout hint that can arrange inputs in various patterns with customizable positioning
class_name GUIDELayoutHint
extends GUIDEIconHint

enum LayoutPattern {
	CROSS, ## Cross/Plus pattern: center with arms
	GRID, ## Grid pattern: rows and columns
	HORIZONTAL, ## Horizontal line
	VERTICAL, ## Vertical line
	CIRCLE, ## Circular arrangement
	DIAMOND, ## Diamond pattern
	CUSTOM ## Custom positions array
}

@export var pattern: LayoutPattern = LayoutPattern.CROSS
@export var spacing: float = 32.0:
	set(value):
		# Limit spacing to prevent viewport issues (based on typical icon size of 32px)
		spacing = clamp(value, 8.0, 500.0)
@export var grid_columns: int = 2:
	set(value):
		grid_columns = max(1, value)
@export var circle_radius: float = 64.0:
	set(value):
		circle_radius = clamp(value, 32.0, 300.0)
@export var custom_positions: Array[Vector2] = []
@export var center_first_input: bool = true ## For patterns like cross, put first input at center
@export var sort_inputs_by_type: bool = true ## Group keyboard inputs together, etc.

func get_layout(action_mapping: GUIDEActionMapping) -> Array:
	var layout: Array[GUIDEIconHint.IconPosition] = []

	if action_mapping == null or action_mapping.input_mappings.is_empty():
		return layout

	# Extract inputs from the action mapping
	var inputs: Array[GUIDEInput] = []
	for input_mapping in action_mapping.input_mappings:
		if input_mapping.input != null:
			inputs.append(input_mapping.input)

	if inputs.is_empty():
		return layout

	# Apply input selection
	inputs = _select_inputs(inputs)

	if inputs.is_empty():
		return layout

	# Sort inputs if requested
	if sort_inputs_by_type:
		inputs = _sort_inputs_by_type(inputs)

	# Create layout based on pattern
	match pattern:
		LayoutPattern.CROSS:
			layout = _create_cross_layout(inputs)
		LayoutPattern.GRID:
			layout = _create_grid_layout(inputs)
		LayoutPattern.HORIZONTAL:
			layout = _create_horizontal_layout(inputs)
		LayoutPattern.VERTICAL:
			layout = _create_vertical_layout(inputs)
		LayoutPattern.CIRCLE:
			layout = _create_circle_layout(inputs)
		LayoutPattern.DIAMOND:
			layout = _create_diamond_layout(inputs)
		LayoutPattern.CUSTOM:
			layout = _create_custom_layout(inputs)

	# Apply configurations to each position
	for i in range(layout.size()):
		_apply_config_to_position(layout[i], i)

	return layout

func _sort_inputs_by_type(inputs: Array[GUIDEInput]) -> Array[GUIDEInput]:
	var sorted_inputs: Array[GUIDEInput] = []
	var keyboard_inputs: Array[GUIDEInput] = []
	var mouse_inputs: Array[GUIDEInput] = []
	var controller_inputs: Array[GUIDEInput] = []
	var other_inputs: Array[GUIDEInput] = []

	for input in inputs:
		if input is GUIDEInputKey:
			keyboard_inputs.append(input)
		elif input is GUIDEInputMouseButton or input is GUIDEInputMouseAxis1D:
			mouse_inputs.append(input)
		elif "Joy" in input.get_class():
			controller_inputs.append(input)
		else:
			other_inputs.append(input)

	# Add in priority order: keyboard, mouse, controller, others
	sorted_inputs.append_array(keyboard_inputs)
	sorted_inputs.append_array(mouse_inputs)
	sorted_inputs.append_array(controller_inputs)
	sorted_inputs.append_array(other_inputs)

	return sorted_inputs

func _create_cross_layout(inputs: Array[GUIDEInput]) -> Array[GUIDEIconHint.IconPosition]:
	var layout: Array[GUIDEIconHint.IconPosition] = []

	if inputs.is_empty():
		return layout

	match inputs.size():
		1:
			layout.append(GUIDEIconHint.IconPosition.new(inputs[0], Vector2.ZERO))
		2:
			if center_first_input:
				layout.append(GUIDEIconHint.IconPosition.new(inputs[0], Vector2.ZERO))
				layout.append(GUIDEIconHint.IconPosition.new(inputs[1], Vector2(spacing, 0)))
			else:
				layout.append(GUIDEIconHint.IconPosition.new(inputs[0], Vector2(-spacing * 0.5, 0)))
				layout.append(GUIDEIconHint.IconPosition.new(inputs[1], Vector2(spacing * 0.5, 0)))
		3:
			if center_first_input:
				layout.append(GUIDEIconHint.IconPosition.new(inputs[0], Vector2.ZERO))
				layout.append(GUIDEIconHint.IconPosition.new(inputs[1], Vector2(0, -spacing))) # top
				layout.append(GUIDEIconHint.IconPosition.new(inputs[2], Vector2(spacing, 0))) # right
			else:
				layout.append(GUIDEIconHint.IconPosition.new(inputs[0], Vector2(0, -spacing))) # top
				layout.append(GUIDEIconHint.IconPosition.new(inputs[1], Vector2(-spacing, 0))) # left
				layout.append(GUIDEIconHint.IconPosition.new(inputs[2], Vector2(spacing, 0))) # right
		4:
			if center_first_input:
				layout.append(GUIDEIconHint.IconPosition.new(inputs[0], Vector2.ZERO)) # center
				layout.append(GUIDEIconHint.IconPosition.new(inputs[1], Vector2(0, -spacing))) # top
				layout.append(GUIDEIconHint.IconPosition.new(inputs[2], Vector2(-spacing, 0))) # left
				layout.append(GUIDEIconHint.IconPosition.new(inputs[3], Vector2(spacing, 0))) # right
			else:
				layout.append(GUIDEIconHint.IconPosition.new(inputs[0], Vector2(0, -spacing))) # top
				layout.append(GUIDEIconHint.IconPosition.new(inputs[1], Vector2(-spacing, 0))) # left
				layout.append(GUIDEIconHint.IconPosition.new(inputs[2], Vector2(0, spacing))) # bottom
				layout.append(GUIDEIconHint.IconPosition.new(inputs[3], Vector2(spacing, 0))) # right
		_:
			# 5+ inputs: center + 4 directions + extras in a second ring
			if center_first_input:
				layout.append(GUIDEIconHint.IconPosition.new(inputs[0], Vector2.ZERO))
			layout.append(GUIDEIconHint.IconPosition.new(inputs[1], Vector2(0, -spacing))) # top
			layout.append(GUIDEIconHint.IconPosition.new(inputs[2], Vector2(-spacing, 0))) # left
			layout.append(GUIDEIconHint.IconPosition.new(inputs[3], Vector2(0, spacing))) # bottom
			layout.append(GUIDEIconHint.IconPosition.new(inputs[4], Vector2(spacing, 0))) # right

			# Additional inputs in outer ring
			var start_idx = 5
			var outer_spacing = spacing * 1.5
			for i in range(start_idx, inputs.size()):
				var angle = (i - start_idx) * PI * 2.0 / max(1, inputs.size() - start_idx)
				var pos = Vector2(cos(angle), sin(angle)) * outer_spacing
				layout.append(GUIDEIconHint.IconPosition.new(inputs[i], pos))

	return layout

func _create_grid_layout(inputs: Array[GUIDEInput]) -> Array[GUIDEIconHint.IconPosition]:
	var layout: Array[GUIDEIconHint.IconPosition] = []

	for i in range(inputs.size()):
		var row = i / grid_columns
		var col = i % grid_columns
		var pos = Vector2(col * spacing, row * spacing)
		layout.append(GUIDEIconHint.IconPosition.new(inputs[i], pos))

	return layout

func _create_horizontal_layout(inputs: Array[GUIDEInput]) -> Array[GUIDEIconHint.IconPosition]:
	var layout: Array[GUIDEIconHint.IconPosition] = []

	for i in range(inputs.size()):
		var pos = Vector2(i * spacing, 0)
		layout.append(GUIDEIconHint.IconPosition.new(inputs[i], pos))

	return layout

func _create_vertical_layout(inputs: Array[GUIDEInput]) -> Array[GUIDEIconHint.IconPosition]:
	var layout: Array[GUIDEIconHint.IconPosition] = []

	for i in range(inputs.size()):
		var pos = Vector2(0, i * spacing)
		layout.append(GUIDEIconHint.IconPosition.new(inputs[i], pos))

	return layout

func _create_circle_layout(inputs: Array[GUIDEInput]) -> Array[GUIDEIconHint.IconPosition]:
	var layout: Array[GUIDEIconHint.IconPosition] = []

	if inputs.size() == 1:
		layout.append(GUIDEIconHint.IconPosition.new(inputs[0], Vector2.ZERO))
		return layout

	for i in range(inputs.size()):
		var angle = i * PI * 2.0 / inputs.size()
		var pos = Vector2(cos(angle), sin(angle)) * circle_radius
		layout.append(GUIDEIconHint.IconPosition.new(inputs[i], pos))

	return layout

func _create_diamond_layout(inputs: Array[GUIDEInput]) -> Array[GUIDEIconHint.IconPosition]:
	var layout: Array[GUIDEIconHint.IconPosition] = []

	match inputs.size():
		1:
			layout.append(GUIDEIconHint.IconPosition.new(inputs[0], Vector2.ZERO))
		2:
			layout.append(GUIDEIconHint.IconPosition.new(inputs[0], Vector2(-spacing * 0.5, 0)))
			layout.append(GUIDEIconHint.IconPosition.new(inputs[1], Vector2(spacing * 0.5, 0)))
		3:
			layout.append(GUIDEIconHint.IconPosition.new(inputs[0], Vector2(0, -spacing))) # top
			layout.append(GUIDEIconHint.IconPosition.new(inputs[1], Vector2(-spacing, 0))) # left
			layout.append(GUIDEIconHint.IconPosition.new(inputs[2], Vector2(spacing, 0))) # right
		4:
			layout.append(GUIDEIconHint.IconPosition.new(inputs[0], Vector2(0, -spacing))) # top
			layout.append(GUIDEIconHint.IconPosition.new(inputs[1], Vector2(-spacing, 0))) # left
			layout.append(GUIDEIconHint.IconPosition.new(inputs[2], Vector2(spacing, 0))) # right
			layout.append(GUIDEIconHint.IconPosition.new(inputs[3], Vector2(0, spacing))) # bottom
		_:
			# More than 4: create concentric diamonds
			var positions = [
				Vector2(0, -spacing), # top
				Vector2(-spacing, 0), # left
				Vector2(spacing, 0), # right
				Vector2(0, spacing), # bottom
			]

			for i in range(inputs.size()):
				if i < 4:
					layout.append(GUIDEIconHint.IconPosition.new(inputs[i], positions[i]))
				else:
					# Outer diamond
					var outer_idx = (i - 4) % 4
					var outer_spacing = spacing * 1.8
					var outer_positions = [
						Vector2(0, -outer_spacing),
						Vector2(-outer_spacing, 0),
						Vector2(outer_spacing, 0),
						Vector2(0, outer_spacing),
					]
					layout.append(GUIDEIconHint.IconPosition.new(inputs[i], outer_positions[outer_idx]))

	return layout

func _create_custom_layout(inputs: Array[GUIDEInput]) -> Array[GUIDEIconHint.IconPosition]:
	var layout: Array[GUIDEIconHint.IconPosition] = []

	for i in range(min(inputs.size(), custom_positions.size())):
		layout.append(GUIDEIconHint.IconPosition.new(inputs[i], custom_positions[i]))

	return layout

func can_apply_to(action_mapping: GUIDEActionMapping) -> bool:
	return super.can_apply_to(action_mapping)

func _get_additional_cache_data() -> String:
	var data = str(pattern) + ":" + str(spacing) + ":" + str(grid_columns) + ":" + str(circle_radius) + ":"
	data += str(center_first_input) + ":" + str(sort_inputs_by_type) + ":"
	data += str(max_inputs) + ":"
	for index in input_indices:
		data += str(index) + ","
	for pos in custom_positions:
		data += str(pos.x) + "," + str(pos.y) + ";"
	return data

## Convenience method to set global rotation for the entire composite icon
func set_global_rotation(rotation_degrees: float) -> void:
	if global_config == null:
		global_config = GUIDEIconHint.IconDisplayConfig.new()
	global_config.rotation = deg_to_rad(rotation_degrees)

## Convenience method to set global tint for the entire composite icon
func set_global_tint(color: Color) -> void:
	if global_config == null:
		global_config = GUIDEIconHint.IconDisplayConfig.new()
	global_config.tint = color

## Convenience method to set global offset for the entire composite icon
func set_global_offset(offset: Vector2) -> void:
	if global_config == null:
		global_config = GUIDEIconHint.IconDisplayConfig.new()
	global_config.global_offset = offset

## Convenience method to set global scale for the entire composite icon
func set_global_scale(scale_multiplier: float) -> void:
	if global_config == null:
		global_config = GUIDEIconHint.IconDisplayConfig.new()
	global_config.global_scale = clamp(scale_multiplier, 0.1, 5.0)

## Convenience method to configure a specific input by index
## This affects only the individual icon, not the whole composite
func configure_input(index: int, scale: float = 1.0, rotation_degrees: float = 0.0, offset: Vector2 = Vector2.ZERO, tint: Color = Color.WHITE) -> void:
	# Ensure we have enough slots in the array
	while input_configs.size() <= index:
		input_configs.append(null)

	if input_configs[index] == null:
		input_configs[index] = GUIDEIconHint.IconDisplayConfig.new()

	var config = input_configs[index]
	config.scale = scale
	config.rotation = deg_to_rad(rotation_degrees)
	config.offset = offset
	config.tint = tint

## Builder pattern methods for easier configuration

## Sets the layout pattern and returns self for chaining
func with_pattern(p: LayoutPattern) -> GUIDELayoutHint:
	pattern = p
	return self

## Sets the maximum number of inputs to show and returns self for chaining
func with_max_inputs(n: int) -> GUIDELayoutHint:
	max_inputs = n
	return self

## Sets the spacing and returns self for chaining
func with_spacing(s: float) -> GUIDELayoutHint:
	spacing = s
	return self

## Sets whether to center the first input and returns self for chaining
func with_center_first(center: bool) -> GUIDELayoutHint:
	center_first_input = center
	return self

## Sets whether to sort inputs by type and returns self for chaining
func with_input_sorting(sort: bool) -> GUIDELayoutHint:
	sort_inputs_by_type = sort
	return self

## Sets grid columns (for grid pattern) and returns self for chaining
func with_grid_columns(columns: int) -> GUIDELayoutHint:
	grid_columns = columns
	return self

## Sets circle radius (for circle pattern) and returns self for chaining
func with_circle_radius(radius: float) -> GUIDELayoutHint:
	circle_radius = radius
	return self

## Sets custom positions (for custom pattern) and returns self for chaining
func with_custom_positions(positions: Array[Vector2]) -> GUIDELayoutHint:
	custom_positions = positions
	return self

## Sets global tint and returns self for chaining
func with_global_tint(color: Color) -> GUIDELayoutHint:
	set_global_tint(color)
	return self

## Sets global rotation and returns self for chaining
func with_global_rotation(degrees: float) -> GUIDELayoutHint:
	set_global_rotation(degrees)
	return self

## Sets global offset and returns self for chaining
func with_global_offset(offset: Vector2) -> GUIDELayoutHint:
	set_global_offset(offset)
	return self

## Sets global scale and returns self for chaining
func with_global_scale(scale_multiplier: float) -> GUIDELayoutHint:
	set_global_scale(scale_multiplier)
	return self

## Configures a specific input and returns self for chaining
func with_input_config(index: int, scale: float = 1.0, rotation_degrees: float = 0.0, offset: Vector2 = Vector2.ZERO, tint: Color = Color.WHITE) -> GUIDELayoutHint:
	configure_input(index, scale, rotation_degrees, offset, tint)
	return self

## Sets specific input indices to include and returns self for chaining
func with_input_indices(indices: Array[int]) -> GUIDELayoutHint:
	input_indices = indices
	return self

## Sets first N inputs only and returns self for chaining
func with_first_inputs(count: int) -> GUIDELayoutHint:
	max_inputs = count
	input_indices = []
	return self

## Convenience method: Show only the first input
func with_first_input_only() -> GUIDELayoutHint:
	return with_input_indices([0])

## Convenience method: Show only specific inputs by index
func with_inputs(indices: Array[int]) -> GUIDELayoutHint:
	return with_input_indices(indices)

## Convenience method: Creates a horizontal layout with specified spacing
static func horizontal(spacing: float = 32.0) -> GUIDELayoutHint:
	return GUIDELayoutHint.new().with_pattern(LayoutPattern.HORIZONTAL).with_spacing(spacing)

## Convenience method: Creates a vertical layout with specified spacing
static func vertical(spacing: float = 32.0) -> GUIDELayoutHint:
	return GUIDELayoutHint.new().with_pattern(LayoutPattern.VERTICAL).with_spacing(spacing)

## Convenience method: Creates a cross layout with specified spacing
static func cross(spacing: float = 32.0, center_first: bool = true) -> GUIDELayoutHint:
	return GUIDELayoutHint.new().with_pattern(LayoutPattern.CROSS).with_spacing(spacing).with_center_first(center_first)

## Convenience method: Creates a grid layout with specified columns and spacing
static func grid(columns: int = 2, spacing: float = 32.0) -> GUIDELayoutHint:
	return GUIDELayoutHint.new().with_pattern(LayoutPattern.GRID).with_grid_columns(columns).with_spacing(spacing)

## Convenience method: Creates a circle layout with specified radius
static func circle(radius: float = 64.0) -> GUIDELayoutHint:
	return GUIDELayoutHint.new().with_pattern(LayoutPattern.CIRCLE).with_circle_radius(radius)

## Convenience method: Creates a diamond layout with specified spacing
static func diamond(spacing: float = 32.0) -> GUIDELayoutHint:
	return GUIDELayoutHint.new().with_pattern(LayoutPattern.DIAMOND).with_spacing(spacing)

## Convenience method: Creates a custom layout with specified positions
static func custom(positions: Array[Vector2]) -> GUIDELayoutHint:
	return GUIDELayoutHint.new().with_pattern(LayoutPattern.CUSTOM).with_custom_positions(positions)

## Common presets with sensible defaults

## Creates a compact cross layout (smaller spacing)
static func compact_cross() -> GUIDELayoutHint:
	return cross(80.0)

## Creates a spacious cross layout (larger spacing)
static func spacious_cross() -> GUIDELayoutHint:
	return cross(50.0)

## Creates a tight horizontal row
static func tight_horizontal() -> GUIDELayoutHint:
	return horizontal(24.0)

## Creates a spaced horizontal row
static func spaced_horizontal() -> GUIDELayoutHint:
	return horizontal(48.0)

## Creates a 3-column grid
static func grid_3x() -> GUIDELayoutHint:
	return grid(3, 100.0)

## Creates a 4-column grid
static func grid_4x() -> GUIDELayoutHint:
	return grid(4, 24.0)

## Creates a small circle arrangement
static func small_circle() -> GUIDELayoutHint:
	return circle(40.0)

## Creates a large circle arrangement
static func large_circle() -> GUIDELayoutHint:
	return circle(80.0)

## Advanced styling methods for individual inputs

## Adds border to a specific input
func with_input_border(index: int, width: float, color: Color = Color.WHITE) -> GUIDELayoutHint:
	_ensure_input_config(index)
	input_configs[index].border_width = width
	input_configs[index].border_color = color
	return self

## Adds background to a specific input
func with_input_background(index: int, color: Color = Color(0, 0, 0, 0.3), radius: float = 8.0) -> GUIDELayoutHint:
	_ensure_input_config(index)
	input_configs[index].background_enabled = true
	input_configs[index].background_color = color
	input_configs[index].background_radius = radius
	return self

## Convenience method to apply a preset style to all inputs
func with_preset_style(style_name: String) -> GUIDELayoutHint:
	match style_name:
		"neon":
			return _apply_neon_style()
		"retro":
			return _apply_retro_style()
		"minimal":
			return _apply_minimal_style()
		"gaming":
			return _apply_gaming_style()
		"elegant":
			return _apply_elegant_style()
		_:
			push_warning("Unknown preset style: " + style_name)
			return self

## Applies effects to all inputs in the layout
func with_all_inputs_border(width: float, color: Color = Color.WHITE) -> GUIDELayoutHint:
	for i in range(max(4, input_configs.size())):
		with_input_border(i, width, color)
	return self

func with_all_inputs_background(color: Color = Color(0, 0, 0, 0.3), radius: float = 8.0) -> GUIDELayoutHint:
	for i in range(input_configs.size()):
		with_input_background(i, color, radius)
	return self

## Helper method to ensure input config exists
func _ensure_input_config(index: int) -> void:
	while input_configs.size() <= index:
		input_configs.append(null)

	if input_configs[index] == null:
		input_configs[index] = GUIDEIconHint.IconDisplayConfig.new()

## Preset style implementations
func _apply_neon_style() -> GUIDELayoutHint:
	return with_global_tint(Color.CYAN) \
			.with_global_scale(1.2) \
			.with_all_inputs_border(2.0, Color.RED)

func _apply_retro_style() -> GUIDELayoutHint:
	return with_global_tint(Color.ORANGE) \
			.with_global_scale(1.1) \
			.with_all_inputs_background(Color(0.2, 0.1, 0.0, 0.8), 4.0) \
			.with_all_inputs_border(1.0, Color.YELLOW)

func _apply_minimal_style() -> GUIDELayoutHint:
	return with_global_tint(Color(0.9, 0.9, 0.9)) \
			.with_global_scale(0.9) \
			.with_all_inputs_background(Color(0, 0, 0, 0.1), 12.0)

func _apply_gaming_style() -> GUIDELayoutHint:
	return with_global_tint(Color.LIME_GREEN) \
			.with_global_scale(1.3) \
			.with_all_inputs_border(3.0, Color.GREEN)

func _apply_elegant_style() -> GUIDELayoutHint:
	return with_global_tint(Color(0.95, 0.95, 1.0)) \
			.with_global_scale(1.1) \
			.with_all_inputs_background(Color(0.1, 0.1, 0.2, 0.6), 16.0) \
			.with_all_inputs_border(1.0, Color(0.8, 0.8, 1.0))

## New preset methods with built-in styling

## Creates a neon-styled cross layout
static func neon_cross(spacing: float = 32.0) -> GUIDELayoutHint:
	return cross(spacing).with_preset_style("neon")

## Creates a retro-styled horizontal layout
static func retro_horizontal(spacing: float = 32.0) -> GUIDELayoutHint:
	return horizontal(spacing).with_preset_style("retro")

## Creates a gaming-styled grid
static func gaming_grid(columns: int = 2, spacing: float = 32.0) -> GUIDELayoutHint:
	return grid(columns, spacing).with_preset_style("gaming")

## Creates an elegant circle layout
static func elegant_circle(radius: float = 64.0) -> GUIDELayoutHint:
	return circle(radius).with_preset_style("elegant")
