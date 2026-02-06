extends GUIDETestBase

var _context1: GUIDEMappingContext
var _context2: GUIDEMappingContext
var _action: GUIDEAction
var _action2d: GUIDEAction


func _setup() -> void:
	_context1 = mapping_context()
	_context2 = mapping_context()
	_action = action_bool("some_action_bool")
	_action2d = action_2d("some_action_2d")

## Tests that different mapping contexts with the same action but different
## inputs both trigger when pressed.
func test_inputs_are_combined() -> void:
	var input1 := input_key(KEY_A)
	var input2 := input_joy_button(JOY_BUTTON_A)
	var trigger := trigger_pressed()
	map(_context1, _action, input1, [], [trigger] )
	map(_context2, _action, input2, [], [trigger] )
	
	GUIDE.enable_mapping_context(_context1)
	GUIDE.enable_mapping_context(_context2)

	await tap_key(KEY_A)
	await assert_triggered(_action)
	await wait_f(10)
	await assert_not_triggered(_action)
	
	await tap_joy_button(JOY_BUTTON_A)
	await assert_triggered(_action)
	await wait_f(10)
	await assert_not_triggered(_action)

## Tests that actions are overridden when a mapping context is enabled that has
## the same action and the same input as another enabled mapping context
func test_merging_same_input() -> void:
	var input1 := input_key(KEY_A)
	var swizzle := modifier_input_swizzle()
	map(_context1, _action2d, input1, [])
	map(_context2, _action2d, input1, [swizzle])
	
	GUIDE.enable_mapping_context(_context2)
	GUIDE.enable_mapping_context(_context1)

	await key_down(KEY_A)
	await assert_triggered(_action2d)
	assert_axis_2d(_action2d, Vector2(1, 0), Vector2(0.001, 0))
	await key_up(KEY_A)
	
	GUIDE.disable_mapping_context(_context1)
	
	await key_down(KEY_A)
	await assert_triggered(_action2d)
	assert_axis_2d(_action2d, Vector2(0, 1), Vector2(0, 0.001))
	await key_up(KEY_A)
