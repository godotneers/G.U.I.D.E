extends CharacterBody3D

@export var movement_speed:float = 5
@export var bolt_scene:PackedScene

@export_category("Input")
@export var mapping_context:GUIDEMappingContext
@export var fire:GUIDEAction
@export var look:GUIDEAction
@export var move:GUIDEAction

@onready var pitch:Node3D = %Pitch
@onready var yaw:Node3D = self
@onready var right_hand:Node3D = %RightHand
@onready var left_hand:Node3D = %LeftHand

func _ready() -> void:
	# Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	GUIDE.enable_mapping_context(mapping_context)
	fire.triggered.connect(_fire)
	look.triggered.connect(_look)
	
func _fire() -> void:
	var spawn_points:Array[Node3D] = [left_hand, right_hand]
	for spawn_point:Node3D in spawn_points:
		var bolt:Node3D = bolt_scene.instantiate()
		get_parent().add_child(bolt)
		
		bolt.global_transform = spawn_point.global_transform


func _physics_process(delta:float) -> void:
	var movement_direction:Vector2 = move.value_axis_2d
	var movement_direction_3d:Vector3 = basis.x * movement_direction.x  - basis.z * movement_direction.y
	velocity = movement_direction_3d * movement_speed
	move_and_slide()
	
		
func _look() -> void:
	var camera_movement:Vector2 = look.value_axis_2d
	yaw.rotate_y(-camera_movement.x )
	pitch.rotate_x(-camera_movement.y )
		
	pitch.rotation_degrees.x = clamp(pitch.rotation_degrees.x, -90, 0)
