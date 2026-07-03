extends GUIDETestBase


var _context:GUIDEMappingContext
var _action:GUIDEAction

func _setup() -> void:
	_context = mapping_context()
	_action = action_1d()


func test_pan_gesture_1d_input_x() -> void:
	var input := input_pan_gesture_1d(GUIDEInputPanGesture1D.GUIDEInputPanGestureAxis.X)
	map(_context, _action, input)

	GUIDE.enable_mapping_context(_context)
	var watched := watch(_action)

	# WHEN
	# i pan horizontally
	await pan_gesture(Vector2(10, 0))

	# THEN
	# the action should be triggered
	await watched.assert_triggered()

func test_pan_gesture_1d_input_y() -> void:
	var input := input_pan_gesture_1d(GUIDEInputPanGesture1D.GUIDEInputPanGestureAxis.Y)
	map(_context, _action, input)

	GUIDE.enable_mapping_context(_context)
	var watched := watch(_action)

	# WHEN
	# i pan vertically
	await pan_gesture(Vector2(0, 10))

	# THEN
	# the action should be triggered
	await watched.assert_triggered()


func test_pan_gesture_1d_input_ignores_other_axis_x() -> void:
	var input := input_pan_gesture_1d(GUIDEInputPanGesture1D.GUIDEInputPanGestureAxis.X)
	map(_context, _action, input)

	GUIDE.enable_mapping_context(_context)
	# wait for any initial events to drop
	await wait_f(5)
	var watched := watch(_action)

	# WHEN
	# i pan vertically
	await pan_gesture(Vector2(0, 10))

	# THEN
	# the action should not be triggered
	watched.assert_not_triggered()

func test_pan_gesture_1d_input_ignores_other_axis_y() -> void:
	var input := input_pan_gesture_1d(GUIDEInputPanGesture1D.GUIDEInputPanGestureAxis.Y)
	map(_context, _action, input)

	GUIDE.enable_mapping_context(_context)
	# wait for any initial events to drop
	await wait_f(5)
	var watched := watch(_action)

	# WHEN
	# i pan horizontally
	await pan_gesture(Vector2(10, 0))

	# THEN
	# the action should not be triggered
	watched.assert_not_triggered()


func test_pan_gesture_1d_resets_per_frame() -> void:
	var input := input_pan_gesture_1d(GUIDEInputPanGesture1D.GUIDEInputPanGestureAxis.X)
	map(_context, _action, input)

	GUIDE.enable_mapping_context(_context)
	var watched := watch(_action)

	# WHEN
	# i pan and then wait a few frames
	await pan_gesture(Vector2(10, 0))
	await watched.assert_triggered()
	await wait_f(3)

	# THEN
	# the action value should be reset to zero
	assert_axis_1d(_action, 0.0)
