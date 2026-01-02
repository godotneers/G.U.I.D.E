extends GUIDETestBase

var _context: GUIDEMappingContext
var _action_a: GUIDEAction
var _action_lt_a: GUIDEAction
var _modifier_lt: GUIDEAction

func _setup() -> void:
	_context = mapping_context()
	_action_a = action_bool("a")
	_action_lt_a = action_bool("lt+a")
	_modifier_lt = action_bool("lt")

	# Modifier action: hold left trigger
	map(_context, _modifier_lt, input_joy_axis_1d(JOY_AXIS_TRIGGER_LEFT))

	var a_button := input_joy_button(JOY_BUTTON_A)

	# Chorded action: LT + A has higher priority because defined earlier
	map(_context, _action_lt_a, a_button, [], [trigger_chorded_action(_modifier_lt), trigger_pressed()])

	# Base action: press A
	map(_context, _action_a, a_button, [] , [trigger_pressed()])

	GUIDE.enable_mapping_context(_context)


func test_a_triggers_without_modifier() -> void:
	# WHEN: I press A without holding LT
	await tap_joy_button(JOY_BUTTON_A)

	# THEN: only the simple A action triggers
	await assert_triggered(_action_a)
	await assert_not_triggered(_action_lt_a)


func test_chorded_action_blocks_lower_priority() -> void:
	for a:GUIDEAction in GUIDE._actions_sharing_input.keys():
		print("%s > %s" % [a.name, GUIDE._actions_sharing_input[a][0].name])
	await joy_axis(JOY_AXIS_TRIGGER_LEFT, 1.0)
	await tap_joy_button(JOY_BUTTON_A)
	await joy_axis(JOY_AXIS_TRIGGER_LEFT, 0.0)

	# THEN: the chorded action (LT + A) triggers and blocks the plain A action
	await assert_triggered(_action_lt_a)
	await assert_not_triggered(_action_a)
