## This is a somewhat more complex player example. Note how all the combos
## are completely handled by GUIDE, the player doesn't need to know which
## inputs trigger them. 
extends CharacterBody2D

@export var speed:float = 150
@export var dash_speed_bonus:float = 250

@export var horizontal_movement:GUIDEAction
@export var dash_left:GUIDEAction
@export var dash_right:GUIDEAction
@export var fireball_left:GUIDEAction
@export var fireball_right:GUIDEAction

@export var fireball_scene:PackedScene

var _dash_bonus:float 

func _ready() -> void:
	# We can use the event system to get notified whenever
	# the combo actions trigger. This way we don't need to check them
	# in _physics_process every frame.
	dash_left.triggered.connect(func() -> void: _dash_bonus = -1)
	dash_right.triggered.connect(func() -> void: _dash_bonus = 1)
	fireball_left.triggered.connect(_spawn_fireball.bind(Vector2.LEFT))
	fireball_right.triggered.connect(_spawn_fireball.bind(Vector2.RIGHT))


func _physics_process(delta:float) -> void:
	# Get current left-right input
	var movement:float = horizontal_movement.value_axis_1d
	
	# Move any dash bonus towards zero
	_dash_bonus = move_toward(_dash_bonus, 0, delta)
	
	# Calculate new velocity
	velocity.x = movement * speed + _dash_bonus * dash_speed_bonus
	velocity.y = 980
	move_and_slide()
	
	
func _spawn_fireball(direction:Vector2) -> void:
	# spawn a new fireball
	var fireball:Node2D = fireball_scene.instantiate()
	# add it to the tree
	get_parent().add_child(fireball)
	# start at our position/orientation
	fireball.global_transform = global_transform
	# fly into the given direction
	fireball.direction = direction
