extends Node2D

@export var keyboard_and_mouse:GUIDEMappingContext
@export var controller:GUIDEMappingContext

@export var switch_to_controller:GUIDEAction
@export var switch_to_keyboard_and_mouse:GUIDEAction

func _ready() -> void:
	# enable controller at the start
	GUIDE.enable_mapping_context(controller)
	
	# Switch the control scheme depending on the input.
	switch_to_controller.triggered \
		.connect(func() -> void: GUIDE.enable_mapping_context(controller, true))
	switch_to_keyboard_and_mouse.triggered \
		.connect(func() -> void: GUIDE.enable_mapping_context(keyboard_and_mouse, true))
	


