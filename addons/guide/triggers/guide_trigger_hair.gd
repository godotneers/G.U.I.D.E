@tool
# Triggers using relative actuation threshold instead of absolute threshold.
# Triggers when the input presses more than the threshold.
# Stops when the input unpresses more than the threshold.
class_name GUIDETriggerHair
extends GUIDETrigger

var _last_actuation_value: Vector3
var _actuated: bool = false

func is_same_as(other: GUIDETrigger) -> bool:
	return other is GUIDETriggerHair and \
	is_equal_approx(actuation_threshold, other.actuation_threshold)
	

func _update_state(input: Vector3, delta: float, value_type: GUIDEAction.GUIDEActionValueType) -> GUIDETriggerState:
	var diff = input - _last_actuation_value
	if _actuated:
		# Push compare value if input increases
		if input > _last_actuation_value:
			_last_actuation_value = input
	else:
		# Push compare value if input decreases
		if input < _last_actuation_value:
			_last_actuation_value = input

	if not _actuated:
		if is_finite(diff.x) and diff.x >= actuation_threshold:
			_actuated = true
			_last_actuation_value = input
			return GUIDETriggerState.TRIGGERED
		return GUIDETriggerState.NONE
	else:
		if is_finite(diff.x) and diff.x <= actuation_threshold:
			_actuated = false
			_last_actuation_value = input
			return GUIDETriggerState.NONE
		return GUIDETriggerState.TRIGGERED


func _editor_name() -> String:
	return "Hair"

func _editor_description() -> String:
	return "Triggers and resets when a relative threshold is hit.\n"
