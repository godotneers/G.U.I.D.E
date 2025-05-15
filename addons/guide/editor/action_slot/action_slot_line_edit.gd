@tool
extends LineEdit

signal action_dropped(action:GUIDEAction)


func _can_drop_data(at_position, data) -> bool:
	if not data is Dictionary:
		return false
		
	if data.has("files"):
		for file in data["files"]:
			if ResourceLoader.load(file) is GUIDEAction:
				return true
		
	return false	
	
	
func _drop_data(at_position, data) -> void:
	for file in data["files"]:
		var item = ResourceLoader.load(file) 
		if item is GUIDEAction:
			action_dropped.emit(item)

