## Base class for joystick inputs.
@tool
class_name GUIDEInputJoyBase
extends GUIDEInput

## The index of the connected joy pad to check. 
## -1 = Any connected joy pad
##  0 = First connected joy pad
##  1 = Second connected joy pad
##  2 = Third connected joy pad
##  3 = Fourth connected joy pad
## -2 = First virtual joy pad
## -3 = Second virtual joy pad
@export_enum("Any:-1","1:0","2:1","3:2","4:3","Virtual 1:-2","Virtual 2:-3", "Virtual 3:-4", "Virtual 4:-5") var joy_index:int = -1:
	set(value):
		if value == joy_index:
			return
		joy_index = value
		emit_changed()	

func _device_type() -> DeviceType:
	return DeviceType.JOY
