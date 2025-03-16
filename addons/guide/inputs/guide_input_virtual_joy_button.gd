@tool
class_name GUIDEInputVirtualJoyButton
extends GUIDEInputVirtualJoyBase

@export var button:JoyButton = JOY_BUTTON_A:
	set(value):
		if value == button:
			return
		button = value
		emit_changed()		

func _begin_usage() -> void:
	GUIDEInternalVirtualJoyRelay.Instance.joy_button_changed.connect(_on_joy_button_changed)

	
func _end_usage() -> void:
	GUIDEInternalVirtualJoyRelay.Instance.joy_button_changed.disconnect(_on_joy_button_changed)
	
	
func _on_joy_button_changed(joy_index:int, button:int, value:bool) -> void:
	if self.joy_index > -1 and self.joy_index != joy_index:
		return
		
	if button != self.button:
		return
		
	_value.x = 1.0 if value else 0.0


func is_same_as(other:GUIDEInput) -> bool:
	return other is GUIDEInputVirtualJoyButton and \
		 other.button == button and \
		 other.joy_index == joy_index


func _to_string():
	return "(GUIDEInputVirtualJoyButton: button=" + str(button) + ", joy_index="  + str(joy_index) + ")"


func _editor_name() -> String:
	return "Virtual Joy Button"
	
func _editor_description() -> String:
	return "A button press from a virtual joy button."
	

func _native_value_type() -> GUIDEAction.GUIDEActionValueType:
	return GUIDEAction.GUIDEActionValueType.BOOL
