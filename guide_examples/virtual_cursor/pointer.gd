extends Area2D

@export var cursor_2d:GUIDEAction
@export var click:GUIDEAction


func _ready() -> void:
	click.triggered.connect(_click)

func _process(_delta:float) -> void:
	global_position = cursor_2d.value_axis_2d


func _click() -> void:
	for clickable in get_overlapping_areas():
		if clickable.has_method("spin"):
			clickable.spin()
