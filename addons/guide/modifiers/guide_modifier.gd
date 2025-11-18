@tool
@icon("res://addons/guide/modifiers/guide_modifier.svg")
class_name GUIDEModifier
extends Resource

## Returns whether this modifier is the same as the other modifier.
## This is used to determine if a modifier can be reused during context switching.
func is_same_as(other:GUIDEModifier) -> bool:
	return self == other

## Called when the modifier is started to be used by GUIDE. Can be used to perform
## initializations.
func _begin_usage() -> void :
	pass
	
## Called, when the modifier is no longer used by GUIDE. Can be used to perform
## cleanup.
func _end_usage() -> void:
	pass

## Called to modify the input value before it is passed to the triggers.
func _modify_input(input:Vector3, delta:float, value_type:GUIDEAction.GUIDEActionValueType) -> Vector3:
	return input

## The name as it should be displayed in the editor.
func _editor_name() -> String:
	return ""

## The description as it should be displayed in the editor.
func _editor_description() -> String:
	return ""

## Whether this modifier needs physics processing. This is queried once
## when the modifier is used, not every frame.
func _needs_physics_process() -> bool:
	return false

## Called to update any internal state of the modifier during physics processing.
## Only called if _needs_physics_process() returns true.
func _physics_process(_delta: float) -> void:
	pass
