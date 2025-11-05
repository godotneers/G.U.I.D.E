@tool
extends Button

var _parent_array:Variant
var _index:int

func _get_drag_data(at_position) -> Variant:
	return { "parent_array" : _parent_array, "index" : _index }
