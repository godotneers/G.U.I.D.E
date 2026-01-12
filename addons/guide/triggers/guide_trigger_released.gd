@tool
## A trigger that activates when the input is released down. Will only emit a
## trigger event once.
class_name GUIDETriggerReleased
extends GUIDETrigger

func is_same_as(other: GUIDETrigger) -> bool:
	return other is GUIDETriggerReleased


func _update_state(input: Vector3, delta: float, value_type: GUIDEAction.GUIDEActionValueType) -> GUIDETriggerState:
	# https://github.com/godotneers/G.U.I.D.E/issues/144 - go to ongoing while input is 
	# actuated, so code can track position while input is held down. This is useful for 
	# touch input, where we have no more position information when input is released.
	if _is_actuated(input, value_type):
		return GUIDETriggerState.ONGOING
	
	if not _is_actuated(input, value_type):
		if _is_actuated(_last_value, value_type):
			return GUIDETriggerState.TRIGGERED
	
	return GUIDETriggerState.NONE


func _editor_name() -> String:
	return "Released"


func _editor_description() -> String:
	return "Fires once, when the input goes from actuated to not actuated. The opposite of the Pressed trigger."
