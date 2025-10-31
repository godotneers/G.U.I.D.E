class_name GUIDEVirtualJoyBase
extends Container

## Called when the control's actuation state changes. Can be used to update
## the rendering of the button on screen.
signal changed()

## Called when the control's configuration changes. Can be used to re-initialize
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

## Index of the virtual stick this should drive.
@export_enum("Virtual 1:0", "Virtual 2:1", "Virtual 3:2", "Virtual 4:3") var virtual_device: int = 0:
	set(value):
		virtual_device = value
		_reconnect()
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

## Connects this virtual device to the input system. If already connected,
## it will first disconnect.
func _reconnect() -> void:	
	if not is_node_ready():
		return
		
	if _virtual_joy_id != 0:
		GUIDE._input_state.disconnect_virtual_stick(_virtual_joy_id)
	
	_virtual_joy_id = GUIDE._input_state.connect_virtual_stick(virtual_device)
	

## Handles input events. This is done here and not in the GUIDE input state
## because this should behave like a control node and should consume input events
## that it uses so they don't propagate to other nodes.
func _input(event: InputEvent) -> void:
	if event is InputEventMouse:
		if input_mode == InputMode.MOUSE or input_mode == InputMode.MOUSE_AND_TOUCH:
			_handle_mouse_input(event)

	if event is InputEventScreenTouch or event is InputEventScreenDrag:
		if input_mode == InputMode.TOUCH or input_mode == InputMode.MOUSE_AND_TOUCH:
			_handle_touch_input(event)


## Handles input from the mouse.
func _handle_mouse_input(event: InputEventMouse) -> void:
	pass
	
	
## Handles input from touch devices.
func _handle_touch_input(event: InputEvent) -> void:
	pass

## Converts screen coordinates to world coordinates.
func _screen_to_world(input: Vector2) -> Vector2:
	return get_canvas_transform().affine_inverse() * input	
