## The remapping dialog. 
extends MarginContainer

signal closed(applied_config:GUIDERemappingConfig)

const Utils = preload("../utils.gd")

# Input
@export var keyboard_context:GUIDEMappingContext
@export var controller_context:GUIDEMappingContext
@export var binding_keyboard_context:GUIDEMappingContext
@export var binding_controller_context:GUIDEMappingContext
@export var close_dialog:GUIDEAction
@export var switch_to_controller:GUIDEAction
@export var switch_to_keyboard:GUIDEAction
@export var previous_tab:GUIDEAction
@export var next_tab:GUIDEAction

# UI 
@export var binding_row_scene:PackedScene
@export var binding_section_scene:PackedScene

@onready var _keyboard_bindings:Container = %KeyboardBindings
@onready var _controller_bindings:Container = %ControllerBindings
@onready var _press_prompt:Control = %PressPrompt
@onready var _controller_invert_horizontal:CheckBox = %ControllerInvertHorizontal
@onready var _controller_invert_vertical:CheckBox = %ControllerInvertVertical
@onready var _tab_container:TabContainer = %TabContainer

## The input detector for detecting new input
@onready var _input_detector:GUIDEInputDetector = %GUIDEInputDetector

## The remapper, helps us quickly remap inputs.
var _remapper:GUIDERemapper = GUIDERemapper.new()

## The config we're currently working on
var _remapping_config:GUIDERemappingConfig

## The last control that was focused when we started input detection.
## Used to restore focus afterwards.
var _focused_control:Control = null

func _ready() -> void:
	# connect the actions that the remapping dialog uses
	close_dialog.triggered.connect(_on_close_dialog)
	switch_to_controller.triggered.connect(_switch.bind(binding_controller_context))
	switch_to_keyboard.triggered.connect(_switch.bind(binding_keyboard_context))
	previous_tab.triggered.connect(_switch_tab.bind(-1))
	next_tab.triggered.connect(_switch_tab.bind(1))
	

func open() -> void:
	# switch the tab to the scheme that is currently enabled
	# to make life a bit easier for the player, and also
	# enable the correct mapping context for the binding dialog
	if GUIDE.is_mapping_context_enabled(controller_context):
		_tab_container.current_tab = 1
		GUIDE.enable_mapping_context(binding_controller_context, true)
	else:
		_tab_container.current_tab = 0
		GUIDE.enable_mapping_context(binding_keyboard_context, true)
		
	# todo provide specific actions for the tab bar controller
	_tab_container.get_tab_bar().grab_focus()
	
	# Open the user's last edited remapping config, if it exists
	_remapping_config = Utils.load_remapping_config()
	
	# And initialize the remapper
	_remapper.initialize([keyboard_context, controller_context], _remapping_config)
	
	_clear(_keyboard_bindings)
	_clear(_controller_bindings)
	
	# fill the keyboard section
	_fill_remappable_items(keyboard_context, _keyboard_bindings)
	
	# fill the controller section
	_fill_remappable_items(controller_context, _controller_bindings)
	
	_controller_invert_horizontal.button_pressed = _remapper.get_custom_data("invert_horizontal", false)
	_controller_invert_vertical.button_pressed = _remapper.get_custom_data("invert_vertical", false)
	
	
	visible = true
	
	
## Fills remappable items and sub-sections into the given container	
func _fill_remappable_items(context:GUIDEMappingContext, root:Container) -> void:
	var items := _remapper.get_remappable_items(context)
	var section_name := ""
	for item in items:
		if item.display_category != section_name:
			section_name = item.display_category
			var section:Node = binding_section_scene.instantiate()
			root.add_child(section)
			section.text = section_name
			
		var instance:Node = binding_row_scene.instantiate()
		root.add_child(instance)
		
		# Show the current binding.
		instance.initialize(item, _remapper.get_bound_input_or_null(item))
		instance.rebind.connect(_rebind_item)



func _rebind_item(item:GUIDERemapper.ConfigItem) -> void:
	_focused_control = get_viewport().gui_get_focus_owner()
	_focused_control.release_focus()
	
	_press_prompt.visible = true

	# Limit the devices that we can detect based on which
	# mapping context we're currently working on. So 
	# for keyboard only keys can be bound and for controller
	# only controller buttons can be bound.
	var device := GUIDEInputDetector.DeviceType.KEYBOARD
	if item.context == controller_context:
		device = GUIDEInputDetector.DeviceType.JOY

	# detect a new input
	_input_detector.detect(item.value_type, [device])
	var input:GUIDEInput = await _input_detector.input_detected

	_press_prompt.visible = false

	_focused_control.grab_focus()

	# check if the detection was aborted.
	if input == null:
		return

	# check for collisions 
	var collisions := _remapper.get_input_collisions(item, input)
		
	# if any collision is from a non-bindable mapping, we cannot use this input
	if collisions.any(func(it:GUIDERemapper.ConfigItem) -> bool: return not it.is_remappable):
		return
		
	# unbind the colliding entries.
	for collision in collisions:
		_remapper.set_bound_input(collision, null)
		
	# now bind the new input
	_remapper.set_bound_input(item, input)
			


func _clear(root:Container) -> void:
	for child in root.get_children():
		root.remove_child(child)
		child.queue_free()
		
		
func _on_abort_detection() -> void:
	_input_detector.abort_detection()

func _on_close_dialog() -> void:
	if _input_detector.is_detecting:
		return
	# same as pressing return to game	
	_on_return_to_game_pressed()

func _on_controller_invert_horizontal_toggled(toggled_on:bool) -> void:
	_remapper.set_custom_data(Utils.CUSTOM_DATA_INVERT_HORIZONTAL, toggled_on)


func _on_controller_invert_vertical_toggled(toggled_on:bool) -> void:
	_remapper.set_custom_data(Utils.CUSTOM_DATA_INVERT_VERTICAL, toggled_on)


func _on_return_to_game_pressed() -> void:
	# get the modified config
	var final_config := _remapper.get_mapping_config()
	# store it
	Utils.save_remapping_config(final_config)

	# restore main mapping context based on what is currently active
	if GUIDE.is_mapping_context_enabled(binding_keyboard_context):
		GUIDE.enable_mapping_context(keyboard_context, true)
	else:
		GUIDE.enable_mapping_context(controller_context, true)

	# and close the dialog
	visible = false
	closed.emit(final_config)
	
	
func _switch_tab(index:int) -> void:
	_tab_container.current_tab = posmod(_tab_container.current_tab + index, 2)	

func _switch(context:GUIDEMappingContext) -> void:
	# only do this when the dialog is visible
	if not visible:
		return
		
	GUIDE.enable_mapping_context(context, true)
