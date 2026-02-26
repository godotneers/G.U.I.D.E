extends GUIDETestBase

var _context1: GUIDEMappingContext
var _context2: GUIDEMappingContext
var _action: GUIDEAction


func _setup() -> void:
	_context1 = mapping_context()
	_context2 = mapping_context()
	_action = action_bool("some_action")


func test_action_with_pressed_trigger_does_not_trigger_again_on_context_switch() -> void:
	var input := input_key(KEY_A)
	var trigger := trigger_pressed()
	map(_context1, _action, input, [], [trigger] )
	map(_context2, _action, input, [], [trigger] )

	GUIDE.enable_mapping_context(_context1)
	var watched := watch(_action)
	# when i press the key
	key_down(KEY_A, true)

	# then the action is triggered
	await watched.assert_triggered()

	await wait_f(10)

	# since we have a pressed trigger, the action should not trigger again
	watched.assert_not_triggered()

	# when i switch to the second context
	GUIDE.enable_mapping_context(_context2)

	# then this should not trigger the action again, as the key is still down
	watched.assert_not_triggered()


func test_action_with_down_trigger_triggers_again_on_context_switch() -> void:
	var input := input_key(KEY_A)
	var trigger := trigger_down()
	map(_context1, _action, input, [], [trigger] )
	map(_context2, _action, input, [], [trigger] )

	GUIDE.enable_mapping_context(_context1)
	var watched := watch(_action)
	# when i press the key
	key_down(KEY_A, true)

	# then the action is triggered
	await watched.assert_triggered()

	await wait_f(10)

	# since we have a down trigger, the action should trigger again
	await watched.assert_triggered()

	# when i switch to the second context
	GUIDE.enable_mapping_context(_context2)

	# then this should trigger the action again
	await watched.assert_triggered()

	await wait_f(10)

	# and should still do so
	await watched.assert_triggered()

	
func test_action_with_different_inputs_retains_value_on_context_switch() -> void:
	_action = action_2d("some_action")
	
	# we have 2 contexts with the same action, but different inputs (e.g. one keyboard, one gamepad)
	var input1 : GUIDEInput = input_mouse_position()	
	var input2 : GUIDEInput = input_joy_axis_2d(JOY_AXIS_LEFT_X, JOY_AXIS_LEFT_Y)
	map(_context1, _action, input1)
	map(_context2, _action, input2, [modifier_virtual_cursor()])
	
	GUIDE.enable_mapping_context(_context1)
	
	# wait 1 frame
	await wait_f(1)
	
	assert_vector(_action.value_axis_2d).is_equal_approx(Vector2(get_viewport().get_mouse_position()), Vector2(0.01, 0.01))
	
	
	# if we now switch the mapping contexts 
	GUIDE.enable_mapping_context(_context2, true)
	
	# the value should now be the value of the virtual cursor
	# without waiting for a frame.
	assert_vector(_action.value_axis_2d).is_equal_approx(Vector2(get_viewport().get_visible_rect().size / 2.0), Vector2(0.01, 0.01))


func test_enable_mapping_context_emits_signals() -> void:
	# Set up an enabled signal watcher
	var enabled_count := [0]
	_context1.enabled.connect(func() -> void: enabled_count[0] += 1)

	# Enable context1
	GUIDE.enable_mapping_context(_context1)
	
	# Signal should be triggered
	assert_int(enabled_count[0]).is_equal(1)
	enabled_count[0] = 0

	# Set up a disabled signal watcher
	var disabled_count := [0]
	_context1.disabled.connect(func() -> void: disabled_count[0] += 1)

	# Enable context2 and disable others
	GUIDE.enable_mapping_context(_context2, true)
	
	# Disabled signal should be emitted for context1
	assert_int(enabled_count[0]).is_equal(0)
	assert_int(disabled_count[0]).is_equal(1)


func test_disable_mapping_context_emits_signals() -> void:
	# Enable context1
	GUIDE.enable_mapping_context(_context1)

	# Set up a disabled signal watcher
	var disabled_count := [0]
	_context1.disabled.connect(func() -> void: disabled_count[0] += 1)
	
	# Disable context1
	GUIDE.disable_mapping_context(_context1)

	# Disabled signal should be emitted for context1
	assert_int(disabled_count[0]).is_equal(1)


func test_set_enabled_mapping_contexts_returns_previous_contexts() -> void:
	# Given some active contexts
	GUIDE.enable_mapping_context(_context1)
	GUIDE.enable_mapping_context(_context2)

	# When we set new contexts
	var context3 := mapping_context()
	var previous := GUIDE.set_enabled_mapping_contexts([context3])

	# Then the previous contexts are returned
	assert_array(previous).contains_exactly([_context1, _context2])


func test_set_enabled_mapping_contexts_activates_new_contexts() -> void:
	# Given some active contexts
	GUIDE.enable_mapping_context(_context1)

	# When we set new contexts
	var context3 := mapping_context()
	GUIDE.set_enabled_mapping_contexts([_context2, context3])

	# Then the new contexts are active
	assert_bool(GUIDE.is_mapping_context_enabled(_context2)).is_true()
	assert_bool(GUIDE.is_mapping_context_enabled(context3)).is_true()


func test_set_enabled_mapping_contexts_deactivates_old_contexts() -> void:
	# Given some active contexts
	GUIDE.enable_mapping_context(_context1)
	GUIDE.enable_mapping_context(_context2)

	# When we set new contexts that don't include context1
	var context3 := mapping_context()
	GUIDE.set_enabled_mapping_contexts([_context2, context3])

	# Then context1 is no longer active
	assert_bool(GUIDE.is_mapping_context_enabled(_context1)).is_false()


func test_set_enabled_mapping_contexts_with_empty_array_clears_all() -> void:
	# Given some active contexts
	GUIDE.enable_mapping_context(_context1)
	GUIDE.enable_mapping_context(_context2)

	# When we set an empty array
	var previous := GUIDE.set_enabled_mapping_contexts([])

	# Then all contexts are deactivated
	assert_bool(GUIDE.is_mapping_context_enabled(_context1)).is_false()
	assert_bool(GUIDE.is_mapping_context_enabled(_context2)).is_false()
	# And previous contexts are returned
	assert_array(previous).contains_exactly([_context1, _context2])


func test_set_enabled_mapping_contexts_with_single_context() -> void:
	# When we set a single context
	GUIDE.set_enabled_mapping_contexts([_context1])

	# Then only that context is active
	assert_bool(GUIDE.is_mapping_context_enabled(_context1)).is_true()
	assert_bool(GUIDE.is_mapping_context_enabled(_context2)).is_false()


func test_set_enabled_mapping_contexts_emits_enabled_signals() -> void:
	# Given we watch for enabled signals
	var enabled1 := [false]
	var enabled2 := [false]
	_context1.enabled.connect(func() -> void: enabled1[0] = true)
	_context2.enabled.connect(func() -> void: enabled2[0] = true)

	# When we set new contexts
	GUIDE.set_enabled_mapping_contexts([_context1, _context2])

	# Then enabled signals are emitted for all new contexts
	assert_bool(enabled1[0]).is_true()
	assert_bool(enabled2[0]).is_true()


func test_set_enabled_mapping_contexts_emits_disabled_signals() -> void:
	# Given some active contexts with disabled signal watchers
	GUIDE.enable_mapping_context(_context1)
	GUIDE.enable_mapping_context(_context2)
	var disabled1 := [false]
	var disabled2 := [false]
	_context1.disabled.connect(func() -> void: disabled1[0] = true)
	_context2.disabled.connect(func() -> void: disabled2[0] = true)

	# When we set new contexts that don't include the old ones
	var context3 := mapping_context()
	GUIDE.set_enabled_mapping_contexts([context3])

	# Then disabled signals are emitted for removed contexts
	assert_bool(disabled1[0]).is_true()
	assert_bool(disabled2[0]).is_true()


func test_set_enabled_mapping_contexts_later_contexts_have_higher_precedence() -> void:
	# Given an action mapped to different inputs in two contexts
	var input1 := input_key(KEY_A)
	var input2 := input_key(KEY_B)
	map(_context1, _action, input1)
	map(_context2, _action, input2)

	# When we set contexts with context2 later in the array
	GUIDE.set_enabled_mapping_contexts([_context1, _context2])

	var watched := watch(_action)

	# When we press input2 (from context2)
	key_down(KEY_B, true)

	# Then the action is triggered (context2 has precedence)
	await watched.assert_triggered()

	# And input1 does not trigger (because context2's input takes precedence due to later timestamp)
	key_up(KEY_B, true)
	await wait_f(10)
	watched.reset()
	key_down(KEY_A, true)

	# Context1's input should still work, just with lower precedence
	await watched.assert_triggered()


func test_set_enabled_mapping_contexts_with_duplicate_contexts_uses_later_occurrence() -> void:
	# When we set contexts with duplicates
	GUIDE.set_enabled_mapping_contexts([_context1, _context2, _context1])

	# Then the context is still enabled (later occurrence wins)
	assert_bool(GUIDE.is_mapping_context_enabled(_context1)).is_true()
	assert_bool(GUIDE.is_mapping_context_enabled(_context2)).is_true()

	# And there should be only 2 contexts active (not 3)
	var active := GUIDE.get_enabled_mapping_contexts()
	assert_int(active.size()).is_equal(2)


func test_set_enabled_mapping_contexts_does_not_emit_enabled_for_already_active_contexts() -> void:
	# Given context1 is already enabled
	GUIDE.enable_mapping_context(_context1)

	# And we set up a signal watcher
	var enabled_count := [0]
	_context1.enabled.connect(func() -> void: enabled_count[0] += 1)

	# When we set contexts that include context1 (which is already active)
	GUIDE.set_enabled_mapping_contexts([_context1, _context2])

	# Then the enabled signal should NOT be emitted for context1 (it was already enabled)
	assert_int(enabled_count[0]).is_equal(0)


func test_set_enabled_mapping_contexts_emits_enabled_only_for_new_contexts() -> void:
	# Given context1 is already enabled
	GUIDE.enable_mapping_context(_context1)

	# And we set up signal watchers
	var enabled1_count := [0]
	var enabled2_count := [0]
	_context1.enabled.connect(func() -> void: enabled1_count[0] += 1)
	_context2.enabled.connect(func() -> void: enabled2_count[0] += 1)

	# When we set contexts that include both context1 (already active) and context2 (new)
	GUIDE.set_enabled_mapping_contexts([_context1, _context2])

	# Then enabled should only be emitted for context2 (the new one)
	assert_int(enabled1_count[0]).is_equal(0)
	assert_int(enabled2_count[0]).is_equal(1)

