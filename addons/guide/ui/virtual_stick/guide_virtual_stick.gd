@tool
class_name GUIDEVirtualStick
extends Container

signal changed()

enum InputMode {
	## Only react to touch input.
	TOUCH,
	## Only react to mouse input.
	MOUSE,
	## React to both touch and mouse input.
	MOUSE_AND_TOUCH
}
enum PositionMode {
	## The stick center stays at the designed position
	FIXED,
	
	## The stick center moves to touched/clicked position when the 
	## stick is first actuated, then returns to the designed position
	## when released.
	RELATIVE
}
enum StickPosition {
	LEFT,
	RIGHT
}

## Radius of the zone in which interactions should be tracked.
@export var interaction_zone_radius: float = 200:
	set(value):
		interaction_zone_radius = value
		queue_redraw()

## Radius of the stick.
@export var stick_radius: float = 100:
	set(value):
		stick_radius = value
		queue_redraw()

## Maximum radius that the stick can be moved.
@export var max_actuation_radius: float = 100:
	set(value):
		max_actuation_radius = value
		queue_redraw()

## Whether this is left or right stick (used for mapping the inputs).
@export var stick_position: StickPosition = StickPosition.LEFT

## Index of the virtual stick this should drive.
@export_range(0, 5, 1, "or_greater") var virtual_stick_index: int = 0

## The input mode to use.
@export var input_mode: InputMode = InputMode.TOUCH

## The position mode to use.
@export var position_mode: PositionMode = PositionMode.FIXED

@export var draw_debug: bool = false:
	set(value):
		draw_debug = value
		queue_redraw()

var _is_actuated: bool = false
var _start_pos: Vector2
var _current_pos: Vector2

var stick_relative_position:Vector2:
	get: return _screen_to_world(_start_pos - _current_pos)

func _ready():
	_start_pos = global_position
	_current_pos = global_position
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_report_input()


func _input(event: InputEvent):
	if event is InputEventMouse:
		if input_mode == InputMode.MOUSE or input_mode == InputMode.MOUSE_AND_TOUCH:
			_handle_mouse_input(event)

	if event is InputEventScreenTouch or event is InputEventScreenDrag:
		if input_mode == InputMode.MOUSE or input_mode == InputMode.MOUSE_AND_TOUCH:
			_handle_touch_input(event)


func _handle_mouse_input(event: InputEventMouse) -> void:
	if not _is_actuated:
		# if the mouse moves while we're not actuated, this has no effect
		# so we can skip this one.
		if event is InputEventMouseMotion:
			return

		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			var pos := _screen_to_world(event.position)
			# try to actuate joystick at the given position
			_try_actuate(pos)
			if _is_actuated:
				get_viewport().set_input_as_handled()

		return

	# actuated
	if event is InputEventMouseMotion:
		var pos := _screen_to_world(event.position)
		_move_towards(pos)
		get_viewport().set_input_as_handled()
		return

	if not event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_release()
		get_viewport().set_input_as_handled()


func _handle_touch_input(event: InputEvent) -> void:
	if not _is_actuated:
		# ignore drag events if we're not actuated
		if event is InputEventScreenDrag:
			return

		# must be an InputEventScreenTouch now
		if event.pressed:
			var pos := _screen_to_world(event.position)
			_try_actuate(pos)
			if _is_actuated:
				get_viewport().set_input_as_handled()
			return

		return

	# actuated
	var pos := _screen_to_world(event.position)
	# we can have multiple touches, so we only care about the one that is still over the joystick
	# area
	if pos.distance_to(_current_pos) > stick_radius:
		return

	if event is InputEventScreenDrag:
		_move_towards(pos)
		get_viewport().set_input_as_handled()
		return

	# must be an InputEventScreenTouch now
	if not event.pressed:
		_release()
		get_viewport().set_input_as_handled()


func _try_actuate(world_position: Vector2):
	match position_mode:
		PositionMode.FIXED:
			# in fixed mode, the starting position must be inside the joystick area
			if world_position.distance_to(global_position) > stick_radius:
				return

			_start_pos = global_position
			_current_pos = world_position
			_is_actuated = true
			_report_input()

		PositionMode.RELATIVE:
			# in relative mode, the starting position must be somewhere inside the 
			# interaction area
			if world_position.distance_to(global_position) > interaction_zone_radius:
				return

			_start_pos = world_position
			_current_pos = world_position
			_is_actuated = true
			_report_input()


func _move_towards(world_position: Vector2):
	var direction = _start_pos.direction_to(world_position)
	var distance = _start_pos.distance_to(world_position)
	_current_pos = _start_pos + direction * min(distance, max_actuation_radius)
	_report_input()


func _release():
	_is_actuated = false
	_start_pos = global_position
	_current_pos = global_position
	_report_input()


func _report_input():
	var direction := Vector2.ZERO
	if not _start_pos.is_equal_approx(_current_pos):
		direction = _start_pos.direction_to(_current_pos)

	var distance: float = _start_pos.distance_to(_current_pos)
	var offset:Vector2 = direction * (distance / max_actuation_radius)

	match stick_position:
		StickPosition.LEFT:
			GUIDEInternalVirtualJoyRelay.submit_axis_change(virtual_stick_index, JOY_AXIS_LEFT_X, offset.x)
			GUIDEInternalVirtualJoyRelay.submit_axis_change(virtual_stick_index, JOY_AXIS_LEFT_Y, offset.y)
		StickPosition.RIGHT:
			GUIDEInternalVirtualJoyRelay.submit_axis_change(virtual_stick_index, JOY_AXIS_RIGHT_X, offset.x)
			GUIDEInternalVirtualJoyRelay.submit_axis_change(virtual_stick_index, JOY_AXIS_RIGHT_Y, offset.y)
	if draw_debug:
		queue_redraw()
	
	changed.emit()


func _screen_to_world(input: Vector2) -> Vector2:
	return get_canvas_transform().affine_inverse() * input


func _draw():
	if not draw_debug:
		return
	
	if not _is_actuated:
		draw_circle(Vector2.ZERO, interaction_zone_radius, Color(0.5, 0.5, 1.0, 0.5))
		draw_circle(Vector2.ZERO, max_actuation_radius, Color(0.9, 0.2, 0.2, 0.5))	
		draw_circle(Vector2.ZERO, stick_radius, Color(0.9, 0.9, 0.3, 0.5))
		return

	draw_circle(_start_pos - global_position, interaction_zone_radius, Color(0.5, 0.5, 1.0, 0.5))
	draw_circle(_start_pos - global_position, max_actuation_radius, Color(0.9, 0.2, 0.2, 0.5))
	draw_circle(_current_pos - global_position, stick_radius, Color(0.9, 0.9, 0.3, 0.5))
		
	
