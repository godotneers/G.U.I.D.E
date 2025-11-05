## This example shows how to switch the input scheme on the fly. 
extends Node

@export var joystick_scheme:GUIDEMappingContext
@export var keyboard_scheme:GUIDEMappingContext
@export var switch_to_keyboard:GUIDEAction
@export var switch_to_joystick:GUIDEAction

func _ready() -> void:
	# When we get a command to switch the input scheme, we
	# switch.
	switch_to_keyboard.triggered.connect(_switch_input_scheme.bind(keyboard_scheme))
	switch_to_joystick.triggered.connect(_switch_input_scheme.bind(joystick_scheme))
	
	# And switch now to enable keyboard
	_switch_input_scheme(keyboard_scheme)


func _switch_input_scheme(context:GUIDEMappingContext) -> void:
	GUIDE.enable_mapping_context(context, true)
	
