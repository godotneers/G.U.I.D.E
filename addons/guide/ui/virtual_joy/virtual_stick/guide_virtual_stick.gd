@tool
@icon("guide_virtual_stick.svg")
## A virtual joystick.
class_name GUIDEVirtualStick
extends GUIDEVirtualJoyBase

## Positioning mode for the virtual stick.
enum PositionMode {
	## The stick center stays at the designed position
	FIXED,
	
	## The stick center moves to touched/clicked position when the 
	## stick is first actuated, then returns to the designed position
	## when released.
	RELATIVE
}

## Which stick this is.
enum StickPosition {
	## This represents the left stick.
	LEFT,
	## This represents the right stick.
	RIGHT
}

## Radius of the zone in which interactions should be tracked.
@export var interaction_zone_radius: float = 200:
	set(value):
		interaction_zone_radius = value
		queue_redraw()
		configuration_changed.emit()

## Radius of the stick.
@export var stick_radius: float = 100:
	set(value):
		stick_radius = value
		queue_redraw()
		configuration_changed.emit()

## Maximum radius that the stick can be moved.
@export var max_actuation_radius: float = 100:
	set(value):
		max_actuation_radius = value
		queue_redraw()
		configuration_changed.emit()

## Whether this is left or right stick (used for mapping the inputs).
@export var stick_position: StickPosition = StickPosition.LEFT:
	set(value):
		stick_position = value
		configuration_changed.emit()

## The position mode to use.
@export var position_mode: PositionMode = PositionMode.FIXED:
	set(value):
		position_mode = value
		configuration_changed.emit()

# The initial position of the stick, when not being actuated.
var _initial_pos:Vector2

# The global position where the stick was when it started to be actuated.
# If the mode is FIXED, this is equal to _initial_pos, otherwise this
# is the position where the finger came down within the interaction zone.
var _start_pos: Vector2

# The current global position of the stick
var _current_pos: Vector2


## The index of the finger which is currently controlling this stick. Is -1 if no finger controls it.
var _finger_index:int = -1

## Stick position relative to the center of the stick in world coordinates.
var stick_relative_position:Vector2:
	get: return _current_pos - _start_pos

func _ready() -> void:
	use_top_left = true
	size = Vector2.ZERO
	# the editor likes to set the size to 40x40, we'll override that
	if Engine.is_editor_hint():
		set_deferred("size", Vector2.ZERO)
	_initial_pos = global_position
	_start_pos = global_position
	_current_pos = global_position
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	# let renderers know the initial configuration
	configuration_changed.emit()
	# and the initial state
	changed.emit()

	if Engine.is_editor_hint():
		# no input processing in the editor
		return
		
	# connect to GUIDE
	_reconnect()
	# and report the initial state.
	_report_input()


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
				_finger_index = event.index
				get_viewport().set_input_as_handled()
			return
		return

	# actuated
	if event.index != _finger_index:
		return # we only react to events of the finger that actuated this stick
		

	if event is InputEventScreenDrag:
		var pos := _screen_to_world(event.position)
		_move_towards(pos)
		get_viewport().set_input_as_handled()
		return

	# must be an InputEventScreenTouch now
	if not event.pressed:
		_release()
		get_viewport().set_input_as_handled()
		_finger_index = -1
		

func _try_actuate(world_position: Vector2) -> void:
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

			global_position = world_position
			_start_pos = world_position
			_current_pos = world_position
			_is_actuated = true
			_report_input()

## Moves the joystick towards the given world position.
func _move_towards(world_position: Vector2) -> void:
	var direction:Vector2 = _start_pos.direction_to(world_position)
	var distance:float = _start_pos.distance_to(world_position)
	_current_pos = _start_pos + direction * min(distance, max_actuation_radius)
	_report_input()

## Releases the joystick.
func _release() -> void:
	_is_actuated = false
	# return to initial position
	global_position = _initial_pos
	
	_start_pos = global_position
	_current_pos = global_position
	_report_input()

## Reports the current input state to the input system.
func _report_input() -> void:
	var direction := Vector2.ZERO
	if not _start_pos.is_equal_approx(_current_pos):
		direction = _start_pos.direction_to(_current_pos)

	var distance: float = _start_pos.distance_to(_current_pos)
	var offset:Vector2 = direction * (distance / max_actuation_radius)

	match stick_position:
		StickPosition.LEFT:
			_send_event(JOY_AXIS_LEFT_X, offset.x)
			_send_event(JOY_AXIS_LEFT_Y, offset.y)
		StickPosition.RIGHT:
			_send_event(JOY_AXIS_RIGHT_X, offset.x)
			_send_event(JOY_AXIS_RIGHT_Y, offset.y)
	if draw_debug:
		queue_redraw()
	
	changed.emit()
	
## Helper function to send input events to the input system.
func _send_event(axis:int, value:float):
	var event := InputEventJoypadMotion.new()	
	event.axis = axis
	event.axis_value = value
	event.device = _virtual_joy_id
	GUIDE.inject_input(event)
	

## Draws the virtual stick and its interaction zone.
func _draw() -> void:
	if not draw_debug:
		return
	
	draw_circle(Vector2.ZERO, interaction_zone_radius, Color(0.5, 0.5, 1.0, 0.5))
	draw_circle(Vector2.ZERO, max_actuation_radius, Color(0.9, 0.2, 0.2, 0.5))	
	draw_circle(Vector2.ZERO, stick_radius, Color(0.9, 0.9, 0.3, 0.5))

	if _is_actuated:
		draw_circle(stick_relative_position, stick_radius, Color(0.9, 0.9, 0.7, 0.5))
		
func _get_configuration_warnings() -> PackedStringArray:
	var result:PackedStringArray = []
	if get_parent() is Container:
		result.append("Virtual sticks must be top level elements. They cannot be a child of a container.")
	return result
