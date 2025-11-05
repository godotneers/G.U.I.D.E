extends GUIDETestBase


var _context1:GUIDEMappingContext
var _context2:GUIDEMappingContext
var _action1:GUIDEAction
var _action2:GUIDEAction

func _setup() -> void:
	_context1 = mapping_context()
	_context2 = mapping_context()
	_action1 = action_bool()
	_action2 = action_bool()

# https://github.com/godotneers/G.U.I.D.E/issues/61
# Switching mapping contexts while an input is active should not deactivate the input.
func test_input_stays_active_when_mapping_contexts_change() -> void:
	var input:GUIDEInput = input_key(KEY_A)
	map(_context1, _action1, input)
	map(_context2, _action2, input)
	
	GUIDE.enable_mapping_context(_context1)
	
	# WHEN
	# i press the key down
	await key_down(KEY_A)
	
	# THEN 
	# the first action is triggered
	await assert_triggered(_action1)
	
	# when I now switch the mapping context, but keep the key pressed
	GUIDE.enable_mapping_context(_context2, true)
	
	# THEN
	# the second action is triggered
	await assert_triggered(_action2)
