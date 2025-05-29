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


enum ReadyCondition {
	## Always allow the accumulator to resume accumulating
	ALWAYS,
	## If the accumulator was full, only allow accumulation after the value reaches the start_value again
	WHEN_FULL_AFTER_RESET,
	## If any value has been accumulated at all, only allow accumulation after the value reaches the start_value again
	ONLY_AFTER_RESET
}

## When should the accumulator be allowed to fill?
@export var ready_condition := ReadyCondition.ALWAYS


enum DecreaseCondition {
	## Begin decreasing the accumulator when the input is released
	DECREASE_ON_RELEASE,
	## Begin decreasing the accumulator when the value reaches the end_value
	DECREASE_AT_LIMIT,
	## Reset to the start_value as soon as the input is released
	RESET_ON_RELEASE,
	## Reset to the start_value as soon as the accumulator reaches the end_value
	RESET_AT_LIMIT,
}

## When and how should the accumulator decrease its value?
@export var decrease_condition := DecreaseCondition.DECREASE_ON_RELEASE


## A multiplier for how quickly the accumulator decreases its value
@export var decrease_multiplier:float = 1.0


enum InputAxis { X, Y, Z }

## Which axis should we use to accumulate?
@export var input_axis:InputAxis = InputAxis.X


enum AxisRole {
	## This axis will not be used by the accumulator, and will remain unchanged
	UNCHANGED,
	## This axis will contain the currently accumulated value
	VALUE,
	## This axis will contain the amount of time the accumulator has run
	TIME_ELAPSED,
	## This axis will contain the Ready State. 1.0 if a value is allowed to accumulate, or 0.0 if accumulator is waiting to reset
	READY_STATE
}

## Apply modifier to X axis
@export var x:AxisRole = AxisRole.VALUE

## Apply modifier to Y axis
@export var y:AxisRole = AxisRole.UNCHANGED

## Apply modifier to Z axis
@export var z:AxisRole = AxisRole.UNCHANGED


var _value:float
var _elapsed:float
var _ready:bool

var _units_per_second:float


func _begin_usage() -> void:
	# we calculate how many units to increase by per frame based on the time range
	# since delta is the number of seconds between each frame
	_units_per_second = (end_value - start_value) / time
	_reset_accumulator()


func _reset_accumulator() -> void:
	_value = start_value
	_elapsed = 0.0
	_ready = true


func _update_accumulator(input:float, delta:float) -> void:
	# we do our limit checks at the start to allow the value to be at its maximum for at least one frame
	if _elapsed >= time:
		if decrease_condition == DecreaseCondition.RESET_AT_LIMIT:
			return _reset_accumulator()
		elif decrease_condition == DecreaseCondition.DECREASE_AT_LIMIT:
			_ready = false
		elif ready_condition == ReadyCondition.WHEN_FULL_AFTER_RESET and input <= 0.0:
			_ready = false
	elif _elapsed == 0.0:
		_ready = true
	
	if input <= 0.0:
		if decrease_condition == DecreaseCondition.RESET_ON_RELEASE:
			return _reset_accumulator()
		if ready_condition == ReadyCondition.ONLY_AFTER_RESET and _elapsed > 0.0:
			_ready = false
	elif ready_condition == ReadyCondition.ALWAYS:
		_ready = true
	
	var amount:float = delta * clamp(input, 0.0, 1.0)
	# if we're not ready or the user isn't applying input, decrease the accumulator
	if not _ready or input <= 0.0:
		amount = -1.0 * delta * decrease_multiplier
	
	var new_time := clamp(_elapsed + amount, 0.0, time if apply_clamp else INF)
	
	_value = start_value + (new_time * _units_per_second)
	_elapsed = new_time


func _modify_input(input:Vector3, delta:float, _value_type:GUIDEAction.GUIDEActionValueType) -> Vector3:
	if not input.is_finite():
		return Vector3.INF
	
	var input_value:float
	match input_axis:
		InputAxis.X:
			input_value = input.x
		InputAxis.Y:
			input_value = input.y
		InputAxis.Z:
			input_value = input.z
	
	_update_accumulator(input_value, delta)
	
	var _ret: Vector3 = input
	
	match x:
		AxisRole.VALUE:
			_ret.x = _value
		AxisRole.TIME_ELAPSED:
			_ret.x = _elapsed
		AxisRole.READY_STATE:
			_ret.x = 1.0 if _ready else 0.0
	
	match y:
		AxisRole.VALUE:
			_ret.y = _value
		AxisRole.TIME_ELAPSED:
			_ret.y = _elapsed
		AxisRole.READY_STATE:
			_ret.y = 1.0 if _ready else 0.0
	
	match z:
		AxisRole.VALUE:
			_ret.z = _value
		AxisRole.TIME_ELAPSED:
			_ret.z = _elapsed
		AxisRole.READY_STATE:
			_ret.z = 1.0 if _ready else 0.0
	
	print("Accumulator: ", _ret, " (input: ", input, ", delta: ", delta, ")")
	
	# Return vector with enabled axes set, others unchanged
	return _ret


func _editor_name() -> String:
	return "Accumulator"


func _editor_description() -> String:
	return "Accumulates a value over a period of time and optionally clamps the output"
