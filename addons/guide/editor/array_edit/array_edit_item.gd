@tool
extends Container
const Utils = preload("../utils.gd")
const Dragger = preload("dragger.gd")

signal move_requested(from:int, to:int)
signal context_menu_requested(index:int, screen_position:Vector2)

@onready var _dragger:Dragger = %Dragger
@onready var _content:Container = %Content
@onready var _before_indicator:ColorRect = %BeforeIndicator
@onready var _after_indicator:ColorRect = %AfterIndicator


func _ready():
	_dragger.icon = get_theme_icon("GuiSpinboxUpdown", "EditorIcons")
	_before_indicator.color = get_theme_color("box_selection_stroke_color", "Editor")
	_after_indicator.color = get_theme_color("box_selection_stroke_color", "Editor")
	_before_indicator.visible = false
	_after_indicator.visible = false
	_dragger._parent_array = get_parent()
	_dragger._index = get_index()
	_dragger.pressed.connect(_on_dragger_pressed)

func initialize(content:Control):
	Utils.clear(_content)
	_content.add_child(content)


func _on_dragger_pressed() -> void:
	context_menu_requested.emit(get_index(), get_screen_position() + get_local_mouse_position())


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