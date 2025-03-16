## Helper class which holds virtual joy state.
@tool
class_name GUIDEInternalVirtualJoyRelay


signal joy_axis_changed(joy_index:int, axis:int, value:float)
signal joy_button_changed(joy_index:int, button:int, value:bool)

static var Instance:GUIDEInternalVirtualJoyRelay = GUIDEInternalVirtualJoyRelay.new():
	set(value):
		pass

static func submit_axis_change(joy_index:int, axis:int, value:float) -> void:
	Instance.joy_axis_changed.emit(joy_index, axis, value)
	
static func submit_button_change(joy_index:int, button:int, value:bool) -> void:
	Instance.joy_button_changed.emit(joy_index, button, value)
	
	
