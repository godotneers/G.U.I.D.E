extends GUIDETestBase


var _context:GUIDEMappingContext
var _action:GUIDEAction

func _setup() -> void:
	_context = mapping_context()
	_action = action_2d()


func test_pan_gesture_2d_input() -> void:
	var input := input_pan_gesture_2d()
	map(_context, _action, input)

	GUIDE.enable_mapping_context(_context)
	var watched := watch(_action)

	# WHEN
	# i pan diagonally
	await pan_gesture(Vector2(10, 20))

	# THEN
	# the action should be triggered
	await watched.assert_triggered()


func test_pan_gesture_2d_resets_per_frame() -> void:
	var input := input_pan_gesture_2d()
	map(_context, _action, input)

	GUIDE.enable_mapping_context(_context)
	var watched := watch(_action)

	# WHEN
	# i pan and then wait a few frames
	await pan_gesture(Vector2(10, 20))
	await watched.assert_triggered()
	await wait_f(3)

	# THEN
	# the action value should be reset to zero
	assert_axis_2d(_action, Vector2.ZERO, Vector2(0.01, 0.01))
