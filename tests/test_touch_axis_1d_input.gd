extends GUIDETestBase


var _context:GUIDEMappingContext
var _action:GUIDEAction

func _setup() -> void:
	_context = mapping_context()
	_action = action_1d()

func test_touch_axis_1d_input() -> void:
	var input := input_touch_axis_1d(GUIDEInputTouchAxis1D.GUIDEInputTouchAxis.AXIS_X)
	map(_context, _action, input)
	
	GUIDE.enable_mapping_context(_context)
	
	# WHEN
	# I move my finger on the screen
	await finger_down(0, Vector2(50, 50))
	await finger_move(0, Vector2(100, 0))
	
	# THEN
	# the action is triggered
	await assert_triggered(_action)
