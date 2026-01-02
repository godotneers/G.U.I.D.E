@tool
@icon("res://addons/guide/guide_action.svg")
class_name GUIDEAction
extends Resource

enum GUIDEActionValueType {
	BOOL = 0,
	AXIS_1D = 1,
	AXIS_2D = 2,
	AXIS_3D = 3
}

enum GUIDEActionState {
	TRIGGERED,
	ONGOING,
	COMPLETED
}

## The name of this action. Required when this action should be used as
## Godot action. Also displayed in the debugger.
@export var name:StringName:
	set(value):
		if name == value:
			return
		name = value
		emit_changed()
	

## The action value type.
@export var action_value_type: GUIDEActionValueType = GUIDEActionValueType.BOOL:
	set(value):
		if action_value_type == value:
			return
		action_value_type = value
		emit_changed()
		
## If this action triggers, lower-priority actions cannot trigger 
## if they share input with this action unless these actions are
## chorded with this action.		
@export var block_lower_priority_actions:bool = true:
	set(value):
		if block_lower_priority_actions == value:
			return
		block_lower_priority_actions = value
		emit_changed()	


@export_category("Godot Actions")
## If true, then this action will be emitted into Godot's 
## built-in action system. This can be helpful to interact with
## code using this system, like Godot's UI system. Actions
## will be emitted on trigger and completion (e.g. button down
## and button up).
@export var emit_as_godot_actions:bool = false:
	set(value):
		if emit_as_godot_actions == value:
			return
		emit_as_godot_actions = value
		emit_changed()
		
		
@export_category("Action Remapping")

## If true, players can remap this action. To be remappable, make sure
## that a name and the action type are properly set.
@export var is_remappable:bool:
	set(value):
		if is_remappable == value:
			return
		is_remappable = value
		emit_changed()
		
## The display name of the action shown to the player.
@export var display_name:String:
	set(value):
		if display_name == value:
			return
		display_name = value
		emit_changed()

## The display category of the action shown to the player.
@export var display_category:String:
	set(value):
		if display_category == value:
			return
		display_category = value
		emit_changed()
		
## Emitted every frame while the action is triggered.
signal triggered()

## Emitted the first frame that the action is triggered.
signal just_triggered()

## Emitted when the action started evaluating.
signal started()

## Emitted every frame while the action is still evaluating.
signal ongoing()

## Emitted when the action finished evaluating.
signal completed()

## Emitted when the action was cancelled.
signal cancelled()

var _last_state:GUIDEActionState = GUIDEActionState.COMPLETED

var _value_bool:bool
## Returns the value of this action as bool.
var value_bool:bool:
	get: return _value_bool

## Returns the value of this action as float.
var value_axis_1d:float:
	get: return _value.x
		
var _value_axis_2d:Vector2 = Vector2.ZERO
## Returns the value of this action as Vector2.
var value_axis_2d:Vector2:
	get: return _value_axis_2d

var _value:Vector3 = Vector3.ZERO
## Returns the value of this action as Vector3.
var value_axis_3d:Vector3:
	get: return _value
	

var _elapsed_seconds:float
## The amount of seconds elapsed since the action started evaluating.
var elapsed_seconds:float:
	get: return _elapsed_seconds

var _elapsed_ratio:float
## The ratio of the elapsed time to the hold time. This is a percentage
## of the hold time that has passed. If the action has no hold time, this will
## be 0 when the action is not triggered and 1 when the action is triggered.
## Otherwise, this will be a value between 0 and 1.
var elapsed_ratio:float:
	get: return _elapsed_ratio

var _triggered_seconds:float
## The amount of seconds elapsed since the action triggered.
var triggered_seconds:float:
	get: return _triggered_seconds


## This is a hint for how long the input must remain actuated (in seconds) before the action triggers.
## It depends on the mapping in which this action is used. If the mapping has no hold trigger it will be -1.
## In general, you should not access this variable directly, but rather the `elapsed_ratio` property of the action
## which is a percentage of the hold time that has passed.
var _trigger_hold_threshold:float = -1.0

func _triggered(value:Vector3, delta:float) -> void:
	_triggered_seconds += delta
	_elapsed_ratio = 1.0
	_update_value(value)
	if _last_state != GUIDEActionState.TRIGGERED:
		just_triggered.emit()
	_last_state = GUIDEActionState.TRIGGERED
	triggered.emit()
	_emit_godot_action_maybe(true)
		
func _started(value:Vector3) -> void:
	_elapsed_ratio = 0.0
	_update_value(value)
	_last_state = GUIDEActionState.ONGOING
	started.emit()
	ongoing.emit()

func _ongoing(value:Vector3, delta:float) -> void:
	_elapsed_seconds += delta
	if _trigger_hold_threshold > 0:
		_elapsed_ratio = _elapsed_seconds / _trigger_hold_threshold
	_update_value(value)
	var was_triggered:bool = _last_state == GUIDEActionState.TRIGGERED
	_last_state = GUIDEActionState.ONGOING
	ongoing.emit()
	# if the action reverts from triggered to ongoing, this counts as 
	# releasing the action for the godot action system.
	if was_triggered:
		_emit_godot_action_maybe(false)
	

func _cancelled(value:Vector3) -> void:
	_elapsed_seconds = 0
	_elapsed_ratio = 0
	_update_value(value)
	_last_state = GUIDEActionState.COMPLETED
	cancelled.emit()
	completed.emit()

func _completed(value:Vector3) -> void:
	_elapsed_seconds = 0
	_elapsed_ratio = 0
	_triggered_seconds = 0
	_update_value(value)
	_last_state = GUIDEActionState.COMPLETED
	completed.emit()
	_emit_godot_action_maybe(false)
		
func _emit_godot_action_maybe(pressed:bool) -> void:
	if not emit_as_godot_actions:
		return
		
	if name.is_empty():
		push_error("Cannot emit action into Godot's system because name is empty.")
		return
		
	var godot_action := InputEventAction.new()
	godot_action.action = name
	godot_action.strength = _value.x
	godot_action.pressed = pressed
	Input.parse_input_event(godot_action)

func _update_value(value:Vector3):
	match action_value_type:
		GUIDEActionValueType.BOOL, GUIDEActionValueType.AXIS_1D:
			_value_bool = abs(value.x) > 0
			_value_axis_2d = Vector2(abs(value.x), 0)
			_value = Vector3(value.x, 0, 0)
		GUIDEActionValueType.AXIS_2D:
			_value_bool = abs(value.x) > 0
			_value_axis_2d = Vector2(value.x, value.y)
			_value = Vector3(value.x, value.y, 0)
		GUIDEActionValueType.AXIS_3D:
			_value_bool = abs(value.x) > 0
			_value_axis_2d = Vector2(value.x, value.y)
			_value = value

## Returns whether the action is currently triggered. Can be used for a 
## polling style input.
func is_triggered() -> bool:
	return _last_state == GUIDEActionState.TRIGGERED

	
## Returns whether the action is currently completed. Can be used for a 
## polling style input.
func is_completed() -> bool:
	return _last_state == GUIDEActionState.COMPLETED


## Returns whether the action is currently completed. Can be used for a 
## polling style input.
func is_ongoing() -> bool:
	return _last_state == GUIDEActionState.ONGOING


func _editor_name() -> String:
	# Try to give the most user friendly name
	if display_name != "":
		return display_name
		
	if name != "":
		return name
		
	return resource_path.get_file().replace(".tres", "")


