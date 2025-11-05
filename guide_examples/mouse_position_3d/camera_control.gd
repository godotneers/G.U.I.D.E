## GUIDE makes controlling a camera pretty easy. By using the 
## window-relative and scale modifiers we can translate mouse input 
## directly into a format suitable for rotation. GUIDE also takes
## care of only sending yaw and pitch input when the camera toggle 
## is pressed, so we don't need to have any complex input code in
## our camera control script.
extends Node3D

@export var camera_pitch:GUIDEAction
@export var camera_yaw:GUIDEAction
@export var camera_toggle:GUIDEAction
@export var camera_move:GUIDEAction

@export var movement_speed:float = 1
@onready var _camera_yaw:Node3D = %CameraYaw
@onready var _camera_pitch:SpringArm3D = %CameraPitch

func _ready() -> void:
	camera_toggle.triggered.connect(_hide_mouse)
	camera_toggle.completed.connect(_show_mouse)
	camera_yaw.triggered.connect(_yaw)
	camera_pitch.triggered.connect(_pitch)
	
func _hide_mouse() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
func _show_mouse() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _yaw() -> void:
	_camera_yaw.rotate_y(camera_yaw.value_axis_1d)

func _pitch() -> void:
	_camera_pitch.rotate_x(camera_pitch.value_axis_1d)	
	_camera_pitch.rotation_degrees.x = clamp(_camera_pitch.rotation_degrees.x, -75.0, 0.0)

		
func _process(delta:float) -> void:
	# we already used the input-swizzle modifier to get forward as -z, backward as z
	# left as -x and right as x, so we can use this immediately
	position += basis * camera_move.value_axis_3d * movement_speed * delta
	
