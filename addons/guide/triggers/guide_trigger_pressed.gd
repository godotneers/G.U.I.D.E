@tool
## A trigger that activates when the input is pushed down. Will only emit a
## trigger event once. Holding the input will not trigger further events.
class_name GUIDETriggerPressed
extends GUIDETrigger

## If [code]true[/code], the relevant [GUIDEAction] will be triggered if the [GUIDEMappingContext]
## is made active while the relevant input mapping is actuated.[br]
## If [code]false[/code], the relevant input mapping must be in an unactuated state before it will be triggered.
@export var triggerable_immediately:bool = true

func _update_state(input:Vector3, delta:float, value_type:GUIDEAction.GUIDEActionValueType) -> GUIDETriggerState:
	if _is_actuated(input, value_type):
		if not _is_actuated(_last_value, value_type):
			return GUIDETriggerState.TRIGGERED
		
	return GUIDETriggerState.NONE


func _editor_name() -> String:
	return "Pressed"


func _editor_description() -> String:
	return "Fires once, when the input exceeds actuation threshold. Holding the input\n" + \
		"will not fire additional triggers."
