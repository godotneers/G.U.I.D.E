extends GUIDETestBase

var _context:GUIDEMappingContext
var _action:GUIDEAction
var _trigger:GUIDETrigger

var actuation_threshold:float = 0.5
var offset:float = 0.2

func _setup() -> void:
	_context = mapping_context()
	_action = action_1d()
	_trigger = trigger_hair(actuation_threshold)

## Tests complete hair trigger behavior: peak/valley tracking and symmetric trigger/release.
func test_trigger_hair_peak_and_valley_tracking() -> void:
	var input := input_joy_axis_1d(JOY_AXIS_TRIGGER_RIGHT)
	map(_context, _action, input, [], [_trigger])
	GUIDE.enable_mapping_context(_context)

	var action := watch(_action)

	# Initial trigger: rise from 0 to threshold
	await joy_axis(JOY_AXIS_TRIGGER_RIGHT, actuation_threshold)
	assert_bool(await action.triggered_was_emitted()).is_true()
	assert_axis_1d(_action, actuation_threshold)

	# Peak tracking: rise further while triggered
	await joy_axis(JOY_AXIS_TRIGGER_RIGHT, actuation_threshold + offset)
	action.reset()
	assert_bool(await action.triggered_was_emitted()).is_true()
	assert_axis_1d(_action, actuation_threshold + offset)

	# Release: drop by threshold from peak (0.7 -> 0.2)
	action.reset()
	await joy_axis(JOY_AXIS_TRIGGER_RIGHT, offset)
	assert_bool(await action.completed_was_emitted()).is_true()
	assert_axis_1d(_action, offset)

	# Valley tracking: drop further while not triggered
	action.reset()
	await joy_axis(JOY_AXIS_TRIGGER_RIGHT, offset / 2)
	assert_bool(action.triggered_was_not_emitted()).is_true()
	assert_axis_1d(_action, offset / 2)

	# Re-trigger: rise by threshold from valley (0.1 + 0.5 = 0.6)
	await joy_axis(JOY_AXIS_TRIGGER_RIGHT, offset / 2 + actuation_threshold)
	assert_bool(await action.triggered_was_emitted()).is_true()
	assert_axis_1d(_action, offset / 2 + actuation_threshold)

	# Release again: drop by threshold from new peak (0.6 -> 0.1)
	action.reset()
	await joy_axis(JOY_AXIS_TRIGGER_RIGHT, offset / 2)
	assert_bool(await action.completed_was_emitted()).is_true()
	assert_axis_1d(_action, offset / 2)
