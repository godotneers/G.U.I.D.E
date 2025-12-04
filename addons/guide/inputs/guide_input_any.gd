## Input that triggers if any input from the given device class
## is given.
@tool
class_name GUIDEInputAny
extends GUIDEInput


## Should input from mouse buttons be considered? Deprecated, use
## mouse_buttons instead.
## @deprecated 
var mouse:bool:
	get: return mouse_buttons
	set(value): mouse_buttons = value

## Should input from joy buttons be considered. Deprecated, use
## joy_buttons instead.
## @deprecated
var joy:bool:
	get: return joy_buttons
	set(value): joy_buttons = value

## Should input from mouse buttons be considered?
@export var mouse_buttons:bool = false
		
## Should input from mouse movement be considered?
@export var mouse_movement:bool = false

## Minimum movement distance of the mouse before it is considered
## moving.
@export var minimum_mouse_movement_distance:float = 1.0

## Should input from gamepad/joystick buttons be considered?
@export var joy_buttons:bool = false

## Should input from gamepad/joystick axes be considered?
@export var joy_axes:bool = false 

## Minimum strength of a single joy axis actuation before it is considered
## as actuated.
@export var minimum_joy_axis_actuation_strength:float = 0.2

## Should input from the keyboard be considered?
@export var keyboard:bool = false

## Should input from touch be considered?
@export var touch:bool = false


func _needs_reset() -> bool:
	# Needs reset because we cannot detect the absence of input.
	return true

func _begin_usage() -> void:
	# subscribe to relevant input events
	if mouse_movement:
		_state.mouse_position_changed.connect(_refresh)
	if mouse_buttons:
		_state.mouse_button_state_changed.connect(_refresh)
	if keyboard:
		_state.keyboard_state_changed.connect(_refresh)
	if joy_buttons:
		_state.joy_button_state_changed.connect(_refresh)
	if joy_axes:
		_state.joy_axis_state_changed.connect(_refresh)
	if touch:
		_state.touch_state_changed.connect(_refresh)
		
	_refresh()
	
func _end_usage() -> void:
	# unsubscribe from input events
	if mouse_movement:
		_state.mouse_position_changed.disconnect(_refresh)
	if mouse_buttons:
		_state.mouse_button_state_changed.disconnect(_refresh)
	if keyboard:
		_state.keyboard_state_changed.disconnect(_refresh)
	if joy_buttons:
		_state.joy_button_state_changed.disconnect(_refresh)
	if joy_axes:
		_state.joy_axis_state_changed.disconnect(_refresh)
	if touch:
		_state.touch_state_changed.disconnect(_refresh)

func _refresh() -> void:
	# if the input was already actuated this frame, remain
	# actuated, even if more input events come in. Input will
	# reset at the end of the frame.
	if not _value.is_zero_approx():
		return
	
	if keyboard and _state.is_any_key_pressed():		
		_value = Vector3.RIGHT
		return

	if mouse_buttons and _state.is_any_mouse_button_pressed():
		_value = Vector3.RIGHT
		return
	
	if mouse_movement and _state.get_mouse_delta_since_last_frame().length() >= minimum_mouse_movement_distance:
		_value = Vector3.RIGHT
		return
		
	if joy_buttons and _state.is_any_joy_button_pressed():
		_value = Vector3.RIGHT
		return

	if joy_axes and _state.is_any_joy_axis_actuated(minimum_joy_axis_actuation_strength):
		_value = Vector3.RIGHT
		return
		
	if touch and _state.is_any_finger_down():
		_value = Vector3.RIGHT
		return
		
	_value = Vector3.ZERO		


func is_same_as(other:GUIDEInput) -> bool:
	return other is GUIDEInputAny and \
		mouse_buttons == other.mouse_buttons and \
		mouse_movement == other.mouse_movement and \
		joy_buttons == other.joy_buttons and \
		joy_axes == other.joy_axes and \
		keyboard == other.keyboard and \
		touch == other.touch and \
		is_equal_approx(minimum_mouse_movement_distance, other.minimum_mouse_movement_distance) and \
		is_equal_approx(minimum_joy_axis_actuation_strength, other.minimum_joy_axis_actuation_strength)

func _editor_name() -> String:
	return "Any Input"
	
	
func _editor_description() -> String:
	return "Input that triggers if any input from the given device class is given."
	
	
func _native_value_type() -> GUIDEAction.GUIDEActionValueType:
	return GUIDEAction.GUIDEActionValueType.BOOL

# support for legacy properties
func _get_property_list() -> Array[Dictionary]:
	return [
		{
			"name": "mouse",
			"type": TYPE_BOOL,
			"usage": PROPERTY_USAGE_NO_EDITOR
		},
		{
			"name": "joy",
			"type": TYPE_BOOL,
			"usage": PROPERTY_USAGE_NO_EDITOR
		}
	]
	
func _device_type() -> DeviceType:
	var result:DeviceType = DeviceType.NONE
	if joy_axes or joy_buttons:
		result |= DeviceType.JOY
	if mouse_buttons or mouse_movement:
		result |= DeviceType.MOUSE
	if keyboard:
		result |= DeviceType.KEYBOARD
	if touch:
		result |= DeviceType.TOUCH
		
	return result
