## Base class for generic touch input
@tool
class_name GUIDEInputTouchBase
extends GUIDEInput

## The number of fingers to be tracked.
@export_range(1, 5, 1, "or_greater") var finger_count:int = 1:
	set(value):
		if value < 1:
			value = 1
		finger_count = value
		emit_changed()

## The index of the finger for which the position/delta should be reported 
## (0 = first finger, 1 = second finger, etc.). If -1, reports the average position/delta for 
## all fingers currently touching.
@export_range(-1, 4, 1, "or_greater") var finger_index:int = 0:
	set(value):
		if value < -1:
			value = -1
		finger_index = value
		emit_changed()


func _device_type() -> DeviceType:
	return DeviceType.TOUCH
