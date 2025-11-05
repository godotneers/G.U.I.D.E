extends Sprite2D

## The speed at which the player moves.
@export var speed:float = 300
## The action that moves the player.
@export var move_action:GUIDEAction
## The action that says hi.
@export var say_hi_action:GUIDEAction

func _ready() -> void:
	# Call the `say_hi` function whenever the say_hi_action is triggered.
	say_hi_action.triggered.connect(_say_hi)

func _say_hi() -> void:
	# Quickly show and hide message panel
	%MessagePanel.visible = true
	await get_tree().create_timer(0.5).timeout
	%MessagePanel.visible = false
	
func _process(delta:float) -> void:
	# Get the input value from the action and move the player.
	position += move_action.value_axis_2d * speed * delta
