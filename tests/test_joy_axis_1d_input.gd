extends GUIDETestBase


var _context:GUIDEMappingContext
var _action:GUIDEAction

func _setup() -> void:
	_context = mapping_context()
	_action = action_1d()

func test_joy_axis_1d_input() -> void:
	var input := input_joy_axis_1d(JOY_AXIS_LEFT_X)
	map(_context, _action, input)

	GUIDE.enable_mapping_context(_context)
	var watched := watch(_action)

	# WHEN
	# I actuate the left joystick
	await joy_axis(JOY_AXIS_LEFT_X, -0.5)

	# THEN
	# the action is triggered
	await watched.assert_triggered()
	
	# and the value is correct
	assert_float(_action.value_axis_1d).is_equal(-0.5)
		
func test_joy_axis_1d_input_ignores_other_axis() -> void:
	var input := input_joy_axis_1d(JOY_AXIS_LEFT_X)
	map(_context, _action, input)

	GUIDE.enable_mapping_context(_context)
	var watched := watch(_action)

	# WHEN
	# I actuate the right joystick
	await joy_axis(JOY_AXIS_LEFT_Y, -0.5)

	# THEN
	# the action is not triggered
	watched.assert_not_triggered()
	
	# and the value is unchanged
	assert_float(_action.value_axis_1d).is_equal(0.0)
	
