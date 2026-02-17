extends GUIDETestBase

var _context:GUIDEMappingContext
var _action:GUIDEAction

func _setup() -> void:
	_context = mapping_context()
	_action = action_bool()

func test_any_input_works_for_mouse_clicks() -> void:
	
	var input := input_any()
	input.mouse = true
	map(_context, _action, input)
	GUIDE.enable_mapping_context(_context)
	
	
	# WHEN: i press the mouse button
	await tap_mouse(MOUSE_BUTTON_LEFT)

	# THEN: the action is triggered
	await assert_triggered(_action)
	
	
func test_any_input_works_for_mouse_movement() -> void:
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
	

func test_any_input_adheres_to_mouse_minimum_distance() -> void:
	var input := input_any()
	input.mouse_movement = true
	input.minimum_mouse_movement_distance = 30
	map(_context, _action, input)
	GUIDE.enable_mapping_context(_context)
	
	# WHEN: i move the mouse just a small bit
	await mouse_move_by(Vector2(3,3))

	# THEN: the action is not triggered
	await assert_not_triggered(_action)
	


func test_any_input_works_with_joy_buttons() -> void:
	var input := input_any()
	input.joy_buttons = true
	map(_context, _action, input)
	GUIDE.enable_mapping_context(_context)
	
	# WHEN: i press the joy button
	await tap_joy_button(JOY_BUTTON_A)
	
	# THEN: the action is triggered
	await assert_triggered(_action)
	

func test_any_input_works_with_joy_axis() -> void:
	var input := input_any()
	input.joy_axes = true
	map(_context, _action, input)
	GUIDE.enable_mapping_context(_context)
	
	# WHEN: i move the joy axis
	await joy_axis(JOY_AXIS_LEFT_X, 0.5)
	
	# THEN: the action is triggered
	await assert_triggered(_action)
	
	await joy_axis(JOY_AXIS_LEFT_X, 0)
	
func test_any_input_works_with_joy_axis_with_deadzone() -> void:
	var input := input_any()
	input.joy_axes = true
	input.minimum_joy_axis_actuation_strength = 0.7
	map(_context, _action, input)
	GUIDE.enable_mapping_context(_context)
	
	# WHEN: i move the joy axis just a bit
	await joy_axis(JOY_AXIS_LEFT_X, 0.5)
	
	# THEN: the action is not triggered
	await assert_not_triggered(_action)

	
func test_any_input_works_with_keyboard() -> void:
	var input := input_any()
	input.keyboard = true
	map(_context, _action, input)
	GUIDE.enable_mapping_context(_context)
	
	# WHEN: i press the key
	await tap_key(KEY_Q)
	
	# THEN: the action is triggered
	await assert_triggered(_action)
	
func test_any_input_works_with_touch() -> void:
	var input := input_any()
	input.touch = true
	map(_context, _action, input)
	GUIDE.enable_mapping_context(_context)
	
	# WHEN: i press the touch
	await tap_finger(0, Vector2(100, 100))
	
	# THEN: the action is triggered
	await assert_triggered(_action)
	
func test_any_input_handles_queuing_input_correctly() -> void:
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


func test_any_input_with_down_trigger_fires_every_frame() -> void:
	var input := input_any()
	input.keyboard = true

	var trigger_down := trigger_down()
	map(_context, _action, input, [], [trigger_down])
	GUIDE.enable_mapping_context(_context)

	var action := watch(_action)

	# WHEN: I press and hold a key
	key_down(KEY_Q, false)

	# THEN: the action triggers on the first frame
	assert_bool(await action.triggered_was_emitted()).is_true()

	# AND: it continues to trigger on subsequent frames while held
	await wait_f(1)
	assert_bool(await action.triggered_was_emitted()).is_true()

	await wait_f(1)
	assert_bool(await action.triggered_was_emitted()).is_true()

	# WHEN: I release the key
	await key_up(KEY_Q)

	# THEN: completed is emitted
	assert_bool(await action.completed_was_emitted()).is_true()

	# AND: triggered no longer fires on subsequent frames
	action.reset()
	await wait_f(1)
	assert_bool(action.triggered_was_not_emitted()).is_true()
