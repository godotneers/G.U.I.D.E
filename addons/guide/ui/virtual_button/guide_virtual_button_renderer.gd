@tool
## Base class for virtual button renderers.
class_name GUIDEVirtualButtonRenderer
extends Control

var _button: GUIDEVirtualButton = null
var _was_actuated:bool = false

## Returns whether or not the button is currently actuated.
var is_button_actuated:bool:
	get:
		if _button != null:
			return _button._is_actuated
		return false		
		
## Returns the button radius.
var button_radius:float:
	get:
		if _button != null:
			return _button.button_radius
		return 0.0

func _notification(what:int) -> void:
	if what == NOTIFICATION_ENTER_TREE:
		
		_button = get_parent() as GUIDEVirtualButton
		if _button == null:
			push_error("Button renderer must be a child of GUIDEVirtualButton. Button renderer will not work.")
			return
		_button.configuration_changed.connect(_on_configuration_changed)
		if Engine.is_editor_hint():
			return
		# we only react to input changes in the real game, not in the editor.
		_button.changed.connect(func(): _update(_button._is_actuated))

## Called when configuration changed on the parent button.
func _on_configuration_changed() -> void:
	pass
	
## Function to be implemented by subclasses to update the button visuals.
## @param is_actuated: Whether or not the button is currently actuated.
func _update(is_actuated:bool) -> void:
	pass


func _get_configuration_warnings() -> PackedStringArray:
	var results: PackedStringArray = []

	if (get_parent() as GUIDEVirtualButton) == null:
		results.append("Button renderer must be a child of GUIDEVirtualButton")

	return results

