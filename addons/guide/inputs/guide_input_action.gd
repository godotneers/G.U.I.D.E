## An input that mirrors the action's value while the action is triggered.
@tool
class_name GUIDEInputAction
extends GUIDEInput

## The action that this input should mirror. This is live tracked, so any change in
## the action will update the input.
@export var action:GUIDEAction:
	set(value):
		if value == action:
			return
		action = value
		emit_changed()	

func _begin_usage() -> void:
	if is_instance_valid(action):
		action.triggered.connect(_on)
		action.completed.connect(_off)
		action.ongoing.connect(_off)
		if action.is_triggered():
			_on()
			return
	# not triggered or no action.
	_off()
	
	
func _end_usage() -> void:
	if is_instance_valid(action):
		action.triggered.disconnect(_on)
		action.completed.disconnect(_off)
		action.ongoing.disconnect(_off)


func _on() -> void:
	# on is only called when the action is actually existing, so this is
	# always not-null here
	_value = action.value_axis_3d
	
func _off() -> void:
	_value = Vector3.ZERO	
	
	
func is_same_as(other:GUIDEInput) -> bool:
	return other is GUIDEInputAction and other.action == action


func _to_string() -> String:
	return "(GUIDEInputAction: " + str(action) + ")"

func _editor_name() -> String:
	return "Action"
	
	
func _editor_description() -> String:
	return "An input that mirrors the action's value while the action is triggered."
	

func _native_value_type() -> GUIDEAction.GUIDEActionValueType:
	return GUIDEAction.GUIDEActionValueType.AXIS_3D
