extends GUIDETestBase


var _context:GUIDEMappingContext
var _action:GUIDEAction
var _action_2d:GUIDEAction
var _action_3d:GUIDEAction

var _time_scale := 0.25

func _setup():
	_context = mapping_context()
	_action = action_1d()
	_action_2d = action_2d()
	_action_3d = action_3d()


func test_modifier_works_linearly():
	var input := input_joy_axis_1d(JOY_AXIS_LEFT_X)
	var modifier := modifier_accumulator(0.0, 100.0, _time_scale)
	map(_context, _action, input, [modifier])
	GUIDE.enable_mapping_context(_context)
	
	# WHEN i haven't moved the joy
	joy_axis(JOY_AXIS_LEFT_X, 0.0)
	# THEN the action's value is initialized at the start value of 0
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
	#  AND wait 0.5 seconds
	await wait_seconds(_time_scale * 0.5)
	# THEN the action's value is back down to 50
	assert_float(_action.value_axis_1d).is_equal_approx(50, 5.0)

	# WHEN i wait 0.5 more seconds
	await wait_seconds(_time_scale)
	# THEN the action's value is back to 0
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
	#  AND wait 0.25 seconds
	await wait_seconds(_time_scale * 0.25)
	# THEN the action's value is down to 25
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

func test_modifier_can_decrease_at_limit():
	var input := input_joy_axis_1d(JOY_AXIS_LEFT_X)
	var modifier := modifier_accumulator(0.0, \
		100.0, \
		_time_scale, \
		1.0, \
		GUIDEModifierAccumulator.DecreaseCondition.DECREASE_AT_LIMIT, \
		GUIDEModifierAccumulator.ReadyCondition.ONLY_AFTER_RESET)
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
	
	# WHEN i move keep the joy fully to the right
	await joy_axis(JOY_AXIS_LEFT_X, 1.0)
	#  AND wait 0.5 seconds
	await wait_seconds(_time_scale * 0.5)
	# THEN the action's value has decreased back to 0
	assert_float(_action.value_axis_1d).is_equal_approx(50, 5.0)

func test_modifier_can_reset_on_release():
	var input := input_joy_axis_1d(JOY_AXIS_LEFT_X)
	var modifier := modifier_accumulator(0.0, 100.0, _time_scale, 1.0, GUIDEModifierAccumulator.DecreaseCondition.RESET_ON_RELEASE)
	map(_context, _action, input, [modifier])
	GUIDE.enable_mapping_context(_context)
	
	# WHEN i move the joy fully to the left
	joy_axis(JOY_AXIS_LEFT_X, 0.0)
	# THEN the action's value is 0
	assert_float(_action.value_axis_1d).is_equal_approx(0, 0.01)
	
	# WHEN i move the joy fully to the right
	joy_axis(JOY_AXIS_LEFT_X, 1.0)
	#  AND wait 1.5 second
	await wait_seconds(_time_scale * 1.5)
	# THEN the action's value stays at 100
	assert_float(_action.value_axis_1d).is_equal_approx(100, 5.0)
	
	# WHEN i release the joy fully
	await joy_axis(JOY_AXIS_LEFT_X, 0)
	#  AND wait only 0.1 seconds
	await wait_seconds(_time_scale * 0.1)
	# THEN the action's value has reset to 0
	assert_float(_action.value_axis_1d).is_equal_approx(0, 0.01)

func test_modifier_can_reset_at_limit():
	var input := input_joy_axis_1d(JOY_AXIS_LEFT_X)
	var modifier := modifier_accumulator(0.0, 100.0, _time_scale, 1.0, GUIDEModifierAccumulator.DecreaseCondition.RESET_AT_LIMIT)
	map(_context, _action, input, [modifier])
	GUIDE.enable_mapping_context(_context)
	
	# WHEN i move the joy fully to the left
	joy_axis(JOY_AXIS_LEFT_X, 0.0)
	# THEN the action's value is 0
	assert_float(_action.value_axis_1d).is_equal_approx(0, 0.01)
	
	# WHEN i move the joy fully to the right
	joy_axis(JOY_AXIS_LEFT_X, 1.0)
	#  AND wait 1 second
	await wait_seconds(_time_scale * 0.95)
	# THEN the action's value is 100
	assert_float(_action.value_axis_1d).is_equal_approx(95, 5.0)
	
	# WHEN i move keep the joy fully to the left
	await joy_axis(JOY_AXIS_LEFT_X, 1.0)
	#  AND wait only 0.1 seconds
	await wait_seconds(_time_scale * 0.1)
	# THEN the action's value has decrease to 0
	assert_float(_action.value_axis_1d).is_equal_approx(5, 5.0)

func test_modifier_can_prevent_accumulation_after_full():
	var input := input_joy_axis_1d(JOY_AXIS_LEFT_X)
	var modifier := modifier_accumulator(0.0, \
			100.0, \
			_time_scale, \
			1.0, \
			GUIDEModifierAccumulator.DecreaseCondition.DECREASE_ON_RELEASE, \
			GUIDEModifierAccumulator.ReadyCondition.WHEN_FULL_AFTER_RESET)
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
	# WHEN i wait 0.25 more seconds
	await wait_seconds(_time_scale * 0.25)
	# THEN the action's value is still at 100
	assert_float(_action.value_axis_1d).is_equal_approx(100, 1.0)
	
	# WHEN i reset the joy
	await joy_axis(JOY_AXIS_LEFT_X, 0.0)
	#  AND wait only 0.05 seconds
	await wait_seconds(_time_scale * 0.05)
	#  AND move the joy fully to the right again
	await joy_axis(JOY_AXIS_LEFT_X, 1.0)
	#  AND wait only 0.1 seconds
	await wait_seconds(_time_scale * 0.15)
	# THEN the action's value is still decreasing
	assert_float(_action.value_axis_1d).is_equal_approx(75, 5.0)

func test_modifier_can_prevent_accumulation_on_release():
	var input := input_joy_axis_1d(JOY_AXIS_LEFT_X)
	var modifier := modifier_accumulator(0.0, \
			100.0, \
			_time_scale, \
			1.0, \
			GUIDEModifierAccumulator.DecreaseCondition.DECREASE_ON_RELEASE, \
			GUIDEModifierAccumulator.ReadyCondition.ONLY_AFTER_RESET)
	map(_context, _action, input, [modifier])
	GUIDE.enable_mapping_context(_context)
	
	# WHEN i move the joy fully to the left
	joy_axis(JOY_AXIS_LEFT_X, 0.0)
	# THEN the action's value is 0
	assert_float(_action.value_axis_1d).is_equal_approx(0, 0.01)
	
	# WHEN i move the joy fully to the right
	joy_axis(JOY_AXIS_LEFT_X, 1.0)
	#  AND wait only 0.5 seconds
	await wait_seconds(_time_scale * 0.5)
	# THEN the action's value is 100
	assert_float(_action.value_axis_1d).is_equal_approx(50, 5.0)
	
	# WHEN i reset the joy
	await joy_axis(JOY_AXIS_LEFT_X, 0.0)
	#  AND wait only 0.05 seconds
	await wait_seconds(_time_scale * 0.05)
	#  AND move the joy fully to the right again
	await joy_axis(JOY_AXIS_LEFT_X, 1.0)
	#  AND wait only 0.15 seconds
	await wait_seconds(_time_scale * 0.15)
	# THEN the action's value is still decreasing
	assert_float(_action.value_axis_1d).is_equal_approx(20, 5.0)

func test_modifier_can_modify_a_specific_axis():
	var input := input_joy_axis_2d(JOY_AXIS_LEFT_X, JOY_AXIS_LEFT_Y)
	var modifier := modifier_accumulator(0.0, \
		-100.0, \
		_time_scale, \
		1.0, \
		GUIDEModifierAccumulator.DecreaseCondition.DECREASE_ON_RELEASE, \
		GUIDEModifierAccumulator.ReadyCondition.ALWAYS, \
		GUIDEModifierAccumulator.InputAxis.Y\
		)
	map(_context, _action, input, [modifier])
	GUIDE.enable_mapping_context(_context)
	
	# WHEN i move the joy fully to the left
	joy_axis(JOY_AXIS_LEFT_Y, 0.0)
	# THEN the action's value is 0
	assert_float(_action.value_axis_1d).is_equal_approx(0, 0.01)
	
	# WHEN i move the joy fully to the right
	joy_axis(JOY_AXIS_LEFT_Y, 1.0)
	#  AND wait 0.5 seconds
	await wait_seconds(_time_scale * 0.5)
	# THEN the action's value is -50
	assert_float(_action.value_axis_1d).is_equal_approx(-50, 5.0)

	# WHEN i wait 0.5 more seconds
	await wait_seconds(_time_scale * 0.5)
	# THEN the action's value is -100
	assert_float(_action.value_axis_1d).is_equal_approx(-100, 5.0)

	# WHEN i move the joy fully to the left
	joy_axis(JOY_AXIS_LEFT_Y, 0.0)
	#  AND wait 1 second
	await wait_seconds(_time_scale)
	# THEN the action's value is 0
	assert_float(_action.value_axis_1d).is_equal_approx(0, 5.0)

func test_modifier_can_output_value_on_different_axis():
	var input := input_joy_axis_2d(JOY_AXIS_LEFT_X, JOY_AXIS_LEFT_X)
	var modifier := modifier_accumulator(0.0, \
		100.0, \
		_time_scale, \
		1.0, \
		GUIDEModifierAccumulator.DecreaseCondition.DECREASE_ON_RELEASE, \
		GUIDEModifierAccumulator.ReadyCondition.ONLY_AFTER_RESET, \
		GUIDEModifierAccumulator.InputAxis.X, \
		GUIDEModifierAccumulator.AxisRole.UNCHANGED, \
		GUIDEModifierAccumulator.AxisRole.VALUE)
	map(_context, _action_2d, input, [modifier])
	GUIDE.enable_mapping_context(_context)
	
	# WHEN i haven't moved the joy
	joy_axis(JOY_AXIS_LEFT_X, 0.0)
	# THEN the action's value is initialized at the start value of 0
	assert_float(_action_2d.value_axis_2d.x).is_equal_approx(0, 0.01)
	assert_float(_action_2d.value_axis_2d.y).is_equal_approx(0, 0.01)
	
	# WHEN i move the joy fully to the right
	joy_axis(JOY_AXIS_LEFT_X, 1.0)
	#  AND wait 0.5 seconds
	await wait_seconds(_time_scale * 0.5)
	
	# THEN the action's value is 50 on the y-axis
	#  AND the x-axis is preserved
	assert_float(_action_2d.value_axis_2d.x).is_equal_approx(1.0, 0.01)
	assert_float(_action_2d.value_axis_2d.y).is_equal_approx(50, 5.0)

	# WHEN i wait 0.5 more seconds
	await wait_seconds(_time_scale * 0.5)
	# THEN the action's value is 100
	#  AND the x-axis is preserved
	assert_float(_action_2d.value_axis_2d.x).is_equal_approx(1.0, 0.01)
	assert_float(_action_2d.value_axis_2d.y).is_equal_approx(100, 5.0)

	# WHEN i move the joy fully to the left
	joy_axis(JOY_AXIS_LEFT_X, 0.0)
	#  AND wait 0.5 seconds
	await wait_seconds(_time_scale * 0.5)
	# THEN the action's value is back down to 50
	#  AND the x-axis is preserved
	assert_float(_action_2d.value_axis_2d.x).is_equal_approx(0.0, 0.01)
	assert_float(_action_2d.value_axis_2d.y).is_equal_approx(50, 5.0)

	# WHEN i wait 0.5 more seconds
	await wait_seconds(_time_scale)
	# THEN the action's value is back to 0
	#  AND the x-axis is preserved
	assert_float(_action_2d.value_axis_2d.x).is_equal_approx(0.0, 0.01)
	assert_float(_action_2d.value_axis_2d.y).is_equal_approx(0, 5.0)

func test_modifier_can_output_all_state_on_axis():
	var input := input_joy_axis_2d(JOY_AXIS_LEFT_X, JOY_AXIS_LEFT_X)
	var modifier := modifier_accumulator(0.0, \
		100.0, \
		_time_scale, \
		1.0, \
		GUIDEModifierAccumulator.DecreaseCondition.DECREASE_ON_RELEASE, \
		GUIDEModifierAccumulator.ReadyCondition.WHEN_FULL_AFTER_RESET, \
		GUIDEModifierAccumulator.InputAxis.X, \
		GUIDEModifierAccumulator.AxisRole.READY_STATE, \
		GUIDEModifierAccumulator.AxisRole.TIME_ELAPSED, \
		GUIDEModifierAccumulator.AxisRole.VALUE)
	map(_context, _action_3d, input, [modifier])
	GUIDE.enable_mapping_context(_context)
	
	# WHEN i haven't moved the joy
	joy_axis(JOY_AXIS_LEFT_X, 0.0)
	await wait_f(1)
	# THEN the modifier's state is initialized on all axis
	assert_float(_action_3d.value_axis_3d.x).is_equal_approx(1.0, 0.01)
	assert_float(_action_3d.value_axis_3d.y).is_equal_approx(0, 0.01)
	assert_float(_action_3d.value_axis_3d.z).is_equal_approx(0, 0.01)
	
	# WHEN i move the joy fully to the right
	joy_axis(JOY_AXIS_LEFT_X, 1.0)
	#  AND wait 0.5 seconds
	await wait_seconds(_time_scale * 0.5)
	# THEN the action's value is 50 on the z-axis
	assert_float(_action_3d.value_axis_3d.x).is_equal_approx(1.0, 0.01)
	assert_float(_action_3d.value_axis_3d.y).is_equal_approx(_time_scale * 0.5, 0.1)
	assert_float(_action_3d.value_axis_3d.z).is_equal_approx(50.0, 5.0)

	# WHEN i wait 0.5 more seconds
	await wait_seconds(_time_scale * 0.5)
	# THEN the action's value is 100
	assert_float(_action_3d.value_axis_3d.x).is_equal_approx(1.0, 0.01)
	assert_float(_action_3d.value_axis_3d.y).is_equal_approx(_time_scale, 0.1)
	assert_float(_action_3d.value_axis_3d.z).is_equal_approx(100.0, 5.0)

	# WHEN i move the joy fully to the left
	joy_axis(JOY_AXIS_LEFT_X, 0.0)
	#  AND wait 0.5 seconds
	await wait_seconds(_time_scale * 0.5)
	# THEN the action's value has decreased to 50
	#  AND the elapsed time is half of the total time
	#  AND the ready state is reset
	assert_float(_action_3d.value_axis_3d.x).is_equal_approx(0.0, 0.01)
	assert_float(_action_3d.value_axis_3d.y).is_equal_approx(_time_scale * 0.5, 0.1)
	assert_float(_action_3d.value_axis_3d.z).is_equal_approx(50.0, 5.0)

	# WHEN wait 0.5 more seconds
	await wait_seconds(_time_scale * 0.5)
	# THEN the action's value is back down to 0
	#  AND the elapsed time is zero
	#  AND the ready state is ready again
	assert_float(_action_3d.value_axis_3d.x).is_equal_approx(1.0, 0.01)
	assert_float(_action_3d.value_axis_3d.y).is_equal_approx(0.0, 0.1)
	assert_float(_action_3d.value_axis_3d.z).is_equal_approx(0.0, 5.0)
