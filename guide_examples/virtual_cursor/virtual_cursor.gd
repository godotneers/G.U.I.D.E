extends Node2D

@export var keyboard_and_mouse:GUIDEMappingContext
@export var controller:GUIDEMappingContext

@export var switch_to_controller:GUIDEAction
@export var switch_to_keyboard_and_mouse:GUIDEAction


func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
	GUIDE.enable_mapping_context(keyboard_and_mouse)
	
	switch_to_controller.triggered.connect(_to_controller)
	switch_to_keyboard_and_mouse.triggered.connect(_to_keyboard_and_mouse)
	
	
func _to_controller():
	GUIDE.enable_mapping_context(controller, true)
	
	
func _to_keyboard_and_mouse():
	GUIDE.enable_mapping_context(keyboard_and_mouse, true)
