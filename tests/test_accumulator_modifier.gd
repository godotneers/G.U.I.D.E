extends GUIDETestBase


var _context:GUIDEMappingContext
var _action:GUIDEAction

var _time_scale := 0.25

func _setup():
	_context = mapping_context()
	_action = action_1d()


func test_modifier_works_linearly():
	var input := input_joy_axis_1d(JOY_AXIS_LEFT_X)
	var modifier := modifier_accumulator(0.0, 100.0, _time_scale)
	map(_context, _action, input, [modifier])
	GUIDE.enable_mapping_context(_context)
	
	# WHEN i move the joy fully to the left
	joy_axis(JOY_AXIS_LEFT_X, 0.0)
	# THEN the action's value is 0
	assert_float(_action.value_axis_1d).is_equal_approx(0, 0.01)
	
	# WHEN i move the joy fully to the right
	joy_axis(JOY_AXIS_LEFT_X, 1.0)
	#  AND wait 0.5 seconds
	await wait_seconds(_time_scale * 0.5)
	# THEN the action's value is 50
	assert_float(_action.value_axis_1d).is_equal_approx(50, 5.0)

	# WHEN i wait 0.5 more seconds
	await wait_seconds(_time_scale * 0.5)
	# THEN the action's value is 100
	assert_float(_action.value_axis_1d).is_equal_approx(100, 5.0)

	# WHEN i move the joy fully to the left
	joy_axis(JOY_AXIS_LEFT_X, 0.0)
	#  AND wait 1 second
	await wait_seconds(_time_scale)
	# THEN the action's value is 0
	assert_float(_action.value_axis_1d).is_equal_approx(0, 5.0)

func test_modifier_works_in_reverse():
	var input := input_joy_axis_1d(JOY_AXIS_LEFT_X)
	var modifier := modifier_accumulator(0.0, -100.0, _time_scale)
	map(_context, _action, input, [modifier])
	GUIDE.enable_mapping_context(_context)
	
	# WHEN i move the joy fully to the left
	joy_axis(JOY_AXIS_LEFT_X, 0.0)
	# THEN the action's value is 0
	assert_float(_action.value_axis_1d).is_equal_approx(0, 0.01)
	
	# WHEN i move the joy fully to the right
	joy_axis(JOY_AXIS_LEFT_X, 1.0)
	#  AND wait 0.5 seconds
	await wait_seconds(_time_scale * 0.5)
	# THEN the action's value is -50
	assert_float(_action.value_axis_1d).is_equal_approx(-50, 5.0)

	# WHEN i wait 0.5 more seconds
	await wait_seconds(_time_scale * 0.5)
	# THEN the action's value is -100
	assert_float(_action.value_axis_1d).is_equal_approx(-100, 5.0)

	# WHEN i move the joy fully to the left
	joy_axis(JOY_AXIS_LEFT_X, 0.0)
	#  AND wait 1 second
	await wait_seconds(_time_scale)
	# THEN the action's value is 0
	assert_float(_action.value_axis_1d).is_equal_approx(0, 5.0)

func test_modifier_works_with_analog():
	var input := input_joy_axis_1d(JOY_AXIS_LEFT_X)
	var modifier := modifier_accumulator(0.0, 100.0, _time_scale)
	map(_context, _action, input, [modifier])
	GUIDE.enable_mapping_context(_context)
	
	# WHEN i move the joy fully to the left
	joy_axis(JOY_AXIS_LEFT_X, 0.0)
	# THEN the action's value is 0
	assert_float(_action.value_axis_1d).is_equal_approx(0, 0.01)
	
	# WHEN i move the joy half-way to the right
	joy_axis(JOY_AXIS_LEFT_X, 0.5)
	#  AND wait 1 second
	await wait_seconds(_time_scale)
	# THEN the action's value is 50
	assert_float(_action.value_axis_1d).is_equal_approx(50, 5.0)
	
	# WHEN i move the joy fully to the left
	joy_axis(JOY_AXIS_LEFT_X, 0.0)
	#  AND wait 0.5 seconds
	await wait_seconds(_time_scale * 0.25)
	# THEN the action's value is 25
	assert_float(_action.value_axis_1d).is_equal_approx(25, 5.0)

func test_modifier_works_with_decrease_multiplier():
	var input := input_joy_axis_1d(JOY_AXIS_LEFT_X)
	var modifier := modifier_accumulator(0.0, 100.0, _time_scale, 2.0)
	map(_context, _action, input, [modifier])
	GUIDE.enable_mapping_context(_context)
	
	# WHEN i move the joy fully to the left
	joy_axis(JOY_AXIS_LEFT_X, 0.0)
	# THEN the action's value is 0
	assert_float(_action.value_axis_1d).is_equal_approx(0, 0.01)
	
	# WHEN i move the joy fully to the right
	joy_axis(JOY_AXIS_LEFT_X, 1.0)
	#  AND wait 1 second
	await wait_seconds(_time_scale)
	# THEN the action's value is 100
	assert_float(_action.value_axis_1d).is_equal_approx(100, 5.0)
	
	# WHEN i move the joy fully to the left
	await joy_axis(JOY_AXIS_LEFT_X, -1.0)
	#  AND wait only 0.5 seconds
	await wait_seconds(_time_scale * 0.5)
	# THEN the action's value is already 0
	assert_float(_action.value_axis_1d).is_equal_approx(0, 5.0)

func test_modifier_works_with_empty_on_key_up():
	var input := input_joy_axis_1d(JOY_AXIS_LEFT_X)
	var modifier := modifier_accumulator(0.0, 100.0, _time_scale, 0.2, true)
	map(_context, _action, input, [modifier])
	GUIDE.enable_mapping_context(_context)
	
	# WHEN i move the joy fully to the left
	joy_axis(JOY_AXIS_LEFT_X, 0.0)
	# THEN the action's value is 0
	assert_float(_action.value_axis_1d).is_equal_approx(0, 0.01)
	
	# WHEN i move the joy fully to the right
	joy_axis(JOY_AXIS_LEFT_X, 1.0)
	# AND wait 1 second
	await wait_seconds(_time_scale)
	# THEN the action's value is 100
	assert_float(_action.value_axis_1d).is_equal_approx(100, 5.0)
	
	# WHEN i move the joy fully to the left
	joy_axis(JOY_AXIS_LEFT_X, 0.0)
	await wait_seconds(_time_scale * 0.1)
	# THEN the action's value is 0 immediately
	assert_float(_action.value_axis_1d).is_equal_approx(0, 0.01)

func test_modifier_works_with_reset_at_limit():
	var input := input_joy_axis_1d(JOY_AXIS_LEFT_X)
	var modifier := modifier_accumulator(0.0, 100.0, _time_scale, 0.0, false, true)
	map(_context, _action, input, [modifier])
	GUIDE.enable_mapping_context(_context)
	
	# WHEN i move the joy fully to the left
	joy_axis(JOY_AXIS_LEFT_X, 0.0)
	# THEN the action's value is 0
	assert_float(_action.value_axis_1d).is_equal_approx(0, 0.01)
	
	# WHEN i move the joy fully to the right
	joy_axis(JOY_AXIS_LEFT_X, 1.0)
	#  AND wait 0.95 seconds
	await wait_seconds(_time_scale * 0.95)
	# THEN the action's value should be nearing 100
	assert_float(_action.value_axis_1d).is_equal_approx(95, 5.0)
	# WHEN i wait 0.05 more seconds
	await wait_seconds(_time_scale * 0.075)
	# THEN the action's value should be back to 0
	assert_float(_action.value_axis_1d).is_equal_approx(0, 5.0)

func test_modifier_works_with_apply_clamp():
	var input := input_joy_axis_1d(JOY_AXIS_LEFT_X)
	var local_time_scale = _time_scale / 2.0
	var modifier := modifier_accumulator(0.0, 100.0, local_time_scale, 1.0, false, false, true)
	map(_context, _action, input, [modifier])
	GUIDE.enable_mapping_context(_context)
	
	# WHEN i move the joy fully to the left
	joy_axis(JOY_AXIS_LEFT_X, 0.0)
	# THEN the action's value is 0
	assert_float(_action.value_axis_1d).is_equal_approx(0, 0.01)
	
	# WHEN i move the joy fully to the right
	joy_axis(JOY_AXIS_LEFT_X, 1.0)
	#  AND wait 2 seconds
	await wait_seconds(local_time_scale)
	# THEN the action's value should be clamped at its max
	assert_float(_action.value_axis_1d).is_equal_approx(100, 5.0)
	
	# WHEN i move the joy fully to the left
	joy_axis(JOY_AXIS_LEFT_X, 0.0)
	#  AND wait 0.5 seconds
	await wait_seconds(local_time_scale * 0.5)
	# THEN the action's value should already be near 50.0
	assert_float(_action.value_axis_1d).is_equal_approx(50.0, 5.0)
