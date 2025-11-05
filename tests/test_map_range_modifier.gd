extends GUIDETestBase


var _context:GUIDEMappingContext
var _action:GUIDEAction

func _setup() -> void:
	_context = mapping_context()
	_action = action_1d()
	
	
func test_modifier_works_if_both_ranges_are_ascending() -> void:
	var input := input_joy_axis_1d(JOY_AXIS_LEFT_X)
	var modifier := modifier_map_range(-1, 1, 0, 100)
	map(_context, _action, input, [modifier])
	GUIDE.enable_mapping_context(_context)
	
	# when i move the joy fully to the left
	await joy_axis(JOY_AXIS_LEFT_X, -1)
	# then the action's value is 0
	assert_float(_action.value_axis_1d).is_equal_approx(0, 0.01)
	
	# when i move the joy fully to the right
	await joy_axis(JOY_AXIS_LEFT_X, 1)
	# then the action's value is 100
	assert_float(_action.value_axis_1d).is_equal_approx(100, 0.01)

	
func test_modifier_works_if_output_range_is_descending() -> void:
	var input := input_joy_axis_1d(JOY_AXIS_LEFT_X)
	var modifier := modifier_map_range(-1, 1, 100, 0)
	map(_context, _action, input, [modifier])
	GUIDE.enable_mapping_context(_context)
	
	# when i move the joy fully to the left
	await joy_axis(JOY_AXIS_LEFT_X, -1)
	# then the action's value is 100
	assert_float(_action.value_axis_1d).is_equal_approx(100, 0.01)
	
	# when i move the joy fully to the right
	await joy_axis(JOY_AXIS_LEFT_X, 1)
	# then the action's value is 0
	assert_float(_action.value_axis_1d).is_equal_approx(0, 0.01)
	

func test_modifier_works_if_input_range_is_descending() -> void:
	var input := input_joy_axis_1d(JOY_AXIS_LEFT_X)
	var modifier := modifier_map_range(1, -1, 0, 100)
	map(_context, _action, input, [modifier])
	GUIDE.enable_mapping_context(_context)
	
	# when i move the joy fully to the left
	await joy_axis(JOY_AXIS_LEFT_X, -1)
	# then the action's value is 100
	assert_float(_action.value_axis_1d).is_equal_approx(100, 0.01)
	
	# when i move the joy fully to the right
	await joy_axis(JOY_AXIS_LEFT_X, 1)
	# then the action's value is 0
	assert_float(_action.value_axis_1d).is_equal_approx(0, 0.01)
	

func test_modifier_works_if_both_ranges_are_descending() -> void:
	var input := input_joy_axis_1d(JOY_AXIS_LEFT_X)
	var modifier := modifier_map_range(1, -1, 100, 0)
	map(_context, _action, input, [modifier])
	GUIDE.enable_mapping_context(_context)
	
	# when i move the joy fully to the left
	await joy_axis(JOY_AXIS_LEFT_X, -1)
	# then the action's value is 0
	assert_float(_action.value_axis_1d).is_equal_approx(0, 0.01)
	
	# when i move the joy fully to the right
	await joy_axis(JOY_AXIS_LEFT_X, 1)
	# then the action's value is 100
	assert_float(_action.value_axis_1d).is_equal_approx(100, 0.01)

	
func test_modifier_works_with_purely_negative_ranges() -> void:
	var input := input_joy_axis_1d(JOY_AXIS_LEFT_X)
	var modifier := modifier_map_range(-2, -1, -100, -50)
	map(_context, _action, input, [modifier])
	GUIDE.enable_mapping_context(_context)
	
	# when i move the joy fully to the left
	await joy_axis(JOY_AXIS_LEFT_X, -2)
	# then the action's value is -100
	assert_float(_action.value_axis_1d).is_equal_approx(-100, 0.01)
	
	# when i move the joy fully to the right
	await joy_axis(JOY_AXIS_LEFT_X, -1)
	# then the action's value is -50
	assert_float(_action.value_axis_1d).is_equal_approx(-50, 0.01)
