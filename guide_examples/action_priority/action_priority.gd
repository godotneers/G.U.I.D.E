extends Node2D


@export var mapping_context:GUIDEMappingContext
@export var spell_toggle:GUIDEAction

@onready var _layer_1:Control = %Layer1
@onready var _layer_2:Control = %Layer2


func _ready() -> void:
	GUIDE.enable_mapping_context(mapping_context)
	spell_toggle.triggered.connect(func() -> void: _layer_1.hide(); _layer_2.show())
	spell_toggle.completed.connect(func() -> void: _layer_1.show(); _layer_2.hide())
