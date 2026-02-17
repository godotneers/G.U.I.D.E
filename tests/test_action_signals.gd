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

	var watched := watch(_action)

	# Initial state: nothing triggered
	watched.assert_not_triggered()
	watched.assert_not_just_triggered()

	# Press key
	await key_down(KEY_A)

	# THEN: triggered and just_triggered are emitted
	await watched.assert_triggered()
	await watched.assert_just_triggered()

	# Keep key down for another frame
	await wait_f(1)

	# THEN: triggered is emitted again, but just_triggered is not
	await watched.assert_triggered()
	watched.assert_not_just_triggered()

	# Release key
	await key_up(KEY_A)
	watched.reset()

	# wait
	await wait_f(10)

	# no more triggered events are sent
	watched.assert_not_triggered()


## Tests the started, ongoing, and completed signals using a Hold trigger.
func test_hold_signals() -> void:
	var hold := trigger_hold(0.5)
	_map_key(KEY_H, [hold])
	GUIDE.enable_mapping_context(_context)

	var watched := watch(_action)

	# Press key
	await key_down(KEY_H)

	# THEN: started and ongoing are emitted, but not triggered yet
	await watched.assert_started()
	await watched.assert_ongoing()
	watched.assert_not_triggered()

	# Wait some time but not enough for the hold
	await wait_seconds(0.1)

	# THEN: ongoing is emitted, but started and triggered are not
	await watched.assert_ongoing()
	watched.assert_not_started()
	watched.assert_not_triggered()

	# Wait enough for the hold to trigger
	await wait_seconds(0.5)

	# THEN: triggered is emitted
	await watched.assert_triggered()

	# Release key
	await key_up(KEY_H)

	# THEN: completed is emitted
	await watched.assert_completed()


## Tests the cancelled signal when a hold is interrupted.
func test_cancelled_signal() -> void:
	var hold := trigger_hold(1.0)
	_map_key(KEY_C, [hold])
	GUIDE.enable_mapping_context(_context)

	var watched := watch(_action)

	# Press key
	await key_down(KEY_C)

	# THEN: started and ongoing are emitted
	await watched.assert_started()
	await watched.assert_ongoing()

	# Release key before hold threshold
	await key_up(KEY_C)

	# THEN: cancelled and completed are emitted
	await watched.assert_cancelled()
	await watched.assert_completed()
	watched.assert_not_triggered()


## Tests the completed signal when a regular action is released.
func test_completed_signal() -> void:
	_map_key(KEY_B)
	GUIDE.enable_mapping_context(_context)

	var watched := watch(_action)

	# Press key
	await key_down(KEY_B)
	await watched.assert_triggered()

	# Release key
	await key_up(KEY_B)

	# THEN: completed is emitted
	await watched.assert_completed()

