@tool
extends Container
const Utils = preload("../utils.gd")

@export var item_scene:PackedScene 

@export var title:String = "":
	set(value):
		title = value
		_refresh()

@export var add_tooltip:String:
	set(value):
		add_tooltip = value
		_refresh()

@export var clear_tooltip:String:
	set(value):
		clear_tooltip = value
		_refresh()

@export var item_separation:int = 8: 
	set(value):
		item_separation = value
		_refresh()


@export var collapsed:bool = false: 
	set(value):
		collapsed = value
		_refresh()

signal add_requested()
signal delete_requested(index:int)
signal move_requested(from:int, to:int)
signal insert_requested(index:int)
signal duplicate_requested(index:int)
signal clear_requested()
signal collapse_state_changed(collapsed:bool)

@onready var _add_button:Button = %AddButton
@onready var _clear_button:Button = %ClearButton
@onready var _contents:Container = %Contents
@onready var _title_label:Label = %TitleLabel
@onready var _collapse_button:Button = %CollapseButton
@onready var _expand_button:Button = %ExpandButton
@onready var _count_label:Label = %CountLabel

func _ready():
	_add_button.icon = get_theme_icon("Add", "EditorIcons")
	_add_button.pressed.connect(func(): add_requested.emit())
	
	_clear_button.icon = get_theme_icon("Clear", "EditorIcons")
	_clear_button.pressed.connect(func(): clear_requested.emit())
	
	_collapse_button.icon = get_theme_icon("Collapse", "EditorIcons")
	_collapse_button.pressed.connect(_on_collapse_pressed)

	_expand_button.icon = get_theme_icon("Forward", "EditorIcons")
	_expand_button.pressed.connect(_on_expand_pressed)
	
	
	_refresh()

	
func _refresh():
	if is_instance_valid(_add_button):
		_add_button.tooltip_text = add_tooltip
	if is_instance_valid(_clear_button):
		_clear_button.tooltip_text = clear_tooltip
		_clear_button.visible = _contents.get_child_count() > 0
		
	if is_instance_valid(_contents):
		_contents.add_theme_constant_override("separation", item_separation)
		_contents.visible = not collapsed
		
	if is_instance_valid(_collapse_button):
		_collapse_button.visible = not collapsed

	if is_instance_valid(_expand_button):
		_expand_button.visible = collapsed
		
	if is_instance_valid(_title_label):
		_title_label.text = title
	
	if is_instance_valid(_count_label):
		_count_label.text = "(%s)" % [_contents.get_child_count()]
			

func clear():
	Utils.clear(_contents)
	_refresh()


func add_item(new_item:Control):
	var item_wrapper := item_scene.instantiate()
	_contents.add_child(item_wrapper)
	item_wrapper.initialize(new_item)
	item_wrapper.move_requested.connect(func(from:int, to:int): move_requested.emit(from, to))
	item_wrapper.delete_requested.connect(func(idx:int): delete_requested.emit(idx) )
	item_wrapper.duplicate_requested.connect(func(idx:int): duplicate_requested.emit(idx) )
	_refresh()


func _on_collapse_pressed():
	collapsed = true
	collapse_state_changed.emit(true)
	
	
func _on_expand_pressed():
	collapsed = false
	collapse_state_changed.emit(false)

