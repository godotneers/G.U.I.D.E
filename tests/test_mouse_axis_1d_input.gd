extends GUIDETestBase


var _context:GUIDEMappingContext
var _action:GUIDEAction

func _setup():
	_context = mapping_context()
	_action = action_1d()

func test_mouse_axis1d_input_x():
	var input := input_mouse_axis_1d(GUIDEInputMouseAxis1D.GUIDEInputMouseAxis.X)
	map(_context, _action, input)
	
	GUIDE.enable_mapping_context(_context)
	
	# WHEN
	# i move the mouse
	await mouse_move_by(Vector2(-10, 0))
	
	# THEN
	# the action should be triggered
	await assert_triggered(_action)

func test_mouse_axis1d_input_y():
	var input := input_mouse_axis_1d(GUIDEInputMouseAxis1D.GUIDEInputMouseAxis.Y)
	map(_context, _action, input)
	
	GUIDE.enable_mapping_context(_context)
	
	# WHEN
	# i move the mouse
	await mouse_move_by(Vector2(0, 10))
	
	# THEN
	# the action should be triggered
	await assert_triggered(_action)


func test_mouse_axis1d_input_ignores_other_axis_x():
	var input := input_mouse_axis_1d(GUIDEInputMouseAxis1D.GUIDEInputMouseAxis.X)
	map(_context, _action, input)

	GUIDE.enable_mapping_context(_context)

	# WHEN
	# i move the mouse
	await mouse_move_by(Vector2(0, -10))

	# THEN
	# the action should not be triggered
	await assert_not_triggered(_action)
	
func test_mouse_axis1d_input_ignores_other_axis_y():
	var input := input_mouse_axis_1d(GUIDEInputMouseAxis1D.GUIDEInputMouseAxis.Y)
	map(_context, _action, input)

	GUIDE.enable_mapping_context(_context)

	# WHEN
	# i move the mouse
	await mouse_move_by(Vector2(10, 0))

	# THEN
	# the action should not be triggered
	await assert_not_triggered(_action)	
