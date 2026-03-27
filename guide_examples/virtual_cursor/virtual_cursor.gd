extends Node2D

@export var keyboard_and_mouse:GUIDEMappingContext
@export var controller:GUIDEMappingContext

@export var switch_to_controller:GUIDEAction
@export var switch_to_keyboard_and_mouse:GUIDEAction


func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
	GUIDE.enable_mapping_context(keyboard_and_mouse)
	
	switch_to_controller.triggered.connect(_to_controller)
	switch_to_keyboard_and_mouse.triggered.connect(_to_keyboard_and_mouse)
	
	
func _to_controller() -> void:
	# call_deferred is needed because this is called from an action signal handler,
	# which runs during GUIDE's internal update. Changing contexts directly from
	# there is not allowed, similar to modifying physics state in a physics callback.
	GUIDE.enable_mapping_context.call_deferred(controller, true)
	
	
func _to_keyboard_and_mouse() -> void:
	GUIDE.enable_mapping_context.call_deferred(keyboard_and_mouse, true)
