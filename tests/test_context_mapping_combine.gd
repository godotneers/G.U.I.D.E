extends GUIDETestBase

var _context1: GUIDEMappingContext
var _context2: GUIDEMappingContext
var _context3: GUIDEMappingContext
var _action: GUIDEAction
var _action2d: GUIDEAction


func _setup() -> void:
	_context1 = mapping_context()
	_context2 = mapping_context()
	_context3 = mapping_context()
	_action = action_bool("some_action_bool")
	_action2d = action_2d("some_action_2d")

## Tests that different mapping contexts with the same action but different
## inputs both trigger when pressed.
func test_inputs_are_combined() -> void:
	var input1 := input_key(KEY_A)
	var input2 := input_joy_button(JOY_BUTTON_A)
	var trigger := trigger_pressed()
	map(_context1, _action, input1, [], [trigger] )
	map(_context2, _action, input2, [], [trigger] )

	GUIDE.enable_mapping_context(_context1)
	GUIDE.enable_mapping_context(_context2)

	var action_watcher := watch(_action)

	await tap_key(KEY_A)
	assert_bool(await action_watcher.triggered_was_emitted()).is_true()
	action_watcher.reset()
	await wait_f(10)
	assert_bool(action_watcher.triggered_was_not_emitted()).is_true()

	await tap_joy_button(JOY_BUTTON_A)
	assert_bool(await action_watcher.triggered_was_emitted()).is_true()
	action_watcher.reset()
	await wait_f(10)
	assert_bool(action_watcher.triggered_was_not_emitted()).is_true()

## Tests that actions are overridden when a mapping context is enabled that has
## the same action and the same input as another enabled mapping context
func test_merging_same_input() -> void:
	var input1 := input_key(KEY_A)
	var swizzle := modifier_input_swizzle()
	map(_context1, _action2d, input1, [])
	map(_context2, _action2d, input1, [swizzle])

	GUIDE.enable_mapping_context(_context2)
	GUIDE.enable_mapping_context(_context1)

	var action_watcher := watch(_action2d)

	await key_down(KEY_A)
	assert_bool(await action_watcher.triggered_was_emitted()).is_true()
	assert_axis_2d(_action2d, Vector2(1, 0), Vector2(0.001, 0))
	await key_up(KEY_A)

	action_watcher.reset()
	GUIDE.disable_mapping_context(_context1)

	await key_down(KEY_A)
	assert_bool(await action_watcher.triggered_was_emitted()).is_true()
	assert_axis_2d(_action2d, Vector2(0, 1), Vector2(0, 0.001))
	await key_up(KEY_A)


## https://github.com/godotneers/G.U.I.D.E/issues/67
## Tests that when multiple contexts with different inputs for the same action
## are merged, disabling one context while an input from another is held
## does not cause the action to re-trigger.
func test_merged_contexts_preserve_trigger_state_on_context_disable() -> void:
	var input1 := input_key(KEY_W)
	var input2 := input_joy_axis_2d(JOY_AXIS_LEFT_X, JOY_AXIS_LEFT_Y)
	var trigger := trigger_pressed()
	map(_context1, _action2d, input1, [], [trigger])
	map(_context2, _action2d, input2, [], [trigger])

	# Enable both contexts (inputs will be merged)
	GUIDE.enable_mapping_context(_context1)
	GUIDE.enable_mapping_context(_context2)

	var action_watcher := watch(_action2d)

	# Press and hold W
	await key_down(KEY_W)

	# Action should trigger
	assert_bool(await action_watcher.triggered_was_emitted()).is_true()

	# Wait a bit
	action_watcher.reset()
	await wait_f(10)

	# Should not trigger again (it's a Pressed trigger)
	assert_bool(action_watcher.triggered_was_not_emitted()).is_true()

	# Now disable the controller context while W is still held
	GUIDE.disable_mapping_context(_context2)

	# The action should NOT re-trigger even though a new mapping was created
	# (because the new trigger's _last_value should be initialized to current W value)
	assert_bool(action_watcher.triggered_was_not_emitted()).is_true()

	# Release W
	await key_up(KEY_W)


## Tests that when a remapping config remaps an input to match another context's input,
## the merged mapping doesn't create duplicate input mappings for the same input.
## This verifies that the duplicate check happens after remapping is applied.
func test_remapping_to_same_input_doesnt_create_duplicates() -> void:
	# Realistic scenario:
	# Context 1 (keyboard): Space key -> jump
	# Context 2 (controller): Joy button A -> jump
	# User remaps keyboard Space to Joy button A (same as controller's original binding)

	var space_key := input_key(KEY_SPACE)
	var joy_button := input_joy_button(JOY_BUTTON_A)
	var trigger := trigger_pressed()

	map(_context1, _action, space_key, [], [trigger])
	map(_context2, _action, joy_button, [], [trigger])

	# Create a remapping that changes context1's Space key to Joy button A
	# (same as context2's original input)
	var remapping := GUIDERemappingConfig.new()
	var remapped_button := input_joy_button(JOY_BUTTON_A)
	remapping._bind(_context1, _action, remapped_button, 0)

	# Apply the remapping and enable both contexts
	GUIDE.set_remapping_config(remapping)
	GUIDE.enable_mapping_context(_context1)
	GUIDE.enable_mapping_context(_context2)

	# Find the action mapping for our action
	var action_mapping:GUIDEActionMapping = null
	for mapping in GUIDE._active_action_mappings:
		if mapping.action == _action:
			action_mapping = mapping
			break

	assert_that(action_mapping).is_not_null()

	# There should only be ONE input mapping (Joy button A), not two
	assert_int(action_mapping.input_mappings.size()).is_equal(1)

	# Verify the input only triggers once (not twice) when we press the button
	var action_watcher := watch(_action)

	await tap_joy_button(JOY_BUTTON_A)

	assert_bool(await action_watcher.triggered_was_emitted()).is_true()

	# Wait a bit - action should complete normally
	action_watcher.reset()
	await wait_f(10)
	assert_bool(action_watcher.triggered_was_not_emitted()).is_true()


## Edge case: Multiple contexts all remap to the same input.
## Only one input mapping should exist, not multiple.
func test_multiple_contexts_remap_to_same_input() -> void:
	# Three contexts with different inputs, all remap to Joy A
	var space_key := input_key(KEY_SPACE)
	var enter_key := input_key(KEY_ENTER)
	var w_key := input_key(KEY_W)
	var trigger := trigger_pressed()

	map(_context1, _action, space_key, [], [trigger])
	map(_context2, _action, enter_key, [], [trigger])
	map(_context3, _action, w_key, [], [trigger])

	# All three remap to Joy button A
	var remapping := GUIDERemappingConfig.new()
	var joy_a := input_joy_button(JOY_BUTTON_A)
	remapping._bind(_context1, _action, joy_a, 0)
	remapping._bind(_context2, _action, joy_a, 0)
	remapping._bind(_context3, _action, joy_a, 0)

	GUIDE.set_remapping_config(remapping)
	GUIDE.enable_mapping_context(_context1)
	GUIDE.enable_mapping_context(_context2)
	GUIDE.enable_mapping_context(_context3)

	# Find the action mapping
	var action_mapping:GUIDEActionMapping = null
	for mapping in GUIDE._active_action_mappings:
		if mapping.action == _action:
			action_mapping = mapping
			break

	assert_that(action_mapping).is_not_null()
	# Should only have ONE input mapping for Joy A, not three
	assert_int(action_mapping.input_mappings.size()).is_equal(1)

	# Verify it works correctly
	var action_watcher := watch(_action)
	await tap_joy_button(JOY_BUTTON_A)
	assert_bool(await action_watcher.triggered_was_emitted()).is_true()


## Edge case: Remapping to null (unbinding).
## The unbound input should be removed, other context's input should remain.
func test_remapping_to_null_unbinding() -> void:
	var space_key := input_key(KEY_SPACE)
	var joy_a := input_joy_button(JOY_BUTTON_A)
	var trigger := trigger_pressed()

	map(_context1, _action, space_key, [], [trigger])
	map(_context2, _action, joy_a, [], [trigger])

	# Unbind context1's Space key
	var remapping := GUIDERemappingConfig.new()
	remapping._unbind(_context1, _action, 0)

	GUIDE.set_remapping_config(remapping)
	GUIDE.enable_mapping_context(_context1)
	GUIDE.enable_mapping_context(_context2)

	# Find the action mapping
	var action_mapping:GUIDEActionMapping = null
	for mapping in GUIDE._active_action_mappings:
		if mapping.action == _action:
			action_mapping = mapping
			break

	assert_that(action_mapping).is_not_null()
	# Should only have Joy A (Space was unbound)
	assert_int(action_mapping.input_mappings.size()).is_equal(1)
	assert_that(action_mapping.input_mappings[0].input).is_not_null()

	var action_watcher := watch(_action)

	# Space should not trigger
	await tap_key(KEY_SPACE)
	assert_bool(action_watcher.triggered_was_not_emitted()).is_true()

	# Joy A should trigger
	await tap_joy_button(JOY_BUTTON_A)
	assert_bool(await action_watcher.triggered_was_emitted()).is_true()


## Edge case: Priority interaction with remapping.
## When contexts have same priority, more recently enabled context should win.
func test_priority_interaction_with_remapping() -> void:
	var space_key := input_key(KEY_SPACE)
	var joy_a := input_joy_button(JOY_BUTTON_A)
	var trigger := trigger_pressed()

	# Both contexts have same priority (default 0)
	map(_context1, _action, space_key, [], [trigger])
	map(_context2, _action, joy_a, [], [trigger])

	# Context1 remaps to Joy A (same as context2's original)
	var remapping := GUIDERemappingConfig.new()
	remapping._bind(_context1, _action, input_joy_button(JOY_BUTTON_A), 0)

	GUIDE.set_remapping_config(remapping)
	GUIDE.enable_mapping_context(_context1)
	# Enable context2 AFTER context1 (more recent)
	GUIDE.enable_mapping_context(_context2)

	# Find the action mapping
	var action_mapping:GUIDEActionMapping = null
	for mapping in GUIDE._active_action_mappings:
		if mapping.action == _action:
			action_mapping = mapping
			break

	assert_that(action_mapping).is_not_null()
	# Should have only one Joy A mapping (context2 wins as it was enabled more recently)
	assert_int(action_mapping.input_mappings.size()).is_equal(1)

	# Verify it triggers correctly
	var action_watcher := watch(_action)
	await tap_joy_button(JOY_BUTTON_A)
	assert_bool(await action_watcher.triggered_was_emitted()).is_true()


## Edge case: Remapping config applied after contexts are already enabled.
## The remapping should take effect immediately.
func test_remapping_applied_after_contexts_enabled() -> void:
	var space_key := input_key(KEY_SPACE)
	var joy_a := input_joy_button(JOY_BUTTON_A)
	var trigger := trigger_pressed()

	map(_context1, _action, space_key, [], [trigger])
	map(_context2, _action, joy_a, [], [trigger])

	# Enable contexts FIRST
	GUIDE.enable_mapping_context(_context1)
	GUIDE.enable_mapping_context(_context2)

	var action_watcher := watch(_action)

	# Verify both inputs work initially
	await tap_key(KEY_SPACE)
	assert_bool(await action_watcher.triggered_was_emitted()).is_true()
	action_watcher.reset()
	await wait_f(10)

	await tap_joy_button(JOY_BUTTON_A)
	assert_bool(await action_watcher.triggered_was_emitted()).is_true()
	action_watcher.reset()
	await wait_f(10)

	# NOW apply remapping - remap context1 to Joy A (creating duplicate)
	var remapping := GUIDERemappingConfig.new()
	remapping._bind(_context1, _action, input_joy_button(JOY_BUTTON_A), 0)
	GUIDE.set_remapping_config(remapping)

	# Find the action mapping
	var action_mapping:GUIDEActionMapping = null
	for mapping in GUIDE._active_action_mappings:
		if mapping.action == _action:
			action_mapping = mapping
			break

	assert_that(action_mapping).is_not_null()
	# Should have only one Joy A mapping (no duplicates)
	assert_int(action_mapping.input_mappings.size()).is_equal(1)

	action_watcher.reset()

	# Space should no longer work
	await tap_key(KEY_SPACE)
	assert_bool(action_watcher.triggered_was_not_emitted()).is_true()

	# Joy A should work
	await tap_joy_button(JOY_BUTTON_A)
	assert_bool(await action_watcher.triggered_was_emitted()).is_true()


## Edge case: Same context enabled multiple times.
## Should not create duplicate mappings, just update the timestamp.
func test_same_context_enabled_multiple_times() -> void:
	var space_key := input_key(KEY_SPACE)
	var trigger := trigger_pressed()

	map(_context1, _action, space_key, [], [trigger])

	# Enable the same context three times
	GUIDE.enable_mapping_context(_context1)
	GUIDE.enable_mapping_context(_context1)
	GUIDE.enable_mapping_context(_context1)

	# Find the action mapping
	var action_mapping:GUIDEActionMapping = null
	for mapping in GUIDE._active_action_mappings:
		if mapping.action == _action:
			action_mapping = mapping
			break

	assert_that(action_mapping).is_not_null()
	# Should have only one input mapping (not three)
	assert_int(action_mapping.input_mappings.size()).is_equal(1)

	# Verify it works correctly
	var action_watcher := watch(_action)
	await tap_key(KEY_SPACE)
	assert_bool(await action_watcher.triggered_was_emitted()).is_true()


## Edge case: Action priority blocking across merged contexts.
## An action with "block lower priority" should block actions from lower priority contexts.
## Note: Priority is determined by context priority (lower value = higher priority).
## For same-priority contexts, more recently enabled has higher priority.
func test_action_priority_blocking_across_merged_contexts() -> void:
	var dpad_up := input_joy_button(JOY_BUTTON_DPAD_UP)
	var trigger := trigger_pressed()

	# Context 1: high priority action that blocks lower priority
	var high_priority_action := action_bool("high_priority")
	high_priority_action.block_lower_priority_actions = true
	map(_context1, high_priority_action, dpad_up, [], [trigger])

	# Context 2: low priority action (same input)
	var low_priority_action := action_bool("low_priority")
	map(_context2, low_priority_action, dpad_up, [], [trigger])

	# Enable context1 with higher priority (lower number = higher priority)
	# so that high_priority_action can block low_priority_action
	GUIDE.enable_mapping_context(_context1, false, 0)
	GUIDE.enable_mapping_context(_context2, false, 10)

	var high_watcher := watch(high_priority_action)
	var low_watcher := watch(low_priority_action)

	# Press D-pad up - high priority action should trigger and block the low priority one
	await tap_joy_button(JOY_BUTTON_DPAD_UP)

	assert_bool(await high_watcher.triggered_was_emitted()).is_true()
	# Low priority action should be blocked
	assert_bool(low_watcher.triggered_was_not_emitted()).is_true()


## Edge case: Combo mappings with null inputs should not be removed when contexts are merged.
## This ensures that the unbinding fix doesn't accidentally break combo mappings.
func test_combo_mappings_with_null_inputs_are_preserved() -> void:
	# Create two basic actions that the combo will watch for
	var basic_action1 := action_bool("basic_action_1")
	var basic_action2 := action_bool("basic_action_2")

	# Map those basic actions to keys in context1
	map(_context1, basic_action1, input_key(KEY_A), [], [trigger_pressed()])
	map(_context1, basic_action2, input_key(KEY_B), [], [trigger_pressed()])

	# Create a combo trigger that watches for the sequence: basic_action1 -> basic_action2
	var combo_trigger := GUIDETriggerCombo.new()
	var step1 := GUIDETriggerComboStep.new()
	step1.action = basic_action1
	step1.time_to_actuate = 0.5
	var step2 := GUIDETriggerComboStep.new()
	step2.action = basic_action2
	step2.time_to_actuate = 0.5
	combo_trigger.steps = [step1, step2]

	# Create a combo action mapping with null input
	var combo_input_mapping := GUIDEInputMapping.new()
	combo_input_mapping.input = null  # Combo mappings have null input
	combo_input_mapping.triggers = [combo_trigger]

	var combo_action_mapping := GUIDEActionMapping.new()
	combo_action_mapping.action = _action
	combo_action_mapping.input_mappings = [combo_input_mapping]

	# Add the combo mapping to context1
	_context1.mappings.append(combo_action_mapping)

	# Also add a regular mapping in context2 to test merging
	map(_context2, _action, input_key(KEY_SPACE), [], [trigger_pressed()])

	# Enable both contexts
	GUIDE.enable_mapping_context(_context1)
	GUIDE.enable_mapping_context(_context2)

	# Find the action mapping
	var active_mapping:GUIDEActionMapping = null
	for mapping in GUIDE._active_action_mappings:
		if mapping.action == _action:
			active_mapping = mapping
			break

	assert_that(active_mapping).is_not_null()
	# Should have 2 input mappings: one null (combo) and one Space key
	assert_int(active_mapping.input_mappings.size()).is_equal(2)

	# Verify one of them is null (the combo)
	var has_null_input := false
	var has_space_input := false
	for input_map in active_mapping.input_mappings:
		if input_map.input == null:
			has_null_input = true
		elif input_map.input is GUIDEInputKey:
			has_space_input = true

	assert_bool(has_null_input).is_true()
	assert_bool(has_space_input).is_true()

## Tests that the hold threshold hint is properly set when merging contexts.
## This is needed for UI elements like progress bars that show how long until
## a hold action triggers (e.g., the tap_and_hold example).
func test_hold_threshold_hint_with_merged_contexts() -> void:
	var input1 := input_key(KEY_SPACE)
	var input2 := input_joy_button(JOY_BUTTON_A)
	var hold_trigger := trigger_hold(1.0)  # 1 second hold

	# Context 1: Space key with hold trigger
	map(_context1, _action, input1, [], [hold_trigger])
	# Context 2: Joy button with hold trigger
	map(_context2, _action, input2, [], [trigger_hold(1.0)])

	# Enable both contexts to trigger merging
	GUIDE.enable_mapping_context(_context1)
	GUIDE.enable_mapping_context(_context2)

	# The action should have its hold threshold set
	assert_float(_action._trigger_hold_threshold).is_equal(1.0)

	# Press the key and verify elapsed_ratio increases
	var action_watcher := watch(_action)
	await key_down(KEY_SPACE)

	# Wait a bit and check that elapsed_ratio is working
	await wait_f(5)  # 5 frames

	# The action should be ongoing
	assert_bool(await action_watcher.started_was_emitted()).is_true()

	# elapsed_ratio should be between 0 and 1 (not stuck at 0)
	assert_bool(_action.elapsed_ratio > 0.0).is_true()
	assert_bool(_action.elapsed_ratio < 1.0).is_true()

	await key_up(KEY_SPACE)
