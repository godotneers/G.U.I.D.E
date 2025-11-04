## Comprehensive showcase of the GUIDE hint system capabilities
extends Control

## Demo actions for showcasing different hint types
@export var mapping_context: GUIDEMappingContext
@export var movement_action: GUIDEAction
@export var inventory_action: GUIDEAction
@export var spell_action: GUIDEAction

## UI elements for different examples
@onready var basic_example: RichTextLabel = %BasicExample
@onready var preset_examples: VBoxContainer = %PresetExamples
@onready var custom_example: RichTextLabel = %CustomExample
@onready var animated_example: RichTextLabel = %AnimatedExample

var current_animation_frame = 0
var animation_timer = 0.0
func _ready():
	# Set up basic examples
	GUIDE.enable_mapping_context(mapping_context)
	_setup_basic_example()
	_setup_preset_examples()
	_setup_custom_example()
	_setup_animated_example()


func _setup_basic_example():
	if not movement_action:
		basic_example.text = "Please assign a movement_action in the inspector"
		return

	var formatter = GUIDEInputFormatter.for_active_contexts(60)

	# Basic cross layout - show only first 4 inputs to avoid WASD + joystick conflicts
	var basic_hint = GUIDELayoutHint.cross(35.0) \
		.with_spacing(100) \
		.with_global_offset(Vector2(0, 30)) \
		 .with_max_inputs(4) # Limit to first 4 inputs

	formatter.add_icon_hint(movement_action, basic_hint)

	var icon_text = await formatter.action_as_richtext_async(movement_action)
	basic_example.text = "Move with " + icon_text + " (First 4 inputs)"
	basic_example.bbcode_enabled = true

func _setup_preset_examples():
	var formatter = GUIDEInputFormatter.for_active_contexts(60)

	# Showcase different preset layouts with advanced styling
	var examples = [
		{
			"hint": GUIDELayoutHint.neon_cross().with_first_inputs(4).with_spacing(120),
			"action": movement_action,
			"label": "Neon Cross Style (scaled up):"
		},
		{
			"hint": GUIDELayoutHint.retro_horizontal(50) \
				.with_inputs([0, 1]) \
				.with_global_scale(0.5) \
				.with_global_offset(Vector2(0, 20)),
			"action": spell_action,
			"label": "Retro Horizontal (scaled down):"
		},
		{
			"hint": GUIDELayoutHint.gaming_grid(2, 120) \
				.with_max_inputs(4) \
				 .with_global_scale(1),
			"action": movement_action,
			"label": "Gaming Grid:"
		},
	]

	for example in examples:
		var label = RichTextLabel.new()
		label.bbcode_enabled = true
		label.fit_content = true
		label.scroll_active = false

		formatter.add_icon_hint(example.action, example.hint)
		var icon_text = await formatter.action_as_richtext_async(example.action)

		label.text = example.label + " " + icon_text
		preset_examples.add_child(label)

func _setup_custom_example():
	if not spell_action:
		custom_example.text = "Please assign a spell_action in the inspector"
		return

	var formatter = GUIDEInputFormatter.for_active_contexts(60)

	# Advanced custom styling example
	var custom_positions: Array[Vector2] = [
		Vector2(0, -100), # Top
		Vector2(90, 0), # Right
	]

	var custom_hint = GUIDELayoutHint.custom(custom_positions) \
		.with_input_config(0, 1.0, 0, Vector2.ZERO, Color.GOLD) \
		.with_input_border(0, 3.0, Color.RED) \
		.with_input_config(1, 1.0, 0, Vector2.ZERO, Color.WHITE) \
		.with_input_background(1, Color(0, 0.2, 0.4, 0.7), 12.0) \
		.with_input_border(1, 2.0, Color.BLUE) \
		.with_global_scale(1.2) \
		.with_global_offset(Vector2(-10, 0))

	formatter.add_icon_hint(spell_action, custom_hint)

	var icon_text = await formatter.action_as_richtext_async(spell_action)
	custom_example.text = "Advanced Styling: " + icon_text + " (Custom effects with global scale 1.2x)"
	custom_example.bbcode_enabled = true

## Example of creating hints for different controller types
func create_controller_specific_hint(action: GUIDEAction) -> GUIDEIconHint:
	# This would typically check the active input device
	var active_device = "keyboard" # Placeholder

	match active_device:
		"xbox_controller":
			return GUIDELayoutHint.diamond(40.0).with_global_tint(Color.GREEN)
		"playstation_controller":
			return GUIDELayoutHint.diamond(40.0).with_global_tint(Color.BLUE)
		_:
			return GUIDELayoutHint.cross()

func _setup_animated_example():
	if not movement_action:
		animated_example.text = "Please assign a movement_action in the inspector"
		return

	# This will be updated in _process to show dynamic layouts
	animated_example.text = "Dynamic layouts will cycle here..."
	animated_example.bbcode_enabled = true

func _process(delta):
	if not movement_action:
		return

	animation_timer += delta
	if animation_timer >= 2.0: # Change every 2 seconds
		animation_timer = 0.0
		current_animation_frame = (current_animation_frame + 1) % 4
		_update_animated_example()

func _update_animated_example():
	var formatter = GUIDEInputFormatter.for_active_contexts(44)
	var hint: GUIDEIconHint
	var description: String

	match current_animation_frame:
		0:
			hint = GUIDELayoutHint.cross(100.0).with_global_tint(Color.CYAN).with_global_offset(Vector2(0, 0)).with_max_inputs(4)
			description = "Cross Layout"
		1:
			hint = GUIDELayoutHint.horizontal(100.0).with_global_tint(Color.YELLOW).with_global_offset(Vector2(5, -3)).with_max_inputs(4)
			description = "Horizontal Layout (offset)"
		2:
			hint = GUIDELayoutHint.new().with_input_indices([4])
			description = "Input Pick index"
		3:
			hint = GUIDELayoutHint.grid(2, 100.0).with_global_tint(Color.LIGHT_CORAL).with_global_offset(Vector2(2, -2)).with_max_inputs(4)
			description = "Grid Layout (offset)"

	formatter.add_icon_hint(movement_action, hint)
	var icon_text = await formatter.action_as_richtext_async(movement_action)
	animated_example.text = "Dynamic: " + icon_text + " (" + description + ")"

## Example of accessibility-focused hints
func create_accessibility_hint(action: GUIDEAction, high_contrast: bool, large_icons: bool) -> GUIDEIconHint:
	var spacing = 50.0 if large_icons else 32.0
	var scale = 1.8 if large_icons else 1.0 # Now 1.8 makes it 1.8x larger
	var hint = GUIDELayoutHint.cross(spacing).with_global_scale(scale)

	if high_contrast:
		hint = hint.with_global_tint(Color.WHITE)
		# Could also set high contrast colors for individual inputs
		hint = hint.with_input_config(0, 1.5, 0, Vector2.ZERO, Color.YELLOW)

	return hint

## Example of input selection for different scenarios
func create_input_specific_hint(action: GUIDEAction, scenario: String) -> GUIDEIconHint:
	match scenario:
		"wasd_only":
			# Show only first 4 inputs (typically WASD)
			return GUIDELayoutHint.cross(40.0).with_first_inputs(4)
		"primary_secondary":
			# Show only first 2 inputs
			return GUIDELayoutHint.horizontal(40.0).with_inputs([0, 1])
		"specific_keys":
			# Show specific input indices
			return GUIDELayoutHint.cross(40.0).with_inputs([0, 2, 4]) # 1st, 3rd, 5th inputs
		_:
			return GUIDELayoutHint.cross(40.0).with_max_inputs(4)

## Example of creating highly stylized hints for different moods/themes
func create_themed_hint(action: GUIDEAction, theme: String) -> GUIDEIconHint:
	match theme:
		"cyberpunk":
			return GUIDELayoutHint.cross(40.0) \
				.with_global_tint(Color.CYAN) \
				.with_all_inputs_border(2.0, Color.YELLOW)

		"medieval":
			return GUIDELayoutHint.cross(45.0) \
				.with_global_tint(Color(0.8, 0.7, 0.4)) \
				.with_all_inputs_background(Color(0.3, 0.2, 0.1, 0.8), 8.0) \
				.with_all_inputs_border(2.0, Color(0.6, 0.5, 0.3))

		"space":
			return GUIDELayoutHint.circle(50.0) \
				.with_global_tint(Color(0.7, 0.9, 1.0))

		"horror":
			return GUIDELayoutHint.cross(40.0) \
				.with_global_tint(Color.DARK_RED)

		_:
			return GUIDELayoutHint.cross(40.0).with_preset_style("minimal")
