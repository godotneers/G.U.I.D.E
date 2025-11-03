@tool
@icon("guide_virtual_button.svg")
## A virtual joystick button.
class_name GUIDEVirtualButton
extends GUIDEVirtualJoyBase

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

## The finger positions that are currently touching the screen.
var _finger_positions:Dictionary = {}

## Whether or not we consumed the mouse down event.
var _mouse_down_consumed: bool = false

func _ready() -> void:
	use_top_left = true
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	size = Vector2.ZERO
	# the editor likes to set the size to 40x40, we'll override that
	if Engine.is_editor_hint():
		set_deferred("size", Vector2.ZERO)
		
	# let renderers know the initial configuration
	configuration_changed.emit()
	# and the initial state
	changed.emit()
		
	if Engine.is_editor_hint():
		return # no input processing in the editor
		
	_reconnect()
	_report_input()
	

## Handles input from the mouse.
func _handle_mouse_input(event:InputEventMouse) -> void:
	var pos := _screen_to_world(event.position)
	if not _is_actuated:
		if event is InputEventMouseMotion:
			if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
				# try to actuate joystick at the given position
				# print("try_actuate", pos, event.position)
				_try_actuate(pos)
				if _is_over_button(pos):
					get_viewport().set_input_as_handled()
			return
		
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			# try to actuate button at the given position
			_try_actuate(pos)
			
			# we handled this input if it was over the button, otherwise let it propagate
			if _is_over_button(pos):
				_mouse_down_consumed = true
				get_viewport().set_input_as_handled()
		return

	# actuated
	# if the mouse leaves the button area while moving, release
	# this works differently than a UI button which would only release
	# on mouse up, but this is more like a physical button would behave.
	if event is InputEventMouseMotion:
		# check if the mouse is still over the button
		if not _is_over_button(pos):
			_release()
		get_viewport().set_input_as_handled()
		return
		
	# mouse button released, release the button
	if not event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_release()
		# only consume the event if we also consumed the press
		
		get_viewport().set_input_as_handled()
	

## Handles input from touch devices.
func _handle_touch_input(event:InputEvent) -> void:
	# update finger positions
	if event is InputEventScreenTouch:
		if event.pressed:
			_finger_positions[event.index] = event.position
		else:
			_finger_positions.erase(event.index)
	elif event is InputEventScreenDrag:
		_finger_positions[event.index] = event.position
	
	# everything that happens over the button area is considered handled
	if _is_over_button(event.position):
		get_viewport().set_input_as_handled()
	
	if not _is_actuated:
		# if any finger is over the button area, try to actuate
		for position:Vector2 in _finger_positions.values():
			var pos := _screen_to_world(position)
			_try_actuate(pos)
		return
	
	# actuated
	# if no finger is currently over the button area, release
	for position:Vector2 in _finger_positions.values():
		var pos := _screen_to_world(position)
		if _is_over_button(pos):
			return  # still over the button, do nothing
	
	_release()

## Returns whether the given world position is over the button area.
func _is_over_button(world_position:Vector2) -> bool:
	return global_position.distance_squared_to(world_position) <= button_radius * button_radius


## Tries to actuate the button using the given world position.
func _try_actuate(world_position: Vector2):
	if not _is_actuated and _is_over_button(world_position) :
		_is_actuated = true
		_report_input()

## Releases the button.
func _release():
	if _is_actuated:
		_is_actuated = false
		_report_input()

## Reports the current input state to the input system.
func _report_input():
	var event = InputEventJoypadButton.new()
	event.button_index = button_index
	event.pressed = _is_actuated
	event.device = _virtual_joy_id
	GUIDE.inject_input(event)
	if draw_debug:
		queue_redraw()
	changed.emit()

## Draws the debug representation of the button.
func _draw():
	if not draw_debug:
		return
	## 
	var color = Color(0.9, 0.9, 0.9, 0.8) if _is_actuated else Color(0.5, 0.5, 0.5, 0.5)
	draw_circle(Vector2.ZERO, button_radius, color)
