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

	# Basic cross layout - default for WASD/arrow keys (W AND UP ARROW SHOULD BE the FIRST INPUT if not use the configure_input for more control)
	var basic_hint = GUIDELayoutHint.cross(35.0).with_spacing(100)
	formatter.add_icon_hint(movement_action, basic_hint)

	var icon_text = await formatter.action_as_richtext_async(movement_action)
	basic_example.text = "Move with " + icon_text
	basic_example.bbcode_enabled = true

func _setup_preset_examples():

	var formatter = GUIDEInputFormatter.for_active_contexts(40)

	# Showcase different preset layouts
	var examples = [
		{
			"hint": GUIDELayoutHint.compact_cross(),
			"action": movement_action,
			"label": "Compact Cross:"
		},
		{
			"hint": GUIDELayoutHint.horizontal(100),
			"action": spell_action,
			"label": "Spaced Horizontal:"
		},
		{
			"hint": GUIDELayoutHint.grid_3x(),
			"action": movement_action,
			"label": "3-Column Grid:"
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

	# Custom diamond arrangement with unique styling
	var custom_positions: Array[Vector2] = [
		Vector2(0, -80), # Top
		Vector2(90, 0), # Left
	]

	var custom_hint = GUIDELayoutHint.custom(custom_positions) \
		.with_input_config(0, 1.0, 0, Vector2.ZERO, Color.GOLD) \
		.with_input_config(1, 1.0, 0, Vector2.ZERO, Color.GOLD)

	formatter.add_icon_hint(spell_action, custom_hint)

	var icon_text = await formatter.action_as_richtext_async(spell_action)
	custom_example.text = "Spell Casting: " + icon_text + " (Custom positions)"
	custom_example.bbcode_enabled = true

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
			hint = GUIDELayoutHint.cross(100.0).with_global_tint(Color.CYAN)
			description = "Cross Layout"
		1:
			hint = GUIDELayoutHint.horizontal(100.0).with_global_tint(Color.YELLOW)
			description = "Horizontal Layout"
		2:
			hint = GUIDELayoutHint.circle(100.0).with_global_tint(Color.LIGHT_GREEN)
			description = "Circle Layout"
		3:
			hint = GUIDELayoutHint.grid(2, 100.0).with_global_tint(Color.LIGHT_CORAL)
			description = "Grid Layout"

	formatter.add_icon_hint(movement_action, hint)
	var icon_text = await formatter.action_as_richtext_async(movement_action)
	animated_example.text = "Dynamic: " + icon_text + " (" + description + ")"

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

## Example of accessibility-focused hints
func create_accessibility_hint(action: GUIDEAction, high_contrast: bool, large_icons: bool) -> GUIDEIconHint:
	var spacing = 50.0 if large_icons else 32.0
	var hint = GUIDELayoutHint.cross(spacing)

	if high_contrast:
		hint = hint.with_global_tint(Color.WHITE)
		# Could also set high contrast colors for individual inputs
		hint = hint.with_input_config(0, 1.5, 0, Vector2.ZERO, Color.YELLOW)

	return hint
