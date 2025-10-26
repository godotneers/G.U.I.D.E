@tool
## Base class for virtual stick renderers.
class_name GUIDEVirtualStickRenderer
extends Control


var _stick: GUIDEVirtualStick
var _was_actuated:bool = false

## Returns the stick radius from virtual stick.
var stick_radius: float:
	get:
		if _stick != null:
			return _stick.stick_radius
		return 0.0

## Returns the max actuation radius from the virtual stick.
var max_actuation_radius: float:
	get:
		if _stick != null:
			return _stick.max_actuation_radius
		return 0.0

## Returns the interaction zone radius from the virtual stick.
var interaction_zone_radius: float:
	get:
		if _stick != null:
			return _stick.interaction_zone_radius
		return 0.0
		
## Returns the position of the virtual stick relative to the center.	
var stick_position: Vector2:
	get:
		if _stick != null:
			return _stick.stick_relative_position
		return Vector2.ZERO

## Returns the starting position of the virtual stick in global coordinates.
var stick_start_position:Vector2:
	get:
		if _stick != null:
			return _stick._start_pos
		return Vector2.ZERO
			
		
## Returns whether or not the stick is currently actuated.
var is_stick_actuated:bool:
	get:
		if _stick != null:
			return _stick._is_actuated
		return false		
		

func _notification(what:int) -> void:
	if what == NOTIFICATION_ENTER_TREE:
		_stick = get_parent() as GUIDEVirtualStick
		if _stick == null:
			push_error("Stick renderer must be a child of GUIDEVirtualStick. Stick renderer will not work.")
			return
		_stick.configuration_changed.connect(_on_configuration_changed)

		if Engine.is_editor_hint():
			return
		# we only react to input changes in the real game, not in the editor.
		_stick.changed.connect(_on_stick_changed)

## Called when configuration changed on the parent stick (e.g., radii or modes changed).
func _on_configuration_changed() -> void:
	pass
	
func _on_stick_changed() -> void:
	var direction: Vector2 = Vector2.ZERO
	# get the stick direction (if the stick is not in the start position)
	if not _stick._start_pos.is_equal_approx(_stick._current_pos):
		direction = _stick._start_pos.direction_to(_stick._current_pos)
		
	# get the distance from the start position to the current position to 
	# calculate the offset (normalized by the max actuation radius)
	var distance: float = _stick._start_pos.distance_to(_stick._current_pos)
	var offset: Vector2 = direction * (distance / _stick.max_actuation_radius)
	
	# track actuation state changes
	if _stick._is_actuated and not _was_actuated:
		_was_actuated = true
		
	if not _stick._is_actuated and _was_actuated:
		_was_actuated = false
		
	# Update the visuals based on the new state.
	_update(_stick._current_pos - global_position, offset, _stick._is_actuated)
	
## Function to be implemented by subclasses to update the stick visuals.
## @param joy_position The position relative to the position of this renderer.
## @param joy_offset The normalized joy offset from the center of the stick, 
## taking into account the max actuation radius.
func _update(joy_position: Vector2, joy_offset:Vector2, is_actuated:bool) -> void:
	pass



func _get_configuration_warnings() -> PackedStringArray:
	var results: PackedStringArray = []

	if (get_parent() as GUIDEVirtualStick) == null:
		results.append("Stick renderer must be a child of GUIDEVirtualStick")

	return results

