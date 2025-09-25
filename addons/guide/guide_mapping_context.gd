@tool
@icon("res://addons/guide/guide_mapping_context.svg")
class_name GUIDEMappingContext
extends Resource

signal enabled
signal disabled

const GUIDESet = preload("guide_set.gd")

## The display name for this mapping context during action remapping 
@export var display_name:String:
	set(value):
		if value == display_name:
			return
		display_name = value
		emit_changed()

## The mappings. Do yourself a favour and use the G.U.I.D.E panel
## to edit these.
@export var mappings:Array[GUIDEActionMapping] = []:
	set(value):
		if value == mappings:
			return
		mappings = value
		emit_changed()


func _editor_name() -> String:
	if display_name.is_empty():
		return resource_path.get_file()
	else:
		return display_name
