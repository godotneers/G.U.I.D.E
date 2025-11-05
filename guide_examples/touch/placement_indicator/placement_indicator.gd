# This component shows a progress bar for the hold time, indicating to the player 
# that they must keep touching the screen until something is placed. 
extends Node2D

@export var spawn:GUIDEAction
@onready var texture_progress_bar:TextureProgressBar = %TextureProgressBar

func _ready() -> void:
	visible = false
	# While the hold trigger is evaluating show the progress bar
	spawn.ongoing.connect(_show)
	# Once it is done, hide it again
	spawn.triggered.connect(_hide)
	# Same when it was cancelled
	spawn.cancelled.connect(_hide)
	
func _show() -> void:
	# show the indicator
	visible = true
	# move it to where we would spawn
	global_position = spawn.value_axis_2d
	# and update the progress bar
	texture_progress_bar.value = spawn.elapsed_seconds
	
func _hide() -> void:
	visible = false
