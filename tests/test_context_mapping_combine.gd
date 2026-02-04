extends GUIDETestBase

var _context1: GUIDEMappingContext
var _context2: GUIDEMappingContext
var _action: GUIDEAction


func _setup() -> void:
	_context1 = mapping_context()
	_context2 = mapping_context()
	_action = action_bool("some_action")


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
