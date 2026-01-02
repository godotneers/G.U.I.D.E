extends GUIDETestBase

var _action:GUIDEAction
var _action2:GUIDEAction

func _setup() -> void:
	var context := mapping_context()

	# make one action for the left stick
	_action = action_2d("Action 1")
	var input := input_joy_axis_2d(JOY_AXIS_LEFT_X, JOY_AXIS_LEFT_Y)
	input.joy_index = -2  # First virtual joy pad
	map(context, _action, input)

	# make another one for the right stick
	_action2 = action_2d("Action 2")
	var input2 := input_joy_axis_2d(JOY_AXIS_RIGHT_X, JOY_AXIS_RIGHT_Y)
	input2.joy_index = -2  # First virtual joy pad
	map(context, _action2, input2)

	GUIDE.enable_mapping_context(context)


## Makes a new virtual stick with the given input mode at the given position
## if position is Vector2.INF, it will be placed at a random position
func _make_stick(input_mode:GUIDEVirtualStick.InputMode, stick_position:GUIDEVirtualStick.StickPosition, position:Vector2 = Vector2.INF) -> GUIDEVirtualStick:
	var virtual_stick:GUIDEVirtualStick = auto_free(GUIDEVirtualStick.new())
	virtual_stick.stick_position = stick_position
	virtual_stick.input_mode = input_mode
	add_child(virtual_stick)
	
	if not position.is_finite():
		# move it to a random position
		virtual_stick.position = Vector2(randf() * 800, randf() * 600)
	else:
		virtual_stick.position = position
	
	return virtual_stick


func test_virtual_stick_can_be_touched() -> void:
	var virtual_stick := _make_stick(GUIDEVirtualStick.InputMode.MODE_TOUCH, GUIDEVirtualStick.StickPosition.POSITION_LEFT, Vector2(400,400))
	
	# WHEN i touch the virtual stick and move it to the right
	await finger_down(0, virtual_stick.global_position)
	await finger_move(0, virtual_stick.global_position + Vector2(100, 0))
	
	# THEN the action should be triggered
	assert_is_triggered(_action)
	
	# and its 2D value should be close to 1,0
	assert_axis_2d(_action, Vector2(1, 0))
	
	# WHEN i release the finger
	await finger_up(0)
	
	# THEN the action should be released
	assert_is_not_triggered(_action)

	# AND its value should be back to 0,0
	assert_axis_2d(_action, Vector2.ZERO)


func test_virtual_stick_can_be_moved_with_the_mouse() -> void:
	var virtual_stick := _make_stick(GUIDEVirtualStick.InputMode.MODE_MOUSE, GUIDEVirtualStick.StickPosition.POSITION_LEFT, Vector2(400,400))
	
	# WHEN i click the virtual stick and move it to the right
	await mouse_move_to(virtual_stick.global_position)
	await mouse_down(MOUSE_BUTTON_LEFT)
	await mouse_move_to(virtual_stick.global_position + Vector2(100, 0))
	
	# THEN the action should be triggered
	assert_is_triggered(_action)
	
	# AND its 2D value should be close to 1.0
	assert_axis_2d(_action, Vector2(1, 0))
	
	# WHEN i release the mouse
	await mouse_up(MOUSE_BUTTON_LEFT)
	
	# THEN the action should be released
	assert_is_not_triggered(_action)

	# AND its value should be back to 0,0
	assert_axis_2d(_action, Vector2.ZERO)
	
	
	
func test_multiple_virtual_sticks_can_be_moved_independently_by_touch() -> void:
	var stick1 := _make_stick(GUIDEVirtualStick.InputMode.MODE_TOUCH, GUIDEVirtualStick.StickPosition.POSITION_LEFT, Vector2(400,400))
	var stick2 := _make_stick(GUIDEVirtualStick.InputMode.MODE_TOUCH, GUIDEVirtualStick.StickPosition.POSITION_RIGHT, Vector2(800,400))

	# WHEN i move the first stick to the left
	await finger_down(0, stick1.global_position)
	await finger_move(0, stick1.global_position + Vector2(-100, 0))
	
	# THEN the first action value is -1, 0
	assert_axis_2d(_action, Vector2(-1, 0))
	
	# WHEN i now move the second stick to the right with another finger
	await finger_down(1, stick2.global_position)
	await finger_move(1, stick2.global_position + Vector2(100, 0))
	
	# THEN the second action value is 1, 0
	assert_axis_2d(_action2, Vector2(1, 0))
	
	# AND the first action value is still -1, 0
	assert_axis_2d(_action, Vector2(-1, 0))
	
	# WHEN i now move the first finger to the right and the second to the left
	await finger_move(0, stick1.global_position + Vector2(100, 0))
	await finger_move(1, stick2.global_position + Vector2(-100, 0))

	# THEN the action values follow the finger movement
	assert_axis_2d(_action, Vector2(1, 0))
	assert_axis_2d(_action2, Vector2(-1, 0))


func test_fixed_mode_rejects_outside_actuation_touch_and_mouse() -> void:
	# TOUCH: create a fixed-mode touch stick and touch outside the stick radius
	var stick := _make_stick(GUIDEVirtualStick.InputMode.MODE_MOUSE_AND_TOUCH, GUIDEVirtualStick.StickPosition.POSITION_LEFT, Vector2(400,400))
	stick.position_mode = GUIDEVirtualStick.PositionMode.MODE_FIXED

	# WHEN touch outside of stick_radius (default 100) 
	await finger_down(0, stick.global_position + Vector2(150, 0))
	# THEN the action should not be triggered
	assert_is_not_triggered(_action)
	assert_axis_2d(_action, Vector2.ZERO)
	await finger_up(0)

	# WHEN click outside of stick_radius (default 100)
	await mouse_move_to(stick.global_position + Vector2(150, 0))
	await mouse_down(MOUSE_BUTTON_LEFT)
	# THEN the action should not be triggered
	assert_is_not_triggered(_action)
	assert_axis_2d(_action, Vector2.ZERO)
	await mouse_up(MOUSE_BUTTON_LEFT)


func test_relative_mode_sets_start_position_and_recenters_on_release() -> void:
	# RELATIVE mode should set the start position to the touch point
	var rel_stick := _make_stick(GUIDEVirtualStick.InputMode.MODE_TOUCH, GUIDEVirtualStick.StickPosition.POSITION_LEFT, Vector2(200,200))
	rel_stick.position_mode = GUIDEVirtualStick.PositionMode.MODE_RELATIVE

	# WHEN touch at some point
	await finger_down(0, rel_stick.global_position + Vector2(10, 0))
	# AND move right by 100
	await finger_move(0, rel_stick.global_position + Vector2(110, 0))
	# THEN the action should be triggered with x=1
	assert_is_triggered(_action)
	assert_axis_2d(_action, Vector2(1, 0))

	# WHEN i release the finger
	await finger_up(0)
	# THEN the action should be released and axis recentred
	assert_is_not_triggered(_action)
	assert_axis_2d(_action, Vector2.ZERO)


func test_movement_beyond_max_actuation_radius_clamps_reported_axis() -> void:
	# Use relative mode so start position is the touch point and movement is easy to reason about
	var clamp_stick := _make_stick(GUIDEVirtualStick.InputMode.MODE_TOUCH, GUIDEVirtualStick.StickPosition.POSITION_LEFT, Vector2(300,300))
	clamp_stick.position_mode = GUIDEVirtualStick.PositionMode.MODE_RELATIVE
	# sanity: ensure max_actuation_radius is the default (100)
	assert_float(clamp_stick.max_actuation_radius).is_greater(0)

	# WHEN I touch and move far beyond the max actuation radius
	await finger_down(0, clamp_stick.global_position)
	await finger_move(0, clamp_stick.global_position + Vector2(500, 0))
	
	# THEN the action should be triggered
	assert_is_triggered(_action)
	# AND the reported axis should be clamped to (1,0)
	assert_axis_2d(_action, Vector2(1, 0))
	await finger_up(0)


func test_only_controlling_finger_can_move_the_stick_and_release_stops_updates() -> void:
	var stick := _make_stick(GUIDEVirtualStick.InputMode.MODE_TOUCH, GUIDEVirtualStick.StickPosition.POSITION_LEFT, Vector2(400,400))
	stick.position_mode = GUIDEVirtualStick.PositionMode.MODE_FIXED

	# WHEN finger 0 touches and moves the stick to the right
	await finger_down(0, stick.global_position)
	await finger_move(0, stick.global_position + Vector2(100, 0))
	
	# THEN the action should be triggered and moved to (1,0)
	assert_is_triggered(_action)
	assert_axis_2d(_action, Vector2(1, 0))

	# WHEN a second finger (1) touches and moves the stick to the left
	await finger_down(1, stick.global_position)
	await finger_move(1, stick.global_position + Vector2(-100, 0))
	# THEN the action should still be controlled by finger 0 and remain at (1,0)
	assert_axis_2d(_action, Vector2(1, 0))

	# WHEN finger 0 moves the stick to the left
	await finger_move(0, stick.global_position + Vector2(-100, 0))
	# THEN the action should follow finger 0 again and move to (-1,0)
	assert_axis_2d(_action, Vector2(-1, 0))

	# WHEN finger 0 releases
	await finger_up(0)
	# THEN the action should be released
	assert_is_not_triggered(_action)
	assert_axis_2d(_action, Vector2.ZERO)

	# WHEN finger 1 now moves the stick to the right
	await finger_move(1, stick.global_position + Vector2(100, 0))
	# THEN the action should not be triggered as finger 1 is not controlling the stick
	assert_is_not_triggered(_action)
	assert_axis_2d(_action, Vector2.ZERO)
