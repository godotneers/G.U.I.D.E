## This test verifies the signals of GUIDEAction.
extends GUIDETestBase

var _action: GUIDEAction
var _context: GUIDEMappingContext

func _setup() -> void:
	_action = action_bool("test_action")
	_context = mapping_context()


## Helper to map a key to the action with optional triggers.
func _map_key(key: Key, triggers: Array[GUIDETrigger] = []) -> void:
	map(_context, _action, input_key(key), [], triggers)


## Tests the basic triggered and just_triggered signals.
func test_triggered_signals() -> void:
	_map_key(KEY_A)
	GUIDE.enable_mapping_context(_context)
	
	var action := watch(_action)
	
	# Initial state: nothing triggered
	assert_bool(action.triggered_was_not_emitted()).is_true()
	assert_bool(action.just_triggered_was_not_emitted()).is_true()
	
	# Press key
	await key_down(KEY_A)
	
	# THEN: triggered and just_triggered are emitted
	assert_bool(await action.triggered_was_emitted()).is_true()
	assert_bool(await action.just_triggered_was_emitted()).is_true()
	
	# Keep key down for another frame
	await wait_f(1)
	
	# THEN: triggered is emitted again, but just_triggered is not
	assert_bool(await action.triggered_was_emitted()).is_true()
	assert_bool(action.just_triggered_was_not_emitted()).is_true()
	
	# Release key
	await key_up(KEY_A)
	action.reset()
	
	# wait 
	await wait_f(10)
	
	# no more triggered events are sent
	assert_bool(action.triggered_was_not_emitted()).is_true()


## Tests the started, ongoing, and completed signals using a Hold trigger.
func test_hold_signals() -> void:
	var hold := trigger_hold(0.5)
	_map_key(KEY_H, [hold])
	GUIDE.enable_mapping_context(_context)
	
	var action := watch(_action)
	
	# Press key
	await key_down(KEY_H)
	
	# THEN: started and ongoing are emitted, but not triggered yet
	assert_bool(await action.started_was_emitted()).is_true()
	assert_bool(await action.ongoing_was_emitted()).is_true()
	assert_bool(action.triggered_was_not_emitted()).is_true()
	
	# Wait some time but not enough for the hold
	await wait_seconds(0.1)
	
	# THEN: ongoing is emitted, but started and triggered are not
	assert_bool(await action.ongoing_was_emitted()).is_true()
	assert_bool(action.started_was_not_emitted()).is_true()
	assert_bool(action.triggered_was_not_emitted()).is_true()
	
	# Wait enough for the hold to trigger
	await wait_seconds(0.5)
	
	# THEN: triggered is emitted
	assert_bool(await action.triggered_was_emitted()).is_true()
	
	# Release key
	action.reset()
	await key_up(KEY_H)
	
	# THEN: completed is emitted
	assert_bool(await action.completed_was_emitted()).is_true()


## Tests the cancelled signal when a hold is interrupted.
func test_cancelled_signal() -> void:
	var hold := trigger_hold(1.0)
	_map_key(KEY_C, [hold])
	GUIDE.enable_mapping_context(_context)
	
	var action := watch(_action)
	
	# Press key
	await key_down(KEY_C)
	
	# THEN: started and ongoing are emitted
	assert_bool(await action.started_was_emitted()).is_true()
	assert_bool(await action.ongoing_was_emitted()).is_true()
	
	# Release key before hold threshold
	await key_up(KEY_C)
	
	# THEN: cancelled and completed are emitted
	assert_bool(await action.cancelled_was_emitted()).is_true()
	assert_bool(await action.completed_was_emitted()).is_true()
	assert_bool(action.triggered_was_not_emitted()).is_true()


## Tests the completed signal when a regular action is released.
func test_completed_signal() -> void:
	_map_key(KEY_B)
	GUIDE.enable_mapping_context(_context)
	
	var action := watch(_action)
	
	# Press key
	await key_down(KEY_B)
	assert_bool(await action.triggered_was_emitted()).is_true()
	
	# Release key
	action.reset()
	await key_up(KEY_B)
	
	# THEN: completed is emitted
	assert_bool(await action.completed_was_emitted()).is_true()

