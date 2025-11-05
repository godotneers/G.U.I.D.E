extends CharacterBody2D

@export var context:GUIDEMappingContext
@export var move:GUIDEAction
@export var use:GUIDEAction

@export var speed:float = 300

@onready var _detection_area:Area2D = %DetectionArea
@onready var _collision_shape:CollisionShape2D = %CollisionShape

func _ready() -> void:
	use.triggered.connect(_enter_boat)
	
func _physics_process(_delta:float) -> void:
	velocity = move.value_axis_2d.normalized() * speed
	move_and_slide()	
	
	
func _enter_boat() -> void:
	var boats := _detection_area.get_overlapping_bodies()
	if boats.is_empty():
		return
	
	# Disable player input while in the boat
	GUIDE.disable_mapping_context(context)	
	
	# disable our own collisions while in the boat
	_collision_shape.set_deferred("disabled", true)
	
	# enter the boat
	boats[0].enter(self)
	boats[0].exited.connect(_boat_exited, CONNECT_ONE_SHOT)	


func _boat_exited() -> void:
	# re-enable our own mapping context
	GUIDE.enable_mapping_context(context)
	
	# and re-enable our collisions
	_collision_shape.set_deferred("disabled", false)
	
