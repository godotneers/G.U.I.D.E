extends GUIDETestBase

var _action:GUIDEAction
var _action2:GUIDEAction

func _setup():
	var context := mapping_context()
	_action = action_bool("Action 1")
	var input := input_joy_button(JOY_BUTTON_A)
	input.joy_index = -2  # First virtual joy pad
	map(context, _action, input)
	
	_action2 = action_bool("Action 2")
	var input2 := input_joy_button(JOY_BUTTON_A)
	input2.joy_index = -3  # Second virtual joy pad
	map(context, _action2, input2)
	
	GUIDE.enable_mapping_context(context)

## Makes a new virtual button with the given input mode at the given position
## if position is Vector2.INF, it will be placed at a random position
func _make_button(input_mode:GUIDEVirtualButton.InputMode, position:Vector2 = Vector2.INF) -> GUIDEVirtualButton:
	var virtual_button:GUIDEVirtualButton = auto_free(GUIDEVirtualButton.new())
	virtual_button.button_index = JOY_BUTTON_A
	virtual_button.input_mode = input_mode
	add_child(virtual_button)
	
	if not position.is_finite():
		# move it to a random position // ensure it's fully on screen
		virtual_button.position = Vector2(randf() * 800, randf() * 600) + Vector2(virtual_button.button_radius, virtual_button.button_radius)
	else:
		virtual_button.position = position
	
	return virtual_button

func test_virtual_button_can_be_touched():
	var virtual_button := _make_button(GUIDEVirtualButton.InputMode.TOUCH)
	# WHEN i touch the virtual button
	await tap_finger(0, virtual_button.global_position)
	# THEN the action is triggered
	await assert_triggered(_action)
	
	
func test_virtual_button_can_be_clicked():
	var virtual_button := _make_button(GUIDEVirtualButton.InputMode.MOUSE)

	# WHEN i click the virtual button
	await tap_mouse_at(MOUSE_BUTTON_LEFT, virtual_button.global_position)
	# THEN the action is triggered
	await assert_triggered(_action)


func test_virtual_button_can_be_clicked_and_touched():
	var virtual_button := _make_button(GUIDEVirtualButton.InputMode.MOUSE_AND_TOUCH)

	# WHEN i click the virtual button
	await tap_mouse_at(MOUSE_BUTTON_LEFT, virtual_button.global_position)

	# THEN the action is triggered
	await assert_triggered(_action)
	
	reset_signal_watcher(_action)

	# WHEN i touch the virtual button
	await tap_finger(0, virtual_button.global_position)
	
	# THEN the action is triggered
	await assert_triggered(_action)
		
func test_virtual_button_stops_actuation_when_last_finger_moves_out():
	var virtual_button := _make_button(GUIDEVirtualButton.InputMode.TOUCH)

	# WHEN i touch the virtual button with two fingers
	await finger_down(0, virtual_button.global_position)
	await finger_down(1, virtual_button.global_position + Vector2(10,10))
	
	# THEN the action is triggered
	assert_is_triggered(_action)
	
	# WHEN i move the first finger out of the button area
	await finger_move(0, virtual_button.global_position + Vector2(virtual_button.button_radius + 50, 0))
	
	# THEN the action is NOT released yet
	assert_is_triggered(_action)
	
	# WHEN i move the second finger out of the button area
	await finger_move(1, virtual_button.global_position + Vector2(virtual_button.button_radius + 50, 0))
	
	# THEN the action is no longer triggered
	assert_is_not_triggered(_action)
	
	await finger_up(0)
	await finger_up(1)


func test_virtual_button_stops_actuation_when_mouse_moves_out():
	var virtual_button := _make_button(GUIDEVirtualButton.InputMode.MOUSE, Vector2(400,400))

	# WHEN i move the mouse over the button and press
	await mouse_move_to(virtual_button.global_position)
	await mouse_down(MOUSE_BUTTON_LEFT)
	
	# THEN the action is triggered
	assert_is_triggered(_action)
	
	# WHEN i move it out, while keeping the button pressed
	await mouse_move_by(Vector2(virtual_button.button_radius + 50, 0))
	
	# THEN the action is no longer triggered
	assert_is_not_triggered(_action)
	
	await mouse_up(MOUSE_BUTTON_LEFT)


func test_multiple_virtual_buttons_on_different_devices_dont_interfere():
	var virtual_button1 := _make_button(GUIDEVirtualButton.InputMode.TOUCH, Vector2(200,200))
	virtual_button1.virtual_device = 0  # First virtual joy pad
	
	var virtual_button2 := _make_button(GUIDEVirtualButton.InputMode.TOUCH, Vector2(600,400))
	virtual_button2.virtual_device = 1  # Second virtual joy pad

	# WHEN i tap the first virtual button
	await finger_down(0, virtual_button1.global_position)
	
	# THEN only the first action is triggered
	assert_is_triggered(_action)
	assert_is_not_triggered(_action2)
	
	# WHEN i tap the second virtual button	
	await finger_down(1, virtual_button2.global_position)
	
	# THEN both actions are triggered
	assert_is_triggered(_action)
	assert_is_triggered(_action2)
	
	# WHEN i release the second finger
	await finger_up(1)
	
	# THEN only the first action still triggered
	assert_is_triggered(_action)
	assert_is_not_triggered(_action2)
	
	# WHEN i release the first finger
	await finger_up(0)
	# THEN no action is triggered
	assert_is_not_triggered(_action)
	assert_is_not_triggered(_action2)
	
		
func test_moving_mouse_while_clicking_updates_hit_test():
	var virtual_button := _make_button(GUIDEVirtualButton.InputMode.MOUSE, Vector2(400,400))		

	# WHEN i start clicking outside the button area
	await mouse_move_to(Vector2(0, 400))
	await mouse_down(MOUSE_BUTTON_LEFT)
	
	# THEN the action is not triggered
	assert_is_not_triggered(_action)
	
	# WHEN i move the mouse over the button area while keeping the button pressed
	await mouse_move_to(virtual_button.global_position)
	
	# THEN the action is triggered
	assert_is_triggered(_action)
	
	# WHEN i move the mouse out of the button area while keeping the button pressed
	await mouse_move_to(Vector2(800, 400))
	
	# THEN the action is no longer triggered
	assert_is_not_triggered(_action)

	await mouse_up(MOUSE_BUTTON_LEFT)
	
	
func test_moving_finger_while_pressing_updates_hit_test():
	var virtual_button := _make_button(GUIDEVirtualButton.InputMode.TOUCH, Vector2(400,400))

	# WHEN i start touching outside the button area
	await finger_down(0, Vector2(0, 400))

	# THEN the action is not triggered
	assert_is_not_triggered(_action)

	# WHEN i move the finger over the button area while keeping it pressed
	await finger_move(0, virtual_button.global_position)

	# THEN the action is triggered
	assert_is_triggered(_action)

	# WHEN i move the finger out of the button area while keeping it pressed
	await finger_move(0, Vector2(800, 400))

	# THEN the action is no longer triggered
	assert_is_not_triggered(_action)

	await finger_up(0)	
