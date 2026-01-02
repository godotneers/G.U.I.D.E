## Tests the GUIDE default text provider rendering for all supported input types.
## Ensures GUIDEInputFormatter.input_as_text returns the expected string for each input.
extends GUIDETestBase

var _formatter: GUIDEInputFormatter

# The meta key label is OS specific (e.g. Windows, Cmd, Meta), 
# so we cannot hardcode it.
static var meta_key_label:String = OS.get_keycode_string(KEY_META)
	
# we make a high priority default provider so it doesn't matter which device
# is currently connected, we always get the default strings.	
class DefaultProvider:
	extends GUIDETextProviderDefault
	
	
func _setup() -> void:
	_formatter = auto_free(GUIDEInputFormatter.new())
	GUIDEInputFormatter.add_text_provider(DefaultProvider.new())
	
	
## Keyboard input tests
@warning_ignore("unused_parameter")
func test_key_input_renders_special_keys_with_modifiers(
	key_code: int, control: bool, alt: bool, shift: bool, meta: bool, expected: String,
	test_parameters := [
		[KEY_A, false, false, false, false, "[A]"],
		[KEY_A, true, false, false, false, "[Ctrl] + [A]"],
		[KEY_A, false, true, false, false, "[Alt] + [A]"],
		[KEY_A, false, false, true, false, "[Shift] + [A]"],
		[KEY_A, false, false, false, true, "[" + meta_key_label + "] + [A]"],
		[KEY_A, true, true, true, true, "[Ctrl] + [Alt] + [Shift] + [" +  meta_key_label + "] + [A]"],
		[KEY_ENTER, false, false, false, false, "[Enter]"],
		[KEY_ENTER, true, false, false, false, "[Ctrl] + [Enter]"],
		[KEY_SHIFT, false, false, false, false, "[Shift]"],
		[KEY_ESCAPE, false, false, false, false, "[Escape]"],
		[KEY_ESCAPE, false, true, false, false, "[Alt] + [Escape]"]
	]
) -> void:
	var input: GUIDEInputKey = input_key(key_code)
	input.control = control
	input.alt = alt
	input.shift = shift
	input.meta = meta
	var result: String = _formatter.input_as_text(input)
	assert_str(result).is_equal(expected)

## Mouse button input tests
@warning_ignore("unused_parameter")
func test_mouse_button_input_renders_all_buttons(
	button_code: int, expected: String,
	test_parameters := [
		[MOUSE_BUTTON_LEFT, "[Left Mouse Button]"],
		[MOUSE_BUTTON_RIGHT, "[Right Mouse Button]"],
		[MOUSE_BUTTON_MIDDLE, "[Middle Mouse Button]"],
		[MOUSE_BUTTON_WHEEL_UP, "[Mouse Wheel Up]"],
		[MOUSE_BUTTON_WHEEL_DOWN, "[Mouse Wheel Down]"],
		[MOUSE_BUTTON_WHEEL_LEFT, "[Mouse Wheel Left]"],
		[MOUSE_BUTTON_WHEEL_RIGHT, "[Mouse Wheel Right]"],
		[MOUSE_BUTTON_XBUTTON1, "[Mouse Side 1]"],
		[MOUSE_BUTTON_XBUTTON2, "[Mouse Side 2]"]
	]
) -> void:
	var input: GUIDEInputMouseButton = input_mouse_button(button_code)
	var result: String = _formatter.input_as_text(input)
	assert_str(result).is_equal(expected)

## Mouse axis input tests
@warning_ignore("unused_parameter")
func test_mouse_axis_1d_input_renders_all_axes(
	axis_code: int, expected: String,
	test_parameters := [
		[GUIDEInputMouseAxis1D.GUIDEInputMouseAxis.AXIS_X, "[Mouse Left/Right]"],
		[GUIDEInputMouseAxis1D.GUIDEInputMouseAxis.AXIS_Y, "[Mouse Up/Down]"]
	]
) -> void:
	var input: GUIDEInputMouseAxis1D = input_mouse_axis_1d(axis_code)
	var result: String = _formatter.input_as_text(input)
	assert_str(result).is_equal(expected)

## Joy button input tests
@warning_ignore("unused_parameter")
func test_joy_button_input_renders_all_buttons(
	button_code: int, expected: String,
	test_parameters := [
		[JOY_BUTTON_A, "[Joy 0]"],
		[JOY_BUTTON_B, "[Joy 1]"],
		[JOY_BUTTON_X, "[Joy 2]"],
		[JOY_BUTTON_Y, "[Joy 3]"]
	]
) -> void:
	var input: GUIDEInputJoyButton = input_joy_button(button_code)
	var result: String = _formatter.input_as_text(input)
	assert_str(result).is_equal(expected)

## Joy axis input tests
@warning_ignore("unused_parameter")
func test_joy_axis_1d_input_renders_all_axes(
	axis_code: int, expected: String,
	test_parameters := [
		[JOY_AXIS_LEFT_X, "[Stick 1 Horizontal]"],
		[JOY_AXIS_LEFT_Y, "[Stick 1 Vertical]"],
		[JOY_AXIS_RIGHT_X, "[Stick 2 Horizontal]"],
		[JOY_AXIS_RIGHT_Y, "[Stick 2 Vertical]"],
		[JOY_AXIS_TRIGGER_LEFT, "[Axis 3]"],
		[JOY_AXIS_TRIGGER_RIGHT, "[Axis 4]"]
	]
) -> void:
	var input: GUIDEInputJoyAxis1D = input_joy_axis_1d(axis_code)
	var result: String = _formatter.input_as_text(input)
	assert_str(result).is_equal(expected)

## Joy axis input tests
@warning_ignore("unused_parameter")
func test_joy_axis_2d_input_renders_all_axes(
	x_axis: int, y_axis: int, expected: String,
	test_parameters := [
		[JOY_AXIS_LEFT_X, JOY_AXIS_LEFT_Y, "[Stick 1]"],
		[JOY_AXIS_RIGHT_X, JOY_AXIS_RIGHT_Y, "[Stick 2]"]
	]
) -> void:
	var input: GUIDEInputJoyAxis2D = input_joy_axis_2d(x_axis, y_axis)
	var result: String = _formatter.input_as_text(input)
	assert_str(result).is_equal(expected)


## Mouse axis 2D input tests
@warning_ignore("unused_parameter")
func test_mouse_axis_2d_input_renders_all() -> void:
	var input: GUIDEInputMouseAxis2D = input_mouse_axis_2d()
	var result: String = _formatter.input_as_text(input)
	assert_str(result).is_equal("[Mouse]")

## Mouse position input tests
@warning_ignore("unused_parameter")
func test_mouse_position_input_renders_all() -> void:
	var input: GUIDEInputMousePosition = input_mouse_position()
	var result: String = _formatter.input_as_text(input)
	assert_str(result).is_equal("[Mouse Position]")

## Touch angle input tests
@warning_ignore("unused_parameter")
func test_touch_angle_input_renders_all() -> void:
	var input: GUIDEInputTouchAngle = input_touch_angle()
	var result: String = _formatter.input_as_text(input)
	assert_str(result).is_equal("[Touch Angle]")

## Touch distance input tests
@warning_ignore("unused_parameter")
func test_touch_distance_input_renders_all() -> void:
	var input: GUIDEInputTouchDistance = input_touch_distance()
	var result: String = _formatter.input_as_text(input)
	assert_str(result).is_equal("[Touch Distance]")

## Touch axis 1D input tests
@warning_ignore("unused_parameter")
func test_touch_axis_1d_input_renders_all_axes(
	axis_code: int, finger_index: int, expected: String,
	test_parameters := [
		[GUIDEInputTouchAxis1D.GUIDEInputTouchAxis.AXIS_X, 0, "[Touch Left/Right 0]"],
		[GUIDEInputTouchAxis1D.GUIDEInputTouchAxis.AXIS_X, -1, "[Touch Left/Right Average]"],
		[GUIDEInputTouchAxis1D.GUIDEInputTouchAxis.AXIS_Y, 1, "[Touch Up/Down 1]"],
		[GUIDEInputTouchAxis1D.GUIDEInputTouchAxis.AXIS_Y, -1, "[Touch Up/Down Average]"]
	]
) -> void:
	var input: GUIDEInputTouchAxis1D = input_touch_axis_1d(axis_code, finger_index)
	var result: String = _formatter.input_as_text(input)
	assert_str(result).is_equal(expected)

## Touch axis 2D input tests
@warning_ignore("unused_parameter")
func test_touch_axis_2d_input_renders_all(
	finger_index: int, expected: String,
	test_parameters := [
		[0, "[Touch Axis 2D 0]"],
		[-1, "[Touch Axis 2D Average]"]
	]
) -> void:
	var input: GUIDEInputTouchAxis2D = input_touch_axis_2d(finger_index)
	var result: String = _formatter.input_as_text(input)
	assert_str(result).is_equal(expected)


## Any input tests
@warning_ignore("unused_parameter")
func test_any_input_renders_all(
	joy: bool, mouse: bool, keyboard: bool, expected: String,
	test_parameters := [
		[true, false, false, "[Any Joy Button]"],
		[false, true, false, "[Any Mouse Button]"],
		[false, false, true, "[Any Key]"],
		[true, true, true, "[Any Joy Button/Mouse Button/Key]"]
	]
) -> void:
	var input: GUIDEInputAny = input_any()
	input.joy = joy
	input.mouse = mouse
	input.keyboard = keyboard
	var result: String = _formatter.input_as_text(input)
	assert_str(result).is_equal(expected)
