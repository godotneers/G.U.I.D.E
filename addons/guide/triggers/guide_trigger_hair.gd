@tool
# Triggers using relative actuation threshold instead of absolute threshold.
# Triggers when the input presses more than the threshold.
# Stops when the input unpresses more than the threshold.
class_name GUIDETriggerHair
extends GUIDETrigger

var _edge_value: float = 0.0
var _is_triggered: bool = false

func is_same_as(other: GUIDETrigger) -> bool:
	return other is GUIDETriggerHair and \
	is_equal_approx(actuation_threshold, other.actuation_threshold)


func _update_state(input: Vector3, delta: float, value_type: GUIDEAction.GUIDEActionValueType) -> GUIDETriggerState:
	# Hair trigger: symmetric behavior prevents jitter on release/re-trigger.
	# Triggered: _edge_value tracks peak, release when dropping BY threshold from peak.
	# Not triggered: _edge_value tracks valley, trigger when rising BY threshold from valley.

	if _is_triggered:
		# Track peak - update if input increased
		if input.x > _edge_value:
			_edge_value = input.x

		# Release when dropping BY threshold from peak (with epsilon for float precision)
		var drop := _edge_value - input.x
		if drop >= actuation_threshold - 0.001:
			_is_triggered = false
			_edge_value = input.x  # Switch to tracking valley
			return GUIDETriggerState.NONE

		return GUIDETriggerState.TRIGGERED
	else:
		# Track valley - update if input decreased
		if input.x < _edge_value:
			_edge_value = input.x

		# Trigger when rising BY threshold from valley (with epsilon for float precision)
		var rise := input.x - _edge_value
		if rise >= actuation_threshold - 0.001:
			_is_triggered = true
			_edge_value = input.x  # Switch to tracking peak
			return GUIDETriggerState.TRIGGERED

		return GUIDETriggerState.NONE


func _editor_name() -> String:
	return "Hair"

func _editor_description() -> String:
	return "Triggers and resets when a relative threshold is hit."
