## Camera control. We listen to GUIDE's actions to move and zoom the camera. Note how we can
## mix event-based and polling based input handling, depending on what works better for the 
## use case.
extends Camera2D


@export var camera_movement:GUIDEAction
@export var camera_zoom:GUIDEAction
@export var speed:float = 300


func _ready() -> void:
	camera_zoom.triggered.connect(_zoom_camera)

func _process(delta:float) -> void:
	position += camera_movement.value_axis_2d * speed * delta
	
func _zoom_camera() -> void:
	zoom = clamp( zoom + Vector2.ONE * camera_zoom.value_axis_1d, Vector2(0.1, 0.1), Vector2(3, 3))
