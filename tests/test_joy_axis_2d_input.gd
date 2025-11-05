extends GUIDETestBase


var _context:GUIDEMappingContext
var _action:GUIDEAction

func _setup() -> void:
	_context = mapping_context()
	_action = action_2d()

func test_joy_axis_2d_input() -> void:
	var input := input_joy_axis_2d(JOY_AXIS_LEFT_X, JOY_AXIS_LEFT_Y)
	map(_context, _action, input)
	
	GUIDE.enable_mapping_context(_context)
	
	# WHEN
	# I actuate the left joystick
	joy_axis(JOY_AXIS_LEFT_X, -0.5, false)
	await joy_axis(JOY_AXIS_LEFT_Y, 0.5)
	
	# THEN
	# the action is triggered
	await assert_triggered(_action)
	
	# and the value is correct
	assert_vector(_action.value_axis_2d).is_equal(Vector2(-0.5, 0.5))
	
