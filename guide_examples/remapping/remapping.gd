## This is the main game controller. It enables a control scheme at the start and is
## responsible for controlling the remapping dialog.
extends Node

const Utils = preload("utils.gd")

@export_group("Context & Modifiers")
@export var keyboard:GUIDEMappingContext
@export var controller:GUIDEMappingContext
@export var controller_axis_invert_modifier:GUIDEModifierNegate

@export_group("Actions")
@export var switch_to_keyboard:GUIDEAction
@export var switch_to_controller:GUIDEAction
@export var open_menu:GUIDEAction


@onready var _remapping_dialog:Control = %RemappingDialog

func _ready() -> void:
	# React when the open menu action is triggered.
	open_menu.triggered.connect(_open_menu)
	
	# and switching to controller / keyboard ... 
	switch_to_controller.triggered.connect(_switch.bind(controller))
	switch_to_keyboard.triggered.connect(_switch.bind(keyboard))
	
	# Also listen to when the remapping dialog closes and re-apply the changed
	# mapping config
	_remapping_dialog.closed.connect(_load_remapping_config)
	
	# Start with the keyboard scheme
	GUIDE.enable_mapping_context(keyboard)
	
	# finally enable all controls with the last saved remapping configuration
	_load_remapping_config(Utils.load_remapping_config())
	
	
func _open_menu() -> void:
	# and show the remapping dialog
	_remapping_dialog.open()
	
	
func _load_remapping_config(config:GUIDERemappingConfig) -> void:
	GUIDE.set_remapping_config(config)
	
	# also apply changes to our modifiers
	controller_axis_invert_modifier.x = config.custom_data.get(Utils.CUSTOM_DATA_INVERT_HORIZONTAL, false)
	controller_axis_invert_modifier.y = config.custom_data.get(Utils.CUSTOM_DATA_INVERT_VERTICAL, false)


func _switch(context:GUIDEMappingContext) -> void:
	# ignore while remapping is active, remapping will take care of it
	if _remapping_dialog.visible:
		return
		
	GUIDE.enable_mapping_context(context, true)
