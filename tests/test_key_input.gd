extends GUIDETestBase

# https://github.com/godotneers/G.U.I.D.E/issues/34
# if modifier IS the bound key, disabling "allow additional modifiers"
# does not prevent the action from triggering
@warning_ignore("unused_parameter")
func test_modifiers(modifier:int, test_parameters := [[KEY_SHIFT], [KEY_CTRL], [KEY_META], [KEY_ALT]]) -> void:
	var mc := mapping_context()
	@warning_ignore("shadowed_variable")
	var _action := action_bool()
	var input := input_key(modifier)
	input.allow_additional_modifiers = false
	map(mc, _action, input)

	GUIDE.enable_mapping_context(mc)
	var watched := watch(_action)

	# WHEN
	await tap_key(modifier)

	# THEN
	await watched.assert_triggered()
	

# If bind something to a key and the modifier is down that is disallowed
# the action is not triggered.
func test_disallowed_modifiers_prevent_action() -> void:
	var mc := mapping_context()
	@warning_ignore("shadowed_variable")
	var _action := action_bool()
	var input := input_key(KEY_A)
	input.control = true
	input.allow_additional_modifiers = false
	map(mc, _action, input)

	GUIDE.enable_mapping_context(mc)
	var watched := watch(_action)

	# WHEN
	await tap_keys([KEY_CTRL, KEY_SHIFT, KEY_A])

	# THEN - not triggered because shift was down in addition to ctrl
	watched.assert_not_triggered()

	# WHEN
	await tap_keys([KEY_CTRL, KEY_A])

	# THEN - triggered because only ctrl + a were down
	await watched.assert_triggered()

