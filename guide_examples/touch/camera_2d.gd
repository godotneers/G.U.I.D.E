## Camera control. We listen to GUIDE's actions to move and zoom the camera. Note how we can
## mix event-based and polling based input handling, depending on what works better for the 
## use case.
extends Camera2D


@export var camera_movement:GUIDEAction
@export var camera_zoom:GUIDEAction
@export var camera_rotation:GUIDEAction
@export var camera_reset:GUIDEAction


@onready var _reference_zoom:Vector2 = zoom
@onready var _reference_rotation:float = rotation

func _ready() -> void:
	camera_zoom.triggered.connect(_zoom_camera)
	camera_rotation.triggered.connect(_rotate_camera)
	camera_reset.triggered.connect(_reset_camera)
	# whenever zooming completes, we store the new reference zoom
	camera_zoom.completed.connect(func() -> void: _reference_zoom = zoom)
	# whenever rotation completes, we store the new reference rotation
	camera_rotation.completed.connect(func() -> void: _reference_rotation = rotation)
	
	

func _process(_delta:float) -> void:
	position += camera_movement.value_axis_2d

	
func _zoom_camera() -> void:
	zoom = clamp( _reference_zoom * camera_zoom.value_axis_1d, Vector2(0.1, 0.1), Vector2(3, 3))

func _rotate_camera() -> void:
	rotation = fmod(_reference_rotation + camera_rotation.value_axis_1d, TAU)


func _reset_camera() -> void:
	zoom = Vector2.ONE
	rotation = 0
	_reference_zoom = zoom
	_reference_rotation = rotation
