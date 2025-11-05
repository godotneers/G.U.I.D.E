extends CharacterBody2D

signal exited()
@export var speed:float = 300
@export var turn_speed_degrees:float = 180

@export var context:GUIDEMappingContext
@export var accelerate:GUIDEAction
@export var turn:GUIDEAction
@export var leave:GUIDEAction


@onready var _player_spot:Node2D = %PlayerSpot
@onready var _exit_spot:Node2D = %ExitSpot

var _player:Node2D

func _ready() -> void:
	leave.triggered.connect(_on_leave)


func _physics_process(delta:float) -> void:
	# rotate by our turn axis
	rotate(turn.value_axis_1d * deg_to_rad(turn_speed_degrees) * delta)
	# accelerate by our acceleration axis
	velocity = transform.x * accelerate.value_axis_1d * speed
	move_and_slide()
	

func enter(player:Node2D) -> void:
	# Move the player to the player spot
	_player = player
	player.reparent(_player_spot, false)
	_player.position = Vector2.ZERO
	
	# And enable the boat controls
	GUIDE.enable_mapping_context(context)
	

func _on_leave() -> void:
	# Disable boat controls
	GUIDE.disable_mapping_context(context)
	
	# put player back in the world
	_player.reparent(get_parent(), false)
	_player.global_position = _exit_spot.global_position
	
	# this is to prevent the physics engine from going crazy when moving
	# the player's body
	await get_tree().physics_frame
	
	# notify any interested parties that the player has exited
	exited.emit()
	
	

	
	
