@tool

class_name GUIDETriggerHair
extends GUIDETrigger

var _last_actuation_value: Vector3
var _actuated: bool = false

func is_same_as(other: GUIDETrigger) -> bool:
	return other is GUIDETriggerHair and \
	is_equal_approx(actuation_threshold, other.actuation_threshold)
	

# If trigger actuation is passed then send trigger until not activated
# Trigger activation is when _current_value - _last_actuation_min_value > actuation_threshold

func _update_state(input: Vector3, delta: float, value_type: GUIDEAction.GUIDEActionValueType) -> GUIDETriggerState:
	print("Input: %.2s, Last: %.2s, Diff: %.2s" % [input, _last_actuation_value, input.x - _last_actuation_value.x])

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
		if diff.x >= actuation_threshold:
			_actuated = true
			return GUIDETriggerState.TRIGGERED
		else:
			return GUIDETriggerState.ONGOING
	else:
		if diff.x <= -actuation_threshold:
			_actuated = false
			return GUIDETriggerState.NONE
	return GUIDETriggerState.NONE


## Checks if a 1D input is actuated.
func _is_axis1d_actuated(input:Vector3) -> bool:
	return is_finite(input.x) and (input.x - _last_actuation_value.x) > actuation_threshold
	
## Checks if a 2D input is actuated.
func _is_axis2d_actuated(input:Vector3) -> bool:
	var diff = (input - _last_actuation_value)
	diff.z = 0
	return is_finite(input.x) and is_finite(input.y) and diff.length_squared() > actuation_threshold * actuation_threshold

## Checks if a 3D input is actuated.
func _is_axis3d_actuated(input:Vector3) -> bool:
	var diff = (input - _last_actuation_value)
	return input.is_finite() and diff.length_squared() > actuation_threshold * actuation_threshold

func _editor_name() -> String:
	return "Hair"


func _editor_description() -> String:
	return "Triggers and resets when a relative threshold is hit.\n"
