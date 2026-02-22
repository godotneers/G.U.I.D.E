## This example demonstrates how to combine multiple mapping contexts.
##
## Both keyboard and controller inputs are enabled simultaneously, and they both
## map to the same action. This allows seamless input from multiple sources without
## needing to switch contexts.
extends Node2D

@export var keyboard_and_mouse:GUIDEMappingContext
@export var controller:GUIDEMappingContext


func _ready() -> void:
	# Enable both mapping contexts at the same time.
	# They can both map to the same action, and whichever input is used
	# will control the player.
	GUIDE.enable_mapping_context(keyboard_and_mouse)
	GUIDE.enable_mapping_context(controller)
