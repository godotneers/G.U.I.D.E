extends GUIDETestBase


var _context:GUIDEMappingContext
var _action:GUIDEAction

func _setup() -> void:
	_context = mapping_context()
	_action = action_1d()
	

func test_modifier_returns_zero_for_center() -> void:
	var input: GUIDEInputJoyAxis2D = input_joy_axis_2d(JOY_AXIS_LEFT_X, JOY_AXIS_LEFT_Y)
	var modifier := GUIDEModifierMagnitude.new()
	map(_context, _action, input, [modifier])
	GUIDE.enable_mapping_context(_context)
	
	# when the joystick is centered
	joy_axis(JOY_AXIS_LEFT_X, 0.0, false)
	await joy_axis(JOY_AXIS_LEFT_Y, 0.0)
	# then the action's value is 0
	assert_float(_action.value_axis_1d).is_equal_approx(0.0, 0.01)


func test_modifier_returns_length_for_unit_axes() -> void:
	var input: GUIDEInputJoyAxis2D = input_joy_axis_2d(JOY_AXIS_LEFT_X, JOY_AXIS_LEFT_Y)
	var modifier := GUIDEModifierMagnitude.new()
	map(_context, _action, input, [modifier])
	GUIDE.enable_mapping_context(_context)
	
	# when I move the joystick fully to the right
	joy_axis(JOY_AXIS_LEFT_X, 1.0, false)
	await joy_axis(JOY_AXIS_LEFT_Y, 0.0)
	# then the action's value is 1
	assert_float(_action.value_axis_1d).is_equal_approx(1.0, 0.01)
	
	# when I move the joystick fully up
	joy_axis(JOY_AXIS_LEFT_X, 0.0, false)
	await joy_axis(JOY_AXIS_LEFT_Y, 1.0)
	# then the action's value is 1
	assert_float(_action.value_axis_1d).is_equal_approx(1.0, 0.01)


func test_modifier_returns_pythagorean_length() -> void:
	var input: GUIDEInputJoyAxis2D = input_joy_axis_2d(JOY_AXIS_LEFT_X, JOY_AXIS_LEFT_Y)
	var modifier := GUIDEModifierMagnitude.new()
	map(_context, _action, input, [modifier])
	GUIDE.enable_mapping_context(_context)
	
	# when I move the joystick to the top-right corner
	joy_axis(JOY_AXIS_LEFT_X, 1.0, false)
	await joy_axis(JOY_AXIS_LEFT_Y, 1.0)
	# then the action's value is sqrt(2)
	assert_float(_action.value_axis_1d).is_equal_approx(sqrt(2.0), 0.01)
	
	# when I move the joystick to the bottom-left corner
	joy_axis(JOY_AXIS_LEFT_X, -1.0, false)
	await joy_axis(JOY_AXIS_LEFT_Y, -1.0)
	# then the action's value is still sqrt(2) because magnitude ignores direction
	assert_float(_action.value_axis_1d).is_equal_approx(sqrt(2.0), 0.01)
