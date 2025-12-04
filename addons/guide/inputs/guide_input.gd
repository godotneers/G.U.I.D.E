@tool
@icon("res://addons/guide/inputs/guide_input.svg")
## A class representing some actuated input.
class_name GUIDEInput
extends Resource

enum DeviceType {
	## The input originates from no device (e.g. virtual inputs).
	NONE = 0,
	## The input originates from a keyboard.
	KEYBOARD = 1,
	## The input originates from a mouse.
	MOUSE = 2,
	## The input originates from a joystick / gamepad.
	JOY = 4,
	## The input originates from a touch device.
	TOUCH = 8,
}

## The type of device from which this input originates. Note that this can
## also be a combination of devices (e.g. for the any input).
var device_type:DeviceType:
	get: return _device_type()

## The current valueo f this input. Depending on the input type only parts of the 
## returned vector may be relevant.
var _value:Vector3 = Vector3.ZERO

## The current input state. This will be set by GUIDE when the input is used.
var _state:GUIDEInputState = null

## Whether this input needs a reset per frame. _input is only called when
## there is input happening, but some GUIDE inputs may need to be reset
## in the absence of input.
func _needs_reset() -> bool:
	return false
	
## Resets the input value to the default value. Is called once per frame if
## _needs_reset returns true.
func _reset() -> void:
	_value = Vector3.ZERO

## Returns whether this input is the same input as the other input.
func is_same_as(other:GUIDEInput) -> bool:
	return false
	
## Called when the input is started to be used by GUIDE. Can be used to perform
## initializations. The state object can be used to subscribe to input events
## and to get the current input state.
func _begin_usage() -> void :
	pass
	
## Called, when the input is no longer used by GUIDE. Can be used to perform
## cleanup.
func _end_usage() -> void:
	pass
	
## The name of this input as it should be shown in the editor.	
func _editor_name() -> String:
	return ""
	
## The description of this input as it should be shown in the editor.	
func _editor_description() -> String:
	return ""
	
## The native value type of this input (e.g. which kind of value will the 
## input produce).
func _native_value_type() -> GUIDEAction.GUIDEActionValueType:
	return -1

## The device type from which this input originates.
func _device_type() -> DeviceType:
	return DeviceType.NONE
