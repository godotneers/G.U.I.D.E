extends GUIDETestBase


var _context:GUIDEMappingContext
var _action:GUIDEAction

func _setup() -> void:
	_context = mapping_context()
	_action = action_1d()

func test_touch_angle_input() -> void:
	var input := input_touch_angle()
	input.unit = GUIDEInputTouchAngle.AngleUnit.DEGREES
	map(_context, _action, input)
	
	GUIDE.enable_mapping_context(_context)
	var watched := watch(_action)

	var holder:Array[float] = [0.0]
	_action.triggered.connect(func() -> void: holder[0] = _action.value_axis_1d)

	# WHEN
	# I rotate my fingers 90 degrees
	await finger_down(0, Vector2(50, 50))
	await finger_down(1, Vector2(100, 50))
	await finger_move(1, Vector2(50, 0))

	# THEN
	# the action is triggered
	await watched.assert_triggered()
	
	# and the value is 90 degrees
	assert_float(holder[0]).is_equal_approx(90, 0.5)