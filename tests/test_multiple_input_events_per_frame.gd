extends GUIDETestBase


var _context:GUIDEMappingContext
var _action:GUIDEAction

func _setup() -> void:
	_context = mapping_context()
	_action = action_bool()

# https://github.com/godotneers/G.U.I.D.E/issues/77
# Having an actuation and release event in the same frame causes
# missing trigger of an action.
func test_rapid_key_actuations_are_handled_correctly() -> void:
	var input:GUIDEInput = input_key(KEY_A)
	map(_context, _action, input)

	GUIDE.enable_mapping_context(_context)

	await assert_not_completed(_action)

	# WHEN
	# i press the key down
	key_down(KEY_A, false)
	# and immediately release it within the same frame
	await key_up(KEY_A)

	# THEN 
	# the action is triggered
	await assert_triggered(_action)
	# and is completed afterwards
	await assert_completed(_action)


func test_rapid_mouse_actuations_are_handled_correctly() -> void:
	var input:GUIDEInput = input_mouse_button(MOUSE_BUTTON_LEFT)
	map(_context, _action, input)

	GUIDE.enable_mapping_context(_context)

	await assert_not_completed(_action)

	# WHEN
	# i press the mouse button down
	mouse_down(MOUSE_BUTTON_LEFT, false)
	# and immediately release it within the same frame
	await mouse_up(MOUSE_BUTTON_LEFT)

	# THEN 
	# the action is triggered
	await assert_triggered(_action)
	# and is completed afterwards
	await assert_completed(_action)


func test_rapid_controller_actuations_are_handled_correctly() -> void:
	var input:GUIDEInput = input_joy_button(JOY_BUTTON_A)
	map(_context, _action, input)

	GUIDE.enable_mapping_context(_context)

	await assert_not_completed(_action)

	# WHEN
	# i press the controller A button down
	joy_button_down(JOY_BUTTON_A, false)
	# and immediately release it within the same frame
	await joy_button_up(JOY_BUTTON_A)

	# THEN 
	# the action is triggered
	await assert_triggered(_action)
	# and is completed afterwards
	await assert_completed(_action)
