extends GUIDETestBase

var _context:GUIDEMappingContext
var _action:GUIDEAction
var _trigger:GUIDETrigger

func _setup() -> void:
	_context = mapping_context()
	_action = action_bool()
	_trigger = trigger_down()

func test_down_trigger_works_for_key_input() -> void:
	var input := input_key(KEY_Q)
	map(_context, _action, input, [], [_trigger])
	GUIDE.enable_mapping_context(_context)
	
	# WHEN: i press the key
	await key_down(KEY_Q)

	# THEN: the action is triggered
	assert_bool(_action.is_triggered()).is_true()
	
	# WHEN: i release the key
	await key_up(KEY_Q)
	
	# THEN: the action is not triggered anymore
	assert_bool(_action.is_triggered()).is_false()
	
