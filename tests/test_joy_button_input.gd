extends GUIDETestBase


var _context:GUIDEMappingContext
var _action:GUIDEAction

func _setup() -> void:
	_context = mapping_context()
	_action = action_bool()

func test_joy_button_input() -> void:
	var input := input_joy_button(JOY_BUTTON_A)
	map(_context, _action, input)
	
	GUIDE.enable_mapping_context(_context)
	
	# WHEN
	# i press the joy button
	await tap_joy_button(JOY_BUTTON_A)
	
	# THEN
	# the action is triggered
	await assert_triggered(_action)
	
