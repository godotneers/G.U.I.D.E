@tool
extends GridContainer

@onready var _up:TextureRect = %Up
@onready var _left:TextureRect = %Left
@onready var _right:TextureRect = %Right
@onready var _down:TextureRect = %Down


@export var up:Texture2D:
	set(value):
		if value == up:
			return
		up = value
		_refresh()
		
		
@export var left:Texture2D:
	set(value):
		if value == left:
			return
		left = value
		_refresh()
		
		
@export var right:Texture2D:
	set(value):
		if value == right:
			return
		right= value
		_refresh()
		
@export var down:Texture2D:
	set(value):
		if value == down:
			return
		down = value
		_refresh()


func _ready() -> void:
	_refresh()
	
	
func _refresh() -> void:
	if not is_node_ready():
		return
		
	_up.texture = up
	_down.texture = down
	_left.texture = left
	_right.texture = right
