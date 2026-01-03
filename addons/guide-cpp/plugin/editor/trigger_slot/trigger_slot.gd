@tool
extends "../resource_slot/resource_slot.gd"

var trigger:GUIDETrigger:
	set(value):
		_value = value
	get:
		return _value

func _accepts_drop_data(data:Resource) -> bool:
	return data is GUIDETrigger

	
	
