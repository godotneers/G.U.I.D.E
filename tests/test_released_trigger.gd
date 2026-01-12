## This test verifies the GUIDETriggerReleased class.
extends GUIDETestBase

var _context: GUIDEMappingContext
var _action: GUIDEAction
var _trigger: GUIDETriggerReleased

func _setup() -> void:
	_context = mapping_context()
	_action = action_bool()
	_trigger = trigger_released()


func test_released_trigger_works_for_key_input() -> void:
	var input := input_key(KEY_R)
	map(_context, _action, input, [], [_trigger])
	GUIDE.enable_mapping_context(_context)
	
	var action := watch(_action)
	
	# Initial state: nothing
	assert_bool(action.triggered_was_not_emitted()).is_true()
	assert_bool(action.ongoing_was_not_emitted()).is_true()
	
	# WHEN: I press the key
	await key_down(KEY_R)
	
	# THEN: it is ongoing, but not yet triggered
	assert_bool(await action.started_was_emitted()).is_true()
	assert_bool(await action.ongoing_was_emitted()).is_true()
	assert_bool(action.triggered_was_not_emitted()).is_true()
	
	# WHEN: I release the key
	action.reset()
	await key_up(KEY_R)
	
	# THEN: it is triggered and then completed
	assert_bool(await action.triggered_was_emitted()).is_true()
	assert_bool(await action.just_triggered_was_emitted()).is_true()
	assert_bool(await action.completed_was_emitted()).is_true()

