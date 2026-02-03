extends Node2D

@export var keyboard_and_mouse:GUIDEMappingContext
@export var controller:GUIDEMappingContext


func _ready() -> void:
	# enable controller at the start
	GUIDE.enable_mapping_context(keyboard_and_mouse)
	GUIDE.enable_mapping_context(controller)
