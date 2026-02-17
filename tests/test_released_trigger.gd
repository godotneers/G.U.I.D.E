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
	action.assert_not_triggered()
	action.assert_not_ongoing()

	# WHEN: I press the key
	await key_down(KEY_R)

	# THEN: it is ongoing, but not yet triggered
	await action.assert_started()
	await action.assert_ongoing()
	action.assert_not_triggered()

	# WHEN: I release the key
	await key_up(KEY_R)

	# THEN: it is triggered and then completed
	await action.assert_triggered()
	await action.assert_just_triggered()
	await action.assert_completed()

