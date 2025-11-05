extends Node2D


@onready var _animation_player:AnimationPlayer = %AnimationPlayer
@onready var _progress_bar:ProgressBar = %ProgressBar

@export var jump_action:GUIDEAction
@export var somersault_action:GUIDEAction

func _ready() -> void:
	jump_action.triggered.connect(_play.bind("jump"))
	somersault_action.triggered.connect(_play.bind("somersault"))
	somersault_action.ongoing.connect(_update_progress_bar)
	somersault_action.triggered.connect(_hide_progress_bar)
	somersault_action.cancelled.connect(_hide_progress_bar)
	
func _play(animation:String) -> void:
	if _animation_player.is_playing():
		return
		
	_animation_player.play(animation)
	
func _update_progress_bar() -> void:
	# exceeds tap time
	if somersault_action.elapsed_seconds > 0.1:
		_progress_bar.value = somersault_action.elapsed_ratio
		_progress_bar.visible = true

func _hide_progress_bar() -> void:
	_progress_bar.visible = false
