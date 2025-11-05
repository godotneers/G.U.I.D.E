@tool
class_name GUIDEInputMouseAxis1D
extends GUIDEInput

enum GUIDEInputMouseAxis {
	X,
	Y
}

@export var axis:GUIDEInputMouseAxis:
	set(value):
		if value == axis:
			return
		axis = value
		emit_changed()		

# we don't get mouse updates when the mouse is not moving, so this needs to be 
# reset every frame
func _needs_reset() -> bool:
	return true


func _begin_usage() -> void:
	# subscribe to mouse movement events
	_state.mouse_position_changed.connect(_refresh)
	_refresh()
	
func _end_usage() -> void:
	# unsubscribe from mouse movement events
	_state.mouse_position_changed.disconnect(_refresh)

func _refresh() -> void:
	var delta:Vector2 = _state.get_mouse_delta_since_last_frame()	
	match axis:
		GUIDEInputMouseAxis.X:
			_value.x = delta.x
		GUIDEInputMouseAxis.Y:
			_value.x = delta.y

		
func is_same_as(other:GUIDEInput) -> bool:
	return other is GUIDEInputMouseAxis1D and other.axis == axis

func _to_string() -> String:
	return "(GUIDEInputMouseAxis1D: axis=" + str(axis) + ")"


func _editor_name() -> String:
	return "Mouse Axis 1D"
	
	
func _editor_description() -> String:
	return "Relative mouse movement on a single axis."
	

func _native_value_type() -> GUIDEAction.GUIDEActionValueType:
	return GUIDEAction.GUIDEActionValueType.AXIS_1D
