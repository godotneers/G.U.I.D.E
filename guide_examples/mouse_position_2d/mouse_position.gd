## This example shows how to get access to the mouse cursor without being
## specific about where the input comes from. 
extends Node2D


@export var mapping_context:GUIDEMappingContext
@export var spawn:GUIDEAction
@export var cursor:GUIDEAction

@export var godot_head_scene:PackedScene

func _ready() -> void:
	GUIDE.enable_mapping_context(mapping_context)
	spawn.triggered.connect(_spawn_godot_head)


func _spawn_godot_head() -> void:
	# Gets the mouse cursor from G.U.I.D.E. Note how the Canvas Coordinates
	# modifier automatically gives us mouse coordinates in canvas space
	# which means we don't need to take into acount the camera panning and 
	# zoom level and can just use the coordinates we get to directly place
	# a Godot head at the cursor position. 
	var head:Node = godot_head_scene.instantiate()
	add_child(head)
	
	head.global_position = cursor.value_axis_2d
