extends Sprite2D

@export var player_context: GUIDEMappingContext
@export var move: GUIDEAction

func _ready() -> void:
	GUIDE.enable_mapping_context(player_context)

func _process(delta: float) -> void:
	print(move.get_value_axis_2d())
	print(move.is_triggered())
	if move.is_triggered():
		position += move.get_value_axis_2d()
