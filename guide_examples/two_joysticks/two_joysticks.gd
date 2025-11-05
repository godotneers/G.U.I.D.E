extends Node2D

@export var mapping_context:GUIDEMappingContext

func _ready() -> void:
	GUIDE.enable_mapping_context(mapping_context)
