@tool
class_name GUIDEInputKey
extends GUIDEInput

## The physical keycode of the key.
@export var key:Key:
	set(value):
		if value == key:
			return
		key = value
		emit_changed()	
		

@export_group("Modifiers")
## Whether shift must be pressed.
@export var shift:bool = false:
	set(value):
		if value == shift:
			return
		shift = value
		emit_changed()	

## Whether control must be pressed.
@export var control:bool = false:
	set(value):
		if value == control:
			return
		control = value
		emit_changed()	
		
## Whether alt must be pressed.
@export var alt:bool = false:
	set(value):
		if value == alt:
			return
		alt = value
		emit_changed()		
	
		
## Whether meta/win/cmd must be pressed.
@export var meta:bool = false:
	set(value):
		if value == meta:
			return
		meta = value
		emit_changed()	

## Whether this input should fire if additional
## modifier keys are currently pressed.		
@export var allow_additional_modifiers:bool = true:
	set(value):
		if value == allow_additional_modifiers:
			return
		allow_additional_modifiers = value
		emit_changed()
					
## Helper array. All keys that must be pressed for this input to considered actuated.
var _must_be_pressed:Array[Key] = []
## Helper array. All keys that must not be pressed for this input to considered actuated.
var _must_not_be_pressed:Array[Key] = []

func _begin_usage() -> void:
	_must_be_pressed = [key]
	
	# also add the modifiers to the list of keys that must be pressed
	if shift:
		_must_be_pressed.append(KEY_SHIFT)
	if control:
		_must_be_pressed.append(KEY_CTRL)
	if alt:
		_must_be_pressed.append(KEY_ALT)
	if meta:
		_must_be_pressed.append(KEY_META)
		
	_must_not_be_pressed = []
	# now unless additional modifiers are allowed, add all modifiers
	# that are not required to the list of keys that must not be pressed
	# except if the bound key is actually the modifier itself
	if not allow_additional_modifiers:
		if not shift and key != KEY_SHIFT:
			_must_not_be_pressed.append(KEY_SHIFT)
		if not control and key != KEY_CTRL:
			_must_not_be_pressed.append(KEY_CTRL)
		if not alt and key != KEY_ALT:
			_must_not_be_pressed.append(KEY_ALT)
		if not meta and key != KEY_META:
			_must_not_be_pressed.append(KEY_META)
			
	# subscribe to input events
	_state.keyboard_state_changed.connect(_refresh)
	_refresh()
	
func _end_usage() -> void:
	# unsubscribe from input events
	_state.keyboard_state_changed.disconnect(_refresh)
	
	
func _refresh():
	# We are actuated if all keys that must be pressed are pressed and none of the keys that must not be pressed
	# are pressed. 
	var is_actuated:bool = _state.are_all_keys_pressed(_must_be_pressed) and not _state.is_at_least_one_key_pressed(_must_not_be_pressed)
	_value.x = 1.0 if is_actuated else 0.0
	

func is_same_as(other:GUIDEInput) -> bool:
	return other is GUIDEInputKey \
			and other.key == key \
			and other.shift == shift \
			and other.control == control \
			and other.alt == alt \
			and other.meta == meta \
			and other.allow_additional_modifiers == allow_additional_modifiers

func _to_string() -> String:
	return "(GUIDEInputKey: key=" + str(key) + ", shift="  + str(shift) + ", alt=" + str(alt) + ", control=" + str(control) + ", meta="+ str(meta) + ")"


func _editor_name() -> String:
	return "Key"
	
func _editor_description() -> String:
	return "A button press on the keyboard."
	

func _native_value_type() -> GUIDEAction.GUIDEActionValueType:
	return GUIDEAction.GUIDEActionValueType.BOOL

func _device_type() -> DeviceType:
	return DeviceType.KEYBOARD
