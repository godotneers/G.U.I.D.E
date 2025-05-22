@tool
## Accumulates a value over a period of time and optionally clamps the output.
class_name GUIDEModifierAccumulator
extends GUIDEModifier

## Should the output be clamped to the range? (Recommended)
## If the clamp is not applied, the value can exceed the `end_value`
@export var apply_clamp:bool = true

## The initial value for the accumulator
@export var start_value:float = 0.0

## The end value for the accumulator
@export var end_value:float = 1.0

## The time in seconds that it takes to accumulate to the `end_value`
@export var time:float = 1.0

## A multiplier for how quickly the accumulator decreases its value
@export var decrease_multiplier:float = 1.0

## Reset to empty as soon as the input is released
@export var empty_on_key_up:bool = false

## Whether or not to reset as soon as the limit is reached
@export var reset_at_limit:bool = false

## Apply modifier to X axis
@export var x:bool = true

## Apply modifier to Y axis
@export var y:bool = true

## Apply modifier to Z axis
@export var z:bool = true

var _cur_vals:Vector3
var _cur_time:Vector3 = Vector3.ZERO
var _units_per_second:float


func _begin_usage() -> void:
	# we calculate how many units to increase by per frame based on the time range
	# since delta is the number of seconds between each frame
	_units_per_second = (end_value - start_value) / time
	_cur_vals = Vector3.ONE * start_value


func _update_time(input:float, cur_time:float, delta:float) -> float:
	var amount:float = delta * clamp(input, 0.0, 1.0)
	if input <= 0.0:
		if empty_on_key_up:
			return 0.0
		amount = -1.0 * delta * decrease_multiplier
	return clamp(cur_time + amount, 0.0, time if apply_clamp else INF)


func _modify_input(input:Vector3, delta:float, _value_type:GUIDEAction.GUIDEActionValueType) -> Vector3:
	if not input.is_finite():
		return Vector3.INF
	
	# we reset at the start to allow the value to be at its maximum for at least one frame
	if reset_at_limit:
		# since we're not arbitrarily clamping, we have to know which direction we're going
		if end_value > start_value:
			if _cur_vals.x >= end_value: _cur_time.x = 0.0
			if _cur_vals.y >= end_value: _cur_time.y = 0.0
			if _cur_vals.z >= end_value: _cur_time.z = 0.0
		else:
			if _cur_vals.x <= end_value: _cur_time.x = 0.0
			if _cur_vals.y <= end_value: _cur_time.y = 0.0
			if _cur_vals.z <= end_value: _cur_time.z = 0.0
	
	_cur_time.x = _update_time(input.x, _cur_time.x, delta)
	_cur_time.y = _update_time(input.y, _cur_time.y, delta)
	_cur_time.z = _update_time(input.z, _cur_time.z, delta)
	
	_cur_vals.x = start_value + (_cur_time.x * _units_per_second)
	_cur_vals.y = start_value + (_cur_time.y * _units_per_second)
	_cur_vals.z = start_value + (_cur_time.z * _units_per_second)
	
	# Return vector with enabled axes set, others unchanged
	return Vector3(
		_cur_vals.x if x else input.x,
		_cur_vals.y if y else input.y,
		_cur_vals.z if z else input.z,
	)


func _editor_name() -> String:
	return "Accumulator"


func _editor_description() -> String:
	return "Accumulates a value over a period of time and optionally clamps the output"
