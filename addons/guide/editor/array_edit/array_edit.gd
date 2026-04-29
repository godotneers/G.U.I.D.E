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


@export var show_insert_options:bool = false:
	set(value):
		show_insert_options = value
		_build_popup()


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
@onready var _popup_menu:PopupMenu = %PopupMenu

const _ID_DELETE:int = 2
const _ID_DUPLICATE:int = 3
const _ID_INSERT_BEFORE:int = 4
const _ID_INSERT_AFTER:int = 5

var _active_item_index:int = -1

func _ready():
	_add_button.icon = get_theme_icon("Add", "EditorIcons")
	_add_button.pressed.connect(func(): add_requested.emit())

	_clear_button.icon = get_theme_icon("Clear", "EditorIcons")
	_clear_button.pressed.connect(func(): clear_requested.emit())

	_collapse_button.icon = get_theme_icon("Collapse", "EditorIcons")
	_collapse_button.pressed.connect(_on_collapse_pressed)

	_expand_button.icon = get_theme_icon("Forward", "EditorIcons")
	_expand_button.pressed.connect(_on_expand_pressed)

	_popup_menu.id_pressed.connect(_on_popup_id_pressed)
	_build_popup()
	_refresh()


func _build_popup() -> void:
	if not is_instance_valid(_popup_menu):
		return
	_popup_menu.clear()
	_popup_menu.add_icon_item(get_theme_icon("Duplicate", "EditorIcons"), "Duplicate", _ID_DUPLICATE)
	if show_insert_options:
		_popup_menu.add_icon_item(get_theme_icon("InsertBefore", "EditorIcons"), "Insert Before", _ID_INSERT_BEFORE)
		_popup_menu.add_icon_item(get_theme_icon("InsertAfter", "EditorIcons"), "Insert After", _ID_INSERT_AFTER)
	_popup_menu.add_icon_item(get_theme_icon("Remove", "EditorIcons"), "Delete", _ID_DELETE)


func _on_popup_id_pressed(id:int) -> void:
	match id:
		_ID_DELETE:
			delete_requested.emit(_active_item_index)
		_ID_DUPLICATE:
			duplicate_requested.emit(_active_item_index)
		_ID_INSERT_BEFORE:
			insert_requested.emit(_active_item_index)
		_ID_INSERT_AFTER:
			insert_requested.emit(_active_item_index + 1)


func _on_item_context_menu_requested(index:int, screen_position:Vector2) -> void:
	_active_item_index = index
	_popup_menu.popup(Rect2(screen_position, Vector2.ZERO))


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
	item_wrapper.context_menu_requested.connect(_on_item_context_menu_requested)
	_refresh()


func _on_collapse_pressed():
	collapsed = true
	collapse_state_changed.emit(true)


func _on_expand_pressed():
	collapsed = false
	collapse_state_changed.emit(false)