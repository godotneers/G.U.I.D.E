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

func test_trigger_hair_actuate() -> void:
	var input := input_joy_axis_1d(JOY_AXIS_TRIGGER_RIGHT)
	map(_context, _action, input)#, [], [_trigger])
	GUIDE.enable_mapping_context(_context)
	
	# WHEN
	# I actuate the right trigger
	await joy_axis(JOY_AXIS_TRIGGER_RIGHT, actuation_threshold + 0.001)
	
	# THEN
	# the action is triggered
	await assert_triggered(_action)
	
	# and the value is correct
	assert_axis_1d(_action, actuation_threshold + 0.001)
	# assert_float(_action.value_axis_1d).is_equal_approx(actuation_threshold + 0.001)
	
## Tests that pressing then pressing more continues to trigger
## and releasing happens at the threshold.
func test_trigger_hair_retrigger() -> void:
	var input := input_joy_axis_1d(JOY_AXIS_TRIGGER_RIGHT)
	map(_context, _action, input, [], [_trigger])
	GUIDE.enable_mapping_context(_context)
	
	await joy_axis(JOY_AXIS_TRIGGER_RIGHT, actuation_threshold)
	await assert_triggered(_action)
	assert_axis_1d(_action, actuation_threshold)

	# press more
	await joy_axis(JOY_AXIS_TRIGGER_RIGHT, actuation_threshold + offset)
	await assert_triggered(_action)
	assert_axis_1d(_action, actuation_threshold + offset)
	
	await joy_axis(JOY_AXIS_TRIGGER_RIGHT, offset)
	await assert_completed(_action)
	assert_axis_1d(_action, offset)

## Tests that pressing then unpressing more continues to trigger
## and releasing happens at the threshold.
func test_trigger_hair_multiple_trigger() -> void:
	var input := input_joy_axis_1d(JOY_AXIS_TRIGGER_RIGHT)
	map(_context, _action, input, [], [_trigger])
	GUIDE.enable_mapping_context(_context)
	
	log_signals(_action)
	
	await joy_axis(JOY_AXIS_TRIGGER_RIGHT, actuation_threshold + offset)
	await assert_triggered(_action)
	assert_axis_1d(_action, actuation_threshold + offset)
	
	await joy_axis(JOY_AXIS_TRIGGER_RIGHT, offset)
	await assert_completed(_action)
	assert_axis_1d(_action, offset)
	
	await joy_axis(JOY_AXIS_TRIGGER_RIGHT, actuation_threshold + (offset * 2))
	await assert_triggered(_action)
	assert_axis_1d(_action, actuation_threshold + (offset * 2))
	
	await joy_axis(JOY_AXIS_TRIGGER_RIGHT, (offset * 2))
	await assert_completed(_action)
	assert_axis_1d(_action, (offset * 2))

## Tests that pressing then unpressing more continues to trigger
## and releasing happens at the threshold.
func test_trigger_hair_multiple_trigger_bool() -> void:
	var input := input_key(KEY_A)
	map(_context, _action, input, [], [_trigger])
	GUIDE.enable_mapping_context(_context)
	
	log_signals(_action)
	
	await tap_key(KEY_A)
	await assert_triggered(_action)
	
	#await tap_key(KEY_A)
	await assert_completed(_action)
	
	await tap_key(KEY_A)
	await assert_triggered(_action)
	
	#await tap_key(KEY_A)
	await assert_completed(_action)

func test_trigger_hair_any_axis() -> void:
	var input := input_any()
	input.joy_axes = true
	map(_context, _action, input, [], [_trigger])
	GUIDE.enable_mapping_context(_context)
	
	# WHEN: i move the joy axis
	await joy_axis(JOY_AXIS_LEFT_X, actuation_threshold)
	
	# THEN: the action is triggered
	await assert_triggered(_action)
	
	# WHEN: i stop moving the joy axis
	await joy_axis(JOY_AXIS_LEFT_X, 0)

	# THEN: the action is not triggered
	await assert_not_triggered(_action)
	await assert_completed(_action)
