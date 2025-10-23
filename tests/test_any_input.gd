extends GUIDETestBase

var _context:GUIDEMappingContext
var _action:GUIDEAction

func _setup():
	_context = mapping_context()
	_action = action_bool()

func test_any_input_works_for_mouse_clicks():
	
	var input := input_any()
	input.mouse = true
	map(_context, _action, input)
	GUIDE.enable_mapping_context(_context)
	
	
	# WHEN: i press the mouse button
	await tap_mouse(MOUSE_BUTTON_LEFT)

	# THEN: the action is triggered
	await assert_triggered(_action)
	
	
func test_any_input_works_for_mouse_movement():
	var input := input_any()
	input.mouse_movement = true
	input.minimum_mouse_movement_distance = 2
	map(_context, _action, input)
	GUIDE.enable_mapping_context(_context)
	
	monitor_signals(_action)
	
	# WHEN: i move the mouse
	await mouse_move_by(Vector2(3,3))

	# THEN: the action is triggered
	await assert_triggered(_action)
	

func test_any_input_adheres_to_mouse_minimum_distance():
	var input := input_any()
	input.mouse_movement = true
	input.minimum_mouse_movement_distance = 30
	map(_context, _action, input)
	GUIDE.enable_mapping_context(_context)
	
	# WHEN: i move the mouse just a small bit
	await mouse_move_by(Vector2(3,3))

	# THEN: the action is not triggered
	await assert_not_triggered(_action)
	


func test_any_input_works_with_joy_buttons():
	var input := input_any()
	input.joy_buttons = true
	map(_context, _action, input)
	GUIDE.enable_mapping_context(_context)
	
	# WHEN: i press the joy button
	await tap_joy_button(JOY_BUTTON_A)
	
	# THEN: the action is triggered
	await assert_triggered(_action)
	

func test_any_input_works_with_joy_axis():
	var input := input_any()
	input.joy_axes = true
	map(_context, _action, input)
	GUIDE.enable_mapping_context(_context)
	
	# WHEN: i move the joy axis
	await joy_axis(JOY_AXIS_LEFT_X, 0.5)
	
	# THEN: the action is triggered
	await assert_triggered(_action)
	
	await joy_axis(JOY_AXIS_LEFT_X, 0)
	
func test_any_input_works_with_joy_axis_with_deadzone():
	var input := input_any()
	input.joy_axes = true
	input.minimum_joy_axis_actuation_strength = 0.7
	map(_context, _action, input)
	GUIDE.enable_mapping_context(_context)
	
	# WHEN: i move the joy axis just a bit
	await joy_axis(JOY_AXIS_LEFT_X, 0.5)
	
	# THEN: the action is not triggered
	await assert_not_triggered(_action)

	
func test_any_input_works_with_keyboard():
	var input := input_any()
	input.keyboard = true
	map(_context, _action, input)
	GUIDE.enable_mapping_context(_context)
	
	# WHEN: i press the key
	await tap_key(KEY_Q)
	
	# THEN: the action is triggered
	await assert_triggered(_action)
	
func test_any_input_works_with_touch():
	var input := input_any()
	input.touch = true
	map(_context, _action, input)
	GUIDE.enable_mapping_context(_context)
	
	# WHEN: i press the touch
	await tap_finger(0, Vector2(100, 100))
	
	# THEN: the action is triggered
	await assert_triggered(_action)
	
func test_any_input_handles_queuing_input_correctly():
	var input := input_any()
	input.joy_buttons = true
	
	map(_context, _action, input)
	GUIDE.enable_mapping_context(_context)
	
	# when I actuate a button (and not wait)
	joy_button_down(JOY_BUTTON_A, false)
	
	# and and axis aftwards
	await joy_axis(JOY_AXIS_LEFT_X, 0.1, true) 
	
	# then the action is still triggered
	await assert_triggered(_action)
