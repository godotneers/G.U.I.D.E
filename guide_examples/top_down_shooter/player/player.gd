extends CharacterBody2D


@export var speed:float = 300
@export var look_relative:GUIDEAction
@export var look_absolute:GUIDEAction
@export var move:GUIDEAction
@export var fire:GUIDEAction

@export var bolt:PackedScene

@onready var left_hand:Node2D = %LeftHand
@onready var right_hand:Node2D = %RightHand


func _ready() -> void:
	# fire some bolts when the fire action triggers
	fire.triggered.connect(_fire)

func _physics_process(delta:float) -> void:
	var target := Vector2.INF
	
	# Looking at absolute coordinates. This is the case when we use a mouse.
	if look_absolute.is_triggered():
		target = look_absolute.value_axis_2d
	# Looking at relative coordinates. This is the case when we use a controller	
	elif look_relative.is_triggered():
		target = global_position + look_relative.value_axis_2d
	
	# If we have a target, rotate towards it
	if target.is_finite():
		var target_orientation := Transform2D()\
			.translated(transform.origin)\
			.looking_at(target)
		transform = transform.interpolate_with(target_orientation, 5 * delta)

	# and move according to the input. 
	velocity = speed * move.value_axis_2d
	move_and_slide() 

func _fire() -> void:
	# for each hand of the player, spawn a bolt
	for hand:Node2D in [left_hand, right_hand]:
		var a_bolt:Node2D = bolt.instantiate()
		get_parent().add_child(a_bolt)
		a_bolt.global_transform = hand.global_transform
