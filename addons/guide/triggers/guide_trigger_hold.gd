@tool
## A trigger that activates when the input has been held down for a certain amount of time.
class_name GUIDETriggerHold
extends GUIDETrigger

## Continous actuation time required before triggering.
@export var hold_treshold:float = 1.0
## If true the trigger will only fire once until the input is released. Otherwise the trigger will fire every frame.
@export var is_one_shot:bool = false

var _accumulated_time:float = 0
var _did_shoot:bool = false

func is_same_as(other:GUIDETrigger) -> bool:
	return other is GUIDETriggerHold and \
			is_one_shot == other.is_one_shot and \
			is_equal_approx(hold_treshold, other.hold_treshold)

func _update_state(input:Vector3, delta:float, value_type:GUIDEAction.GUIDEActionValueType) -> GUIDETriggerState:
	# if the input is actuated, accumulate time and check if the hold threshold has been reached
	if _is_actuated(input, value_type):
		_accumulated_time += delta
		
		if _accumulated_time >= hold_treshold:
			# if the trigger is one shot and we already shot, then we will not trigger again.
			if is_one_shot and _did_shoot:
				return GUIDETriggerState.NONE
			else:
				# otherwise, we will just trigger.
				_did_shoot = true
				return GUIDETriggerState.TRIGGERED
		else:
			# if the hold threshold has not been reached, then the trigger is ongoing.
			return GUIDETriggerState.ONGOING
	else:
		# if the input is not actuated, reset the accumulated time and one shot flag.
		_accumulated_time = 0
		_did_shoot = false
		return GUIDETriggerState.NONE


func _editor_name() -> String:
	return "Hold"

func _editor_description() -> String:
	return "Fires once the input has remained actuated for hold_threshold seconds.\n" + \
			"May fire once or repeatedly."
