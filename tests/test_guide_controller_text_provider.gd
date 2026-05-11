## Tests the controller text provider rendering for all supported input types.
## Uses FORCE_JOY_TYPE to avoid requiring a physical controller to be connected.
extends GUIDETestBase

var _formatter: GUIDEInputFormatter

func _setup() -> void:
	_formatter = auto_free(GUIDEInputFormatter.new())
	_formatter.formatting_options.joy_rendering = GUIDEInputFormattingOptions.JoyRendering.FORCE_JOY_TYPE
	_formatter.formatting_options.preferred_joy_type = GUIDEInputFormattingOptions.JoyType.MICROSOFT_CONTROLLER


func _as_microsoft(input: GUIDEInput) -> String:
	_formatter.formatting_options.preferred_joy_type = GUIDEInputFormattingOptions.JoyType.MICROSOFT_CONTROLLER
	return _formatter.input_as_text(input)


func _as_nintendo(input: GUIDEInput) -> String:
	_formatter.formatting_options.preferred_joy_type = GUIDEInputFormattingOptions.JoyType.NINTENDO_CONTROLLER
	return _formatter.input_as_text(input)


## supports tests

func test_supports_returns_false_for_non_joy_input() -> void:
	var provider := GUIDEControllerTextProvider.new()
	var options := GUIDEInputFormattingOptions.new()
	assert_bool(provider.supports(input_key(KEY_A), options)).is_false()


func test_supports_returns_true_with_forced_controller_type() -> void:
	var provider := GUIDEControllerTextProvider.new()
	var options := GUIDEInputFormattingOptions.new()
	options.joy_rendering = GUIDEInputFormattingOptions.JoyRendering.FORCE_JOY_TYPE
	options.preferred_joy_type = GUIDEInputFormattingOptions.JoyType.MICROSOFT_CONTROLLER
	assert_bool(provider.supports(input_joy_button(JOY_BUTTON_A), options)).is_true()


## JoyAxis1D tests

@warning_ignore("unused_parameter")
func test_joy_axis_1d_renders_correctly_for_microsoft(
	axis_code: int, expected: String,
	test_parameters := [
		[JOY_AXIS_LEFT_X, "[Left Stick Horizontal]"],
		[JOY_AXIS_LEFT_Y, "[Left Stick Vertical]"],
		[JOY_AXIS_RIGHT_X, "[Right Stick Horizontal]"],
		[JOY_AXIS_RIGHT_Y, "[Right Stick Vertical]"],
		[JOY_AXIS_TRIGGER_LEFT, "[LT]"],
		[JOY_AXIS_TRIGGER_RIGHT, "[RT]"]
	]
) -> void:
	assert_str(_as_microsoft(input_joy_axis_1d(axis_code))).is_equal(expected)


## JoyDirection tests

@warning_ignore("unused_parameter")
func test_joy_direction_renders_correctly_for_microsoft(
	axis_code: int, direction: int, expected: String,
	test_parameters := [
		[JOY_AXIS_LEFT_X, GUIDEInputJoyDirection.Direction.POSITIVE, "[Left Stick Right]"],
		[JOY_AXIS_LEFT_X, GUIDEInputJoyDirection.Direction.NEGATIVE, "[Left Stick Left]"],
		[JOY_AXIS_LEFT_Y, GUIDEInputJoyDirection.Direction.POSITIVE, "[Left Stick Down]"],
		[JOY_AXIS_LEFT_Y, GUIDEInputJoyDirection.Direction.NEGATIVE, "[Left Stick Up]"],
		[JOY_AXIS_RIGHT_X, GUIDEInputJoyDirection.Direction.POSITIVE, "[Right Stick Right]"],
		[JOY_AXIS_RIGHT_X, GUIDEInputJoyDirection.Direction.NEGATIVE, "[Right Stick Left]"],
		[JOY_AXIS_RIGHT_Y, GUIDEInputJoyDirection.Direction.POSITIVE, "[Right Stick Down]"],
		[JOY_AXIS_RIGHT_Y, GUIDEInputJoyDirection.Direction.NEGATIVE, "[Right Stick Up]"]
	]
) -> void:
	assert_str(_as_microsoft(input_joy_direction(axis_code, direction))).is_equal(expected)


## JoyAxis2D tests

@warning_ignore("unused_parameter")
func test_joy_axis_2d_renders_correctly_for_microsoft(
	x_axis: int, y_axis: int, expected: String,
	test_parameters := [
		[JOY_AXIS_LEFT_X, JOY_AXIS_LEFT_Y, "[Left Stick]"],
		[JOY_AXIS_RIGHT_X, JOY_AXIS_RIGHT_Y, "[Right Stick]"]
	]
) -> void:
	assert_str(_as_microsoft(input_joy_axis_2d(x_axis, y_axis))).is_equal(expected)


## JoyButton tests

@warning_ignore("unused_parameter")
func test_joy_button_renders_correctly_for_microsoft(
	button_code: int, expected: String,
	test_parameters := [
		[JOY_BUTTON_A, "[A]"],
		[JOY_BUTTON_B, "[B]"],
		[JOY_BUTTON_X, "[X]"],
		[JOY_BUTTON_Y, "[Y]"],
		[JOY_BUTTON_LEFT_SHOULDER, "[LB]"],
		[JOY_BUTTON_RIGHT_SHOULDER, "[RB]"],
		[JOY_BUTTON_LEFT_STICK, "[Left Stick Click]"],
		[JOY_BUTTON_RIGHT_STICK, "[Right Stick Click]"],
		[JOY_BUTTON_DPAD_UP, "[DPAD Up]"],
		[JOY_BUTTON_DPAD_DOWN, "[DPAD Down]"],
		[JOY_BUTTON_DPAD_LEFT, "[DPAD Left]"],
		[JOY_BUTTON_DPAD_RIGHT, "[DPAD Right]"],
		[JOY_BUTTON_START, "[Menu]"],
		[JOY_BUTTON_BACK, "[View]"]
	]
) -> void:
	assert_str(_as_microsoft(input_joy_button(button_code))).is_equal(expected)


## Cross-controller spot-check: verifies label set switching works

@warning_ignore("unused_parameter")
func test_nintendo_controller_uses_swapped_ab_labels(
	button_code: int, expected: String,
	test_parameters := [
		[JOY_BUTTON_A, "[B]"],
		[JOY_BUTTON_B, "[A]"]
	]
) -> void:
	assert_str(_as_nintendo(input_joy_button(button_code))).is_equal(expected)
