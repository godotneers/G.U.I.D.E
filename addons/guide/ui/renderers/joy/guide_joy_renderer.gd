@tool
class_name GUIDEJoyRenderer
extends GUIDEIconRenderer

@onready var _stick:TextureRect = %Stick
@onready var _button:TextureRect = %Button
@onready var _text:Label = %Text
@onready var _directions:Control = %Directions
@onready var _horizontal:TextureRect = %Horizontal
@onready var _vertical:TextureRect = %Vertical


static var _style:GUIDEJoyRenderStyle = preload("styles/default.tres")

static func set_style(style:GUIDEJoyRenderStyle) -> void:
	if not is_instance_valid(style):
		push_error("Joy style must not be null.")
		return
	_style = style

func supports(input:GUIDEInput, options:GUIDEInputFormattingOptions) -> bool:
	return input is GUIDEInputJoyBase
	
func render(input:GUIDEInput, options:GUIDEInputFormattingOptions) -> void:
	_stick.texture = _style.stick
	_stick.visible = false
	
	_button.texture = _style.button
	_button.visible = false
	
	_directions.visible = false
	
	_horizontal.texture = _style.horizontal
	_horizontal.visible = false
	
	_vertical.texture = _style.vertical
	_vertical.visible = false	
	
	_text.text = ""
	_text.add_theme_color_override("font_color", _style.font_color)
	_text.add_theme_font_override("font", _style.font)
	_text.add_theme_font_size_override("font_size", _style.font_size)

		
	if input is GUIDEInputJoyAxis1D:
		_stick.visible = true
		match input.axis:
			JOY_AXIS_LEFT_X:
				_directions.visible = true
				_text.text = "1"
				_horizontal.visible = true
			JOY_AXIS_RIGHT_X:
				_directions.visible = true
				_text.text = "2"
				_horizontal.visible = true
			JOY_AXIS_LEFT_Y:
				_directions.visible = true
				_text.text = "1"
				_vertical.visible = true
			JOY_AXIS_RIGHT_Y:
				_directions.visible = true
				_text.text = "2"
				_vertical.visible = true
			JOY_AXIS_TRIGGER_LEFT:
				_text.text = "3"
			JOY_AXIS_TRIGGER_RIGHT:
				_text.text = "4"
								
	
	
	if input is GUIDEInputJoyAxis2D:
		_stick.visible = true
		match input.x:
			JOY_AXIS_LEFT_X, JOY_AXIS_LEFT_Y:
				_text.text = "1"
			JOY_AXIS_RIGHT_X, JOY_AXIS_RIGHT_Y:
				_text.text = "2"
			_:
				# well we don't know really what this is but what can we do.
				_text.text = str(input.x + input.y)
		
	if input is GUIDEInputJoyButton:
		_button.visible = true
		_text.text = str(input.button)
			
	call("queue_sort")
 
func cache_key(input:GUIDEInput, options:GUIDEInputFormattingOptions) -> String:
	# output depends on the input and the currently used style
	return "a9ced629-de65-4c31-9de0-8e4cbf88a2e0" \
		 + input.to_string() \
		 + _style.resource_path
