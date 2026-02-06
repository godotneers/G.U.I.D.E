extends GUIDETestBase

var _context1: GUIDEMappingContext
var _context2: GUIDEMappingContext
var _action: GUIDEAction
var _action2d: GUIDEAction


func _setup() -> void:
	_context1 = mapping_context()
	_context2 = mapping_context()
	_action = action_bool("some_action")
	_action2d = action_2d("some_action")


func test_inputs_are_combined() -> void:
	var input1 := input_key(KEY_A)
	var input2 := input_joy_button(JOY_BUTTON_A)
	var trigger := trigger_pressed()
	map(_context1, _action, input1, [], [trigger] )
	map(_context2, _action, input2, [], [trigger] )
	
	# when i enable two mapping contexts with the same action
	# both inputs should trigger the action
	GUIDE.enable_mapping_context(_context1)
	GUIDE.enable_mapping_context(_context2)

	# when i press the key
	await tap_key(KEY_A)
	
	# then the action is triggered
	await assert_triggered(_action)
	
	await wait_f(10)
	
	# check that the trigger stopped
	await assert_not_triggered(_action)
	
	# when i press the button
	await tap_joy_button(JOY_BUTTON_A)
	
	# then the action is triggered
	await assert_triggered(_action)
	
	await wait_f(10)
	
	# check that the trigger stopped
	await assert_not_triggered(_action)

func test_merging_same_input() -> void:
	var input1 := input_key(KEY_A)
	var swizzle := modifier_input_swizzle()
	map(_context1, _action2d, input1, [])
	map(_context2, _action2d, input1, [swizzle])
	
	# when i enable two mapping contexts with the same action
	# both inputs should trigger the action
	GUIDE.enable_mapping_context(_context2)
	GUIDE.enable_mapping_context(_context1)

	# when i press the key
	await key_down(KEY_A)
	
	# then the action is triggered
	await assert_triggered(_action2d)
	assert_axis_2d(_action2d, Vector2(1, 0), Vector2(0.001, 0))
	
	await key_up(KEY_A)
	
	# when i disable mapping context 1
	GUIDE.disable_mapping_context(_context1)
	
	# and i press the key
	await key_down(KEY_A)
	
	# then the action is triggered
	await assert_triggered(_action2d)
	# and the vector is swizzled according to mapping context 2
	assert_axis_2d(_action2d, Vector2(0, 1), Vector2(0, 0.001))
	
	await key_up(KEY_A)
