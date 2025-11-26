@tool
class_name GUIDEKeyRenderer
extends GUIDEIconRenderer

@onready var _label:Label = %Label
@onready var _nine_patch_rect: NinePatchRect = %NinePatchRect

static var _style:GUIDEKeyRenderStyle = preload("styles/default.tres")

## Sets the style to be used by this renderer.
static func set_style(style:GUIDEKeyRenderStyle) -> void:
	if not is_instance_valid(style):
		push_error("Key style must not be null.")
		return
	_style = style

func supports(input:GUIDEInput, options:GUIDEInputFormattingOptions) -> bool:
	return input is GUIDEInputKey
	
func render(input:GUIDEInput, options:GUIDEInputFormattingOptions) -> void:
	var key:Key = input.key
	
	_nine_patch_rect.texture = _style.keycaps
	_nine_patch_rect.region_rect = _style.region_rect
	_nine_patch_rect.patch_margin_left = _style.patch_margin_left
	_nine_patch_rect.patch_margin_top = _style.patch_margin_top
	_nine_patch_rect.patch_margin_right = _style.patch_margin_right
	_nine_patch_rect.patch_margin_bottom = _style.patch_margin_bottom
	
	var label_key:Key = DisplayServer.keyboard_get_label_from_physical(key)
	_label.text = OS.get_keycode_string(label_key).strip_edges()
	_label.add_theme_color_override("font_color", _style.font_color)
	_label.add_theme_font_override("font", _style.font)
	_label.add_theme_font_size_override("font_size", _style.font_size)
	size = Vector2.ZERO
	
	
	call("queue_sort")
 
func cache_key(input:GUIDEInput, options:GUIDEInputFormattingOptions) -> String:
	# Output depends on the input and the style
	return "ed6923d5-4115-44bd-b35e-2c4102ffc83e" \
		+ input.to_string() \
		+ _style.resource_path
