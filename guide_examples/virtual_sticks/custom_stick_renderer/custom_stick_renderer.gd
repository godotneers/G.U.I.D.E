extends GUIDEVirtualStickRenderer

@onready var wheel:TextureRect = %Wheel

var _initial_x:float 

func _ready():
	_initial_x = wheel.position.x
	

func _process(delta):
	if not is_stick_actuated:
		# return wheel back to center
		wheel.position.x = move_toward(wheel.position.x, _initial_x, wheel.size.x * 1.5 * delta)

func _update(joy_position: Vector2, joy_offset:Vector2, is_actuated:bool) -> void:
	if is_actuated:
		wheel.position.x = joy_position.x + _initial_x
