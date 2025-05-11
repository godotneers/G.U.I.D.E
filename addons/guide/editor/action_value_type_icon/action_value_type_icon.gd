@tool
class_name ActionValueTypeIcon
extends TextureRect

@export var default_icon: Texture = preload("res://addons/guide/editor/action_value_type_icon/action_value_type_bool.svg")

# Preload our SVGs as vector textures
var svg_textures: Dictionary = {
	GUIDEAction.GUIDEActionValueType.BOOL: preload("res://addons/guide/editor/action_value_type_icon/action_value_type_bool.svg"),
	GUIDEAction.GUIDEActionValueType.AXIS_1D: preload("res://addons/guide/editor/action_value_type_icon/action_value_type_float.svg"),
	GUIDEAction.GUIDEActionValueType.AXIS_2D: preload("res://addons/guide/editor/action_value_type_icon/action_value_type_vc2.svg"),
	GUIDEAction.GUIDEActionValueType.AXIS_3D: preload("res://addons/guide/editor/action_value_type_icon/action_value_type_vc3.svg"),
}

func _ready() -> void:
	set_texture(default_icon)

# Call this method with the appropriate key to switch icons
#
# Results in a NO-OP if there is not an icon related to the value type.
# Worst case if an action is somehow without a value action type it would render
# an empty rect.
func set_icon_for_value_type(value_type: GUIDEAction.GUIDEActionValueType) -> void:
	if svg_textures.has(value_type):
		set_texture(svg_textures[value_type])
