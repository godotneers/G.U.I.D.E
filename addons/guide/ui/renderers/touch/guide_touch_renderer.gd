@tool
class_name GUIDETouchRenderer
extends GUIDEIconRenderer

@onready var _controls:Control = %Controls
@onready var _1_finger:TextureRect = %T1Finger
@onready var _2_finger:TextureRect = %T2Fingers
@onready var _3_finger:TextureRect = %T3Fingers
@onready var _4_finger:TextureRect = %T4Fingers
@onready var _rotate:TextureRect = %Rotate
@onready var _zoom:TextureRect = %Zoom


@onready var _directions:Control = %Directions
@onready var _horizontal:TextureRect = %Horizontal
@onready var _vertical:TextureRect = %Vertical
@onready var _axis2d:TextureRect = %Axis2D


static var _style:GUIDETouchRenderStyle = preload("styles/default.tres")

## Sets the style to be used by this renderer.
static func set_style(style:GUIDETouchRenderStyle) -> void:
	if not is_instance_valid(style):
		push_error("Touch style must not be null.")
		return
	_style = style
	

func supports(input:GUIDEInput, options:GUIDEInputFormattingOptions) -> bool:
	return input is GUIDEInputTouchAxis1D or \
		input is GUIDEInputTouchAxis2D or \
		input is GUIDEInputTouchPosition or \
		input is GUIDEInputTouchAngle or \
		input is GUIDEInputTouchDistance
		
	
	
func render(input:GUIDEInput, options:GUIDEInputFormattingOptions) -> void:
	for child in _controls.get_children():
		child.visible = false
	for child in _directions.get_children():
		child.visible = false
		
	_directions.visible = false
	
	_1_finger.texture = _style.one_finger
	_2_finger.texture = _style.two_fingers
	_3_finger.texture = _style.three_fingers
	_4_finger.texture = _style.four_fingers
	_rotate.texture = _style.rotate
	_zoom.texture = _style.zoom
	_horizontal.texture = _style.horizontal
	_vertical.texture = _style.vertical
	_axis2d.texture = _style.both
		
	if input is GUIDEInputTouchBase:
		match input.finger_count:
			2:
				_2_finger.visible = true
			3:
				_3_finger.visible = true
			4:
				_4_finger.visible = true
			_:
				# we have no icons for more than 4 fingers, so everything else gets
				# the 1 finger icon
				_1_finger.visible = true	
		
	if input is GUIDEInputTouchAxis2D:
		_directions.visible = true
		_axis2d.visible = true
		
	if input is GUIDEInputTouchAxis1D:
		_directions.visible = true
		match input.axis:
			GUIDEInputTouchAxis1D.GUIDEInputTouchAxis.X:
				_horizontal.visible = true
			GUIDEInputTouchAxis1D.GUIDEInputTouchAxis.X:
				_vertical.visible = true
				
	if input is GUIDEInputTouchDistance:
		_zoom.visible = true
		
	if input is GUIDEInputTouchAngle:
		_rotate.visible = true
		
	call("queue_sort")
 
func cache_key(input:GUIDEInput, options:GUIDEInputFormattingOptions) -> String:
	# output depends on input and the style
	return "1f4c5082-d419-465f-aba8-f889caaff335" \
		+ input.to_string() \
		+ _style.resource_path
