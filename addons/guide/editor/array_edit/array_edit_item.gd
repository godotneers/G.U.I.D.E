@tool
extends Container
const Utils = preload("../utils.gd")
const Dragger = preload("dragger.gd")

signal move_requested(from:int, to:int)
signal delete_requested(index:int)
signal duplicate_requested(index:int)

@onready var _dragger:Dragger = %Dragger
@onready var _content:Container = %Content
@onready var _before_indicator:ColorRect = %BeforeIndicator
@onready var _after_indicator:ColorRect = %AfterIndicator
@onready var _popup_menu:PopupMenu = %PopupMenu


const ID_DELETE:int = 2
const ID_DUPLICATE:int = 3

func _ready():
	_dragger.icon = get_theme_icon("GuiSpinboxUpdown", "EditorIcons")
	_before_indicator.color = get_theme_color("box_selection_stroke_color", "Editor")
	_after_indicator.color = get_theme_color("box_selection_stroke_color", "Editor")
	_before_indicator.visible = false
	_after_indicator.visible = false
	_dragger._parent_array = get_parent()
	_dragger._index = get_index()
	_dragger.pressed.connect(_show_popup_menu)
	
	_popup_menu.clear()
	_popup_menu.add_icon_item(get_theme_icon("Duplicate", "EditorIcons"), "Duplicate", ID_DUPLICATE)
	_popup_menu.add_icon_item(get_theme_icon("Remove", "EditorIcons"), "Delete", ID_DELETE)
	_popup_menu.id_pressed.connect(_on_popup_menu_id_pressed)

func initialize(content:Control):
	Utils.clear(_content)
	_content.add_child(content)
		

func _can_drop_data(at_position:Vector2, data) -> bool:
	if data is Dictionary and data.has("parent_array") and data.parent_array == get_parent() and data.index != get_index():
		var height := size.y
	
		var is_before := not _is_last_child() or (at_position.y < height/2.0)
		if is_before and data.index == get_index() - 1:
			# don't allow the previous child to be inserted at its
			# own position
			return false
		
		_before_indicator.visible = is_before
		_after_indicator.visible = not is_before
		return true
	
	return false
	
	
func _drop_data(at_position:Vector2, data:Variant) -> void:
	var height := size.y
	var is_before := not _is_last_child() or (at_position.y < height/2.0)
	var to := get_index() if is_before else get_index() + 1
	move_requested.emit(data.index, to) 
	_before_indicator.visible = false
	_after_indicator.visible = false

func _is_last_child() -> bool:
	return get_index() == get_parent().get_child_count() - 1


func _on_mouse_exited() -> void:
	_before_indicator.visible = false
	_after_indicator.visible = false


func _show_popup_menu() -> void:
	# https://github.com/godotneers/G.U.I.D.E/issues/88
	# We use DisplayServer.mouse_get_position() to get the position of the mouse
	# in a way that works with multiple monitors.
	_popup_menu.popup(Rect2(get_screen_position() + get_local_mouse_position(), Vector2.ZERO))


func _on_popup_menu_id_pressed(id:int) -> void:
	match id:
		ID_DELETE:
			delete_requested.emit(get_index())
		ID_DUPLICATE:
			duplicate_requested.emit(get_index())
