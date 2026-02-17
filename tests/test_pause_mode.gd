extends GUIDETestBase

var _context:GUIDEMappingContext
var _action:GUIDEAction
var _trigger:GUIDETrigger

func _setup() -> void:
	_context = mapping_context()
	_action = action_bool()
	_trigger = trigger_down()

func test_pause_mode() -> void:
	var input := input_key(KEY_Q)
	map(_context, _action, input, [], [_trigger])
	GUIDE.enable_mapping_context(_context)
	var a := watch(_action)


	# WHEN: the game is paused
	get_tree().paused = true

	# AND: i press the key
	await key_down(KEY_Q)

	# THEN: the action is still triggered
	await a.assert_triggered(1.0)

	await key_up(KEY_Q)

	get_tree().paused = false
