extends CSGSphere3D

@export var cursor:GUIDEAction
@export var camera_toggle:GUIDEAction

func _process(_delta:float) -> void:
	var new_pos := cursor.value_axis_3d
	if not new_pos.is_finite() or camera_toggle.is_triggered():
		visible = false
		return
		
	visible = true
	global_position = new_pos
