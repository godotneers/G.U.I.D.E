@tool
class_name GUIDEMouseRenderer
extends GUIDEIconRenderer

@onready var _controls:Control = %Controls
@onready var _mouse_left:TextureRect = %MouseLeft
@onready var _mouse_right:TextureRect = %MouseRight
@onready var _mouse_middle:TextureRect = %MouseMiddle
@onready var _mouse_side_a:TextureRect = %MouseSideA
@onready var _mouse_side_b:TextureRect = %MouseSideB
@onready var _mouse_blank:TextureRect = %MouseBlank
@onready var _mouse_cursor:TextureRect = %MouseCursor


@onready var _directions:Control = %Directions
@onready var _left:TextureRect = %Left
@onready var _right:TextureRect = %Right
@onready var _up:TextureRect = %Up
@onready var _down:TextureRect = %Down
@onready var _horizontal:TextureRect = %Horizontal
@onready var _vertical:TextureRect = %Vertical

static var _style:GUIDEMouseRenderStyle = preload("styles/default.tres")

static func set_style(style:GUIDEMouseRenderStyle) -> void:
	if not is_instance_valid(style):
		push_error("Mouse style must not be null.")
		return
	_style = style
	


func supports(input:GUIDEInput, options:GUIDEInputFormattingOptions) -> bool:
	return input is GUIDEInputMouseButton or \
		input is GUIDEInputMouseAxis1D or \
		input is GUIDEInputMouseAxis2D or \
		input is GUIDEInputMousePosition
	
	
func render(input:GUIDEInput, options:GUIDEInputFormattingOptions) -> void:
	for child in _controls.get_children():
		child.visible = false
	for child in _directions.get_children():
		child.visible = false
		
	_directions.visible = false
	
	_mouse_blank.texture = _style.mouse_blank
	_mouse_left.texture = _style.mouse_left
	_mouse_right.texture = _style.mouse_right
	_mouse_middle.texture = _style.mouse_middle
	_mouse_side_a.texture = _style.mouse_side_a
	_mouse_side_b.texture = _style.mouse_side_b
	_mouse_cursor.texture = _style.mouse_cursor
	
	_left.texture = _style.left
	_right.texture = _style.right
	_up.texture = _style.up
	_down.texture = _style.down
	_horizontal.texture = _style.horizontal
	_vertical.texture = _style.vertical	
		
	if input is GUIDEInputMouseButton:
		match input.button:
			MOUSE_BUTTON_LEFT:
				_mouse_left.visible = true
			MOUSE_BUTTON_RIGHT:
				_mouse_right.visible = true
			MOUSE_BUTTON_MIDDLE:
				_mouse_middle.visible = true
			MOUSE_BUTTON_WHEEL_UP:
				_directions.visible = true
				_up.visible = true
				_mouse_middle.visible = true
			MOUSE_BUTTON_WHEEL_DOWN:
				_directions.visible = true
				_down.visible = true
				_mouse_middle.visible = true
			MOUSE_BUTTON_WHEEL_LEFT:
				_directions.visible = true
				_left.visible = true
				_mouse_middle.visible = true
			MOUSE_BUTTON_WHEEL_RIGHT:
				_directions.visible = true
				_right.visible = true
				_mouse_middle.visible = true
			MOUSE_BUTTON_XBUTTON1:
				_mouse_side_a.visible = true
			MOUSE_BUTTON_XBUTTON2:
				_mouse_side_b.visible = true
				
	if input is GUIDEInputMouseAxis1D:
		if input.axis == GUIDEInputMouseAxis1D.GUIDEInputMouseAxis.X:
			_mouse_blank.visible = true
			_directions.visible = true
			_horizontal.visible = true
		else:
			_mouse_blank.visible = true
			_directions.visible = true
			_vertical.visible = true		
		
	if input is GUIDEInputMouseAxis2D:
		_mouse_blank.visible = true
		
	if input is GUIDEInputMousePosition:
		_mouse_cursor.visible = true
	
	call("queue_sort")
 
func cache_key(input:GUIDEInput, options:GUIDEInputFormattingOptions) -> String:
	# output depends on input and style
	return "7e27520a-b6d8-4451-858d-e94330c82e85" \
		+ input.to_string() \
		+ _style.resource_path
