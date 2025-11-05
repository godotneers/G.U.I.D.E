extends Node2D

@export var action:GUIDEAction
@export var texture:Texture2D

@onready var _animation_player:AnimationPlayer = %AnimationPlayer
@onready var _sprite_2d:Sprite2D = %Sprite2D

func _ready() -> void:
	_sprite_2d.texture = texture
	action.triggered.connect(_animation_player.play.bind("run"))
