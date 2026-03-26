@tool
class_name GUIDEControllerRenderer
extends GUIDEIconRenderer

const GUIDEFormattingUtils = preload("../../guide_formatting_utils.gd")
const ControllerType = GUIDEFormattingUtils.ControllerType

## Icon sets to be used for the controller types. The key is the controller type, the value is an
## icon set that should be used.
static var _controller_styles:Dictionary = {
	ControllerType.MICROSOFT: preload("styles/microsoft/microsoft.tres"),
	ControllerType.NINTENDO: preload("styles/nintendo/nintendo.tres"),
	ControllerType.SONY: preload("styles/sony/sony.tres"),
	ControllerType.STEAM_DECK: preload("styles/steam_deck/steam_deck.tres"),
}

@onready var _a_button:TextureRect = %AButton
@onready var _b_button:TextureRect = %BButton
@onready var _x_button:TextureRect = %XButton
@onready var _y_button:TextureRect = %YButton
@onready var _left_stick:TextureRect = %LeftStick
@onready var _left_stick_click:TextureRect = %LeftStickClick
@onready var _right_stick:TextureRect = %RightStick
@onready var _right_stick_click:TextureRect = %RightStickClick
@onready var _left_bumper:Control = %LeftBumper
@onready var _right_bumper:Control = %RightBumper
@onready var _left_trigger:Control = %LeftTrigger
@onready var _right_trigger:TextureRect = %RightTrigger
@onready var _dpad_up:TextureRect = %DpadUp
@onready var _dpad_left:TextureRect = %DpadLeft
@onready var _dpad_right:TextureRect = %DpadRight
@onready var _dpad_down:TextureRect = %DpadDown
@onready var _start:TextureRect = %Start
@onready var _misc1:TextureRect = %Misc1
@onready var _back:TextureRect = %Back
@onready var _left_right:TextureRect = %LeftRight
@onready var _up_down:TextureRect = %UpDown
@onready var _controls:Control = %Controls
@onready var _directions:Control = %Directions
@onready var _touch_pad:TextureRect = %TouchPad


func _init():
	priority = -10

func _ready():
	super()

## Sets the style that is used for rendering the given controller type.
static func set_style(type:ControllerType, style:GUIDEControllerRenderStyle) -> void:
	if not is_instance_valid(style):
		push_error("Icon set must not be null.")
		return

	if type == ControllerType.UNKNOWN:
		push_error("Cannot set icon set for the unknown controller. Use GUIDEInputFormattingOptions to set up how unknown controllers are rendered.")
		return

	_controller_styles[type] = style


## Sets up the textures for the given controller type.
func _setup_textures(type:ControllerType) -> void:
	if type == ControllerType.UNKNOWN:
		push_error("Tried to set up textures with unknown controller type. This is a bug, please report it.")
		return

	var style:GUIDEControllerRenderStyle = _controller_styles[type]

	_a_button.texture = style.a_button
	_b_button.texture = style.b_button
	_x_button.texture = style.x_button
	_y_button.texture = style.y_button
	_left_stick.texture = style.left_stick
	_left_stick_click.texture = style.left_stick_click
	_right_stick.texture = style.right_stick
	_right_stick_click.texture = style.right_stick_click
	_left_bumper.texture = style.left_bumper
	_right_bumper.texture = style.right_bumper
	_left_trigger.texture = style.left_trigger
	_right_trigger.texture = style.right_trigger
	_dpad_up.texture = style.dpad_up
	_dpad_left.texture = style.dpad_left
	_dpad_right.texture = style.dpad_right
	_dpad_down.texture = style.dpad_down
	_start.texture = style.start
	_misc1.texture = style.misc1
	_back.texture = style.back
	_touch_pad.texture = style.touch_pad
	_left_right.texture = style.horizontal
	_up_down.texture = style.vertical


func supports(input:GUIDEInput, options:GUIDEInputFormattingOptions) -> bool:
	# we support rendering if the input effectively can be mapped to any known
	# controller type using the options
	return GUIDEFormattingUtils.effective_controller_type(input, options) != ControllerType.UNKNOWN



func render(input:GUIDEInput, options:GUIDEInputFormattingOptions) -> void:
	# get effective controller type to use the correct textures.
	var controller_type := GUIDEFormattingUtils.effective_controller_type(input, options)
	_setup_textures(controller_type)

	for control in _controls.get_children():
		control.visible = false
	for direction in _directions.get_children():
		direction.visible = false
	_directions.visible = false


	if input is GUIDEInputJoyAxis1D:
		match input.axis:
			JOY_AXIS_LEFT_X:
				_left_stick.visible = true
				_show_left_right()
			JOY_AXIS_LEFT_Y:
				_left_stick.visible = true
				_show_up_down()
			JOY_AXIS_RIGHT_X:
				_right_stick.visible = true
				_show_left_right()
			JOY_AXIS_RIGHT_Y:
				_right_stick.visible = true
				_show_up_down()
			JOY_AXIS_TRIGGER_LEFT:
				_left_trigger.visible = true
			JOY_AXIS_TRIGGER_RIGHT:
				_right_trigger.visible = true

	if input is GUIDEInputJoyAxis2D:
		# We assume that there is no input mixing horizontal and vertical
		# from different sticks into a 2D axis as this would confuse the
		# players.
		match input.x:
			JOY_AXIS_LEFT_X, JOY_AXIS_LEFT_Y:
				_left_stick.visible = true
			JOY_AXIS_RIGHT_X, JOY_AXIS_RIGHT_Y:
				_right_stick.visible = true

	if input is GUIDEInputJoyButton:
		match input.button:
			JOY_BUTTON_A:
				_a_button.visible = true
			JOY_BUTTON_B:
				_b_button.visible = true
			JOY_BUTTON_X:
				_x_button.visible = true
			JOY_BUTTON_Y:
				_y_button.visible = true
			JOY_BUTTON_DPAD_LEFT:
				_dpad_left.visible = true
			JOY_BUTTON_DPAD_RIGHT:
				_dpad_right.visible = true
			JOY_BUTTON_DPAD_UP:
				_dpad_up.visible = true
			JOY_BUTTON_DPAD_DOWN:
				_dpad_down.visible = true
			JOY_BUTTON_LEFT_SHOULDER:
				_left_bumper.visible = true
			JOY_BUTTON_RIGHT_SHOULDER:
				_right_bumper.visible = true
			JOY_BUTTON_LEFT_STICK:
				_left_stick_click.visible = true
			JOY_BUTTON_RIGHT_STICK:
				_right_stick_click.visible = true
			JOY_BUTTON_RIGHT_STICK:
				_right_stick_click.visible = true
			JOY_BUTTON_START:
				_start.visible = true
			JOY_BUTTON_BACK:
				_back.visible = true
			JOY_BUTTON_MISC1:
				_misc1.visible = true
			JOY_BUTTON_TOUCHPAD:
				_touch_pad.visible = true

	call("queue_sort")

func _show_left_right():
	_directions.visible = true
	_left_right.visible = true

func _show_up_down():
	_directions.visible = true
	_up_down.visible = true


func cache_key(input:GUIDEInput, options:GUIDEInputFormattingOptions) -> String:
	var controller_type := GUIDEFormattingUtils.effective_controller_type(input, options)
	var icon_set:GUIDEControllerRenderStyle = _controller_styles[controller_type]

	return "7581f483-bc68-411f-98ad-dc246fd2593a" \
		# output depends on the input to render
		+ input.to_string() \
		# and the icon set we use to render it
		+ icon_set.resource_path
