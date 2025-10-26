@tool
## A virtual joystick button.
class_name GUIDEVirtualButton
extends Container

## Called when the button's actuation state changes. Can be used to update
## the rendering of the button on screen.
signal changed()
## Called when the button's configuration changes. Can be used to re-initialize
## renderers.
signal configuration_changed()

enum InputMode {
	## Only react to touch input.
	TOUCH,
	## Only react to mouse input.
	MOUSE,
	## React to both touch and mouse input.
	MOUSE_AND_TOUCH
}

## Radius of the button.
@export var button_radius: float = 100:
	set(value):
		button_radius = value
		queue_redraw()
		configuration_changed.emit()

## The joy button represented by this virtual button.
@export var button_index: JoyButton = JOY_BUTTON_A:
	set(value):
		button_index = value
		configuration_changed.emit()

## Index of the virtual stick this should drive.
@export_range(0, 5, 1, "or_greater") var virtual_stick_index: int = 0:
	set(value):
		virtual_stick_index = value
		configuration_changed.emit()

## The input mode to use.
@export var input_mode: InputMode = InputMode.TOUCH:
	set(value):
		input_mode = value
		configuration_changed.emit()

@export var draw_debug: bool = false:
	set(value):
		draw_debug = value
		queue_redraw()
		configuration_changed.emit()

var _is_actuated: bool = false

## The virtual joy id assigned to this stick.
var _virtual_joy_id : int = 0

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	if Engine.is_editor_hint():
		return # no input processing in the editor
		
	_virtual_joy_id = GUIDE._input_state.connect_virtual_stick(virtual_stick_index)
	_report_input()
	
	if input_mode == InputMode.MOUSE or input_mode == InputMode.MOUSE_AND_TOUCH:
		GUIDE._input_state.mouse_button_state_changed.connect(_handle_mouse_input)
		GUIDE._input_state.mouse_position_changed.connect(_handle_mouse_input)
	
	if input_mode == InputMode.TOUCH or input_mode == InputMode.MOUSE_AND_TOUCH:
		GUIDE._input_state.touch_state_changed.connect(_handle_touch_input)
	
	
func _handle_mouse_input() -> void:
	if not _is_actuated:
		# if the mouse button is down try to actuate using the current
		# mouse position
		if GUIDE._input_state.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
			_try_actuate(_screen_to_world(GUIDE._input_state.get_mouse_position()))
		return
	
	# actuated
	# if the mouse button is no longer down or the mouse position
	# is no longer over the button, release.
	
	if not GUIDE._input_state.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) or \
		not _is_over_button(_screen_to_world(GUIDE._input_state.get_mouse_position())):
			_release()
			get_viewport().set_input_as_handled()
			return


func _handle_touch_input() -> void:
	if not _is_actuated:
		# if any finger is over the button area, actuate
		var positions:Array[Vector2] = GUIDE._input_state.get_finger_positions()
		for position:Vector2 in positions:
			_try_actuate(_screen_to_world(position))

		return

	# actuated
	# if no finger is currently over the button area, release
	var positions:Array[Vector2] = GUIDE._input_state.get_finger_positions()
	var still_active:bool = false
	for position:Vector2 in positions:
		if _is_over_button(_screen_to_world(position)):
			still_active = true
			break
	
	if not still_active:
		_release()

func _is_over_button(world_position:Vector2) -> bool:
	return global_position.distance_squared_to(world_position) <= button_radius * button_radius

func _try_actuate(world_position: Vector2):
	if not _is_actuated and _is_over_button(world_position) :
		_is_actuated = true
		_report_input()

func _release():
	if _is_actuated:
		_is_actuated = false
		_report_input()


func _report_input():
	var event = InputEventJoypadButton.new()
	event.button_index = button_index
	event.pressed = _is_actuated
	event.device = _virtual_joy_id
	GUIDE.inject_input(event)
	if draw_debug:
		queue_redraw()
	changed.emit()


func _screen_to_world(input: Vector2) -> Vector2:
	return get_canvas_transform().affine_inverse() * input


func _draw():
	if not draw_debug:
		return
	
	var color = Color(0.9, 0.9, 0.9, 0.8) if _is_actuated else Color(0.5, 0.5, 0.5, 0.5)
	draw_circle(Vector2.ZERO, button_radius, color)
