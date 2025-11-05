extends CharacterBody3D

@export var select:GUIDEAction
@export var cursor:GUIDEAction
@export var speed:float = 5.0

@onready var _navigation_agent_3d:NavigationAgent3D = %NavigationAgent3D

func _ready() -> void:
	select.triggered.connect(_new_destination)

func _physics_process(_delta:float) -> void:
	if not _navigation_agent_3d.is_navigation_finished():
		var next_pos := _navigation_agent_3d.get_next_path_position()
		velocity = global_position.direction_to(next_pos) * speed
	else:
		velocity = Vector3.ZERO
		
	if not is_on_floor():
		velocity.y =  -9.18
	
	move_and_slide()

func _new_destination() -> void:
	var destination := cursor.value_axis_3d
	if not destination.is_finite():
		return
	_navigation_agent_3d.target_position = destination
		
		
