extends GUIDETestBase


var _context: GUIDEMappingContext
var _action: GUIDEAction

func _setup() -> void:
	_context = mapping_context()
	_action = action_bool()


func test_positive_direction_triggers_when_axis_meets_threshold() -> void:
	var input := input_joy_direction(JOY_AXIS_LEFT_X, GUIDEInputJoyDirection.Direction.POSITIVE)
	map(_context, _action, input)

	GUIDE.enable_mapping_context(_context)
	var watched := watch(_action)

	# WHEN
	# I push the left stick positive past the threshold
	await joy_axis(JOY_AXIS_LEFT_X, 0.6)

	# THEN
	# the action is triggered
	await watched.assert_triggered()

	# and the value is true
	assert_bool(_action.value_bool).is_true()


func test_negative_direction_triggers_when_axis_meets_threshold() -> void:
	var input := input_joy_direction(JOY_AXIS_LEFT_X, GUIDEInputJoyDirection.Direction.NEGATIVE)
	map(_context, _action, input)

	GUIDE.enable_mapping_context(_context)
	var watched := watch(_action)

	# WHEN
	# I push the left stick negative past the threshold
	await joy_axis(JOY_AXIS_LEFT_X, -0.6)

	# THEN
	# the action is triggered
	await watched.assert_triggered()

	# and the value is true
	assert_bool(_action.value_bool).is_true()


func test_does_not_trigger_when_axis_value_is_below_threshold() -> void:
	var input := input_joy_direction(JOY_AXIS_LEFT_X, GUIDEInputJoyDirection.Direction.POSITIVE)
	map(_context, _action, input)

	GUIDE.enable_mapping_context(_context)
	var watched := watch(_action)

	# WHEN
	# I push the left stick positive but below the threshold
	await joy_axis(JOY_AXIS_LEFT_X, 0.3)

	# THEN
	# the action is not triggered
	watched.assert_not_triggered()

	# and the value is false
	assert_bool(_action.value_bool).is_false()


func test_positive_direction_does_not_trigger_on_negative_axis_value() -> void:
	var input := input_joy_direction(JOY_AXIS_LEFT_X, GUIDEInputJoyDirection.Direction.POSITIVE)
	map(_context, _action, input)

	GUIDE.enable_mapping_context(_context)
	var watched := watch(_action)

	# WHEN
	# I push the left stick in the negative direction
	await joy_axis(JOY_AXIS_LEFT_X, -0.6)

	# THEN
	# the action is not triggered
	watched.assert_not_triggered()


func test_negative_direction_does_not_trigger_on_positive_axis_value() -> void:
	var input := input_joy_direction(JOY_AXIS_LEFT_X, GUIDEInputJoyDirection.Direction.NEGATIVE)
	map(_context, _action, input)

	GUIDE.enable_mapping_context(_context)
	var watched := watch(_action)

	# WHEN
	# I push the left stick in the positive direction
	await joy_axis(JOY_AXIS_LEFT_X, 0.6)

	# THEN
	# the action is not triggered
	watched.assert_not_triggered()


func test_ignores_other_axis() -> void:
	var input := input_joy_direction(JOY_AXIS_LEFT_X, GUIDEInputJoyDirection.Direction.POSITIVE)
	map(_context, _action, input)

	GUIDE.enable_mapping_context(_context)
	var watched := watch(_action)

	# WHEN
	# I push the left stick on the Y axis
	await joy_axis(JOY_AXIS_LEFT_Y, 0.6)

	# THEN
	# the action is not triggered
	watched.assert_not_triggered()


func test_custom_actuation_threshold_is_respected() -> void:
	var input := input_joy_direction(JOY_AXIS_LEFT_X, GUIDEInputJoyDirection.Direction.POSITIVE, 0.3)
	map(_context, _action, input)

	GUIDE.enable_mapping_context(_context)
	var watched := watch(_action)

	# WHEN
	# I push the left stick past the custom threshold but below the default
	await joy_axis(JOY_AXIS_LEFT_X, 0.4)

	# THEN
	# the action is triggered
	await watched.assert_triggered()
