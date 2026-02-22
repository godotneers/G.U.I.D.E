@tool
@icon("res://addons/guide/triggers/guide_trigger.svg")
class_name GUIDETrigger
extends Resource

enum GUIDETriggerState {
	## The trigger did not fire.
	NONE,
	## The trigger's conditions are partially met
	ONGOING,
	## The trigger has fired.
	TRIGGERED
}

enum GUIDETriggerType {
	# If there are more than one explicit triggers at least one must trigger
	# for the action to trigger.
	EXPLICIT = 1,
	# All implicit triggers must trigger for the action to trigger.
	IMPLICIT = 2,
	# All blocking triggers prevent the action from triggering.
	BLOCKING = 3
}


@export var actuation_threshold:float = 0.5
var _last_value:Vector3

## Returns whether this trigger is the same as the other trigger.
## This is used to determine if a trigger can be reused during context switching.
func is_same_as(other:GUIDETrigger) -> bool:
	return self == other

## Creates a clone of this trigger suitable for context merging.
##
## Returns a new trigger instance while preserving references to actions and other
## shared resources. This ensures triggers watch the same actions across contexts.
##
## Default implementation uses shallow copy. Subclasses with sub-resources or arrays
## should override this method to properly duplicate their internal structures while
## still preserving action references.
func clone() -> GUIDETrigger:
	return duplicate()

## Returns the trigger type of this trigger.
func _get_trigger_type() -> GUIDETriggerType:
	return GUIDETriggerType.EXPLICIT


func _update_state(input:Vector3, delta:float, value_type:GUIDEAction.GUIDEActionValueType) -> GUIDETriggerState:
	return GUIDETriggerState.NONE

	
func _is_actuated(input:Vector3, value_type:GUIDEAction.GUIDEActionValueType) -> bool:
	match value_type:
		GUIDEAction.GUIDEActionValueType.AXIS_1D, GUIDEAction.GUIDEActionValueType.BOOL:
			return _is_axis1d_actuated(input)
		GUIDEAction.GUIDEActionValueType.AXIS_2D:
			return _is_axis2d_actuated(input)
		GUIDEAction.GUIDEActionValueType.AXIS_3D:
			return _is_axis3d_actuated(input)
			
	return false

## Checks if a 1D input is actuated.
func _is_axis1d_actuated(input:Vector3) -> bool:
	return is_finite(input.x) and abs(input.x) > actuation_threshold
	
## Checks if a 2D input is actuated.
func _is_axis2d_actuated(input:Vector3) -> bool:
	return is_finite(input.x) and is_finite(input.y) and Vector2(input.x, input.y).length_squared() > actuation_threshold * actuation_threshold

## Checks if a 3D input is actuated.
func _is_axis3d_actuated(input:Vector3) -> bool:
	return input.is_finite() and input.length_squared() > actuation_threshold * actuation_threshold
	
## The name as it should be displayed in the editor.
func _editor_name() -> String:
	return "GUIDETrigger"
	
## The description as it should be displayed in the editor.
func _editor_description() -> String:
	return ""
