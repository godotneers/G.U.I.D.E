extends GUIDETestBase

var _context1: GUIDEMappingContext
var _context2: GUIDEMappingContext
var _action: GUIDEAction


func _setup():
	_context1 = mapping_context()
	_context2 = mapping_context()
	_action = action_bool("some_action")


func test_action_with_pressed_trigger_does_not_trigger_again_on_context_switch():
	var input := input_key(KEY_A)
	var trigger := trigger_pressed()
	map(_context1, _action, input, [], [trigger] )
	map(_context2, _action, input, [], [trigger] )
	
	GUIDE.enable_mapping_context(_context1)
	# when i press the key
	key_down(KEY_A, true)
	
	# then the action is triggered
	await assert_triggered(_action)
	
	await wait_f(10)
	
	# since we have a pressed trigger, the action should not trigger again
	await assert_not_triggered(_action)
	
	# when i switch to the second context
	GUIDE.enable_mapping_context(_context2)
	
	# then this should not trigger the action again, as the key is still down
	await assert_not_triggered(_action)


func test_action_with_down_trigger_triggers_again_on_context_switch():
	var input := input_key(KEY_A)
	var trigger := trigger_down()
	map(_context1, _action, input, [], [trigger] )
	map(_context2, _action, input, [], [trigger] )
	
	GUIDE.enable_mapping_context(_context1)
	# when i press the key
	key_down(KEY_A, true)
	
	# then the action is triggered
	await assert_triggered(_action)
	
	await wait_f(10)
	
	# since we have a down trigger, the action should trigger again
	await assert_triggered(_action)
	
	# when i switch to the second context
	GUIDE.enable_mapping_context(_context2)
	
	# then this should trigger the action again
	await assert_triggered(_action)
	
	await wait_f(10)
	
	# and should still do so
	await assert_triggered(_action)

	
func test_action_with_different_inputs_retains_value_on_context_switch():
	_action = action_2d("some_action")
	
	# we have 2 contexts with the same action, but different inputs (e.g. one keyboard, one gamepad)
	var input1 : GUIDEInput = input_mouse_position()	
	var input2 : GUIDEInput = input_joy_axis_2d(JOY_AXIS_LEFT_X, JOY_AXIS_LEFT_Y)
	map(_context1, _action, input1)
	map(_context2, _action, input2, [modifier_virtual_cursor()])
	
	GUIDE.enable_mapping_context(_context1)
	
	# wait 1 frame
	await wait_f(1)
	
	assert_vector(_action.value_axis_2d).is_equal_approx(Vector2(get_viewport().get_mouse_position()), Vector2(0.01, 0.01))
	
	
	# if we now switch the mapping contexts 
	GUIDE.enable_mapping_context(_context2, true)
	
	# the value should now be the value of the virtual cursor 
	# without waiting for a frame. 
	assert_vector(_action.value_axis_2d).is_equal_approx(Vector2(get_viewport().get_visible_rect().size / 2.0), Vector2(0.01, 0.01))
	
