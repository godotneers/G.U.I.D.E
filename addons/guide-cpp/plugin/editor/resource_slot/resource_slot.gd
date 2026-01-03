@tool
extends LineEdit

signal changed()

func _ready():
	editable = false
	context_menu_enabled = false
	virtual_keyboard_enabled = false
	shortcut_keys_enabled = false
	selecting_enabled = false
	drag_and_drop_selection_enabled = false
	middle_mouse_paste_enabled = false

## The underlying resource. This is opened for editing when the user clicks on the control. Its also 
## used when dragging from the control.
var _value:Resource = null:
	set(value):
		if _value == value:
			return

		# stop tracking changes to the old resource (if any)
		if is_instance_valid(_value):
			_value.changed.disconnect(_update_from_value)
			
		_value = value

		# track changes to the resource itself
		if is_instance_valid(_value):
			_value.changed.connect(_update_from_value)
		
		_update_from_value()
		changed.emit()

func _update_from_value():
	if not is_instance_valid(_value):
		text = "<none>"
		tooltip_text = ""
		remove_theme_color_override("font_uneditable_color")
	else:
		text = _value._editor_name()
		tooltip_text = _value.resource_path
		# if the value is shared, we override the font color to indicate that
		if not GUIDEEditorUtils.is_inline(_value):
			add_theme_color_override("font_uneditable_color", get_theme_color("accent_color", "Editor"))
			queue_redraw()
		else:
			remove_theme_color_override("font_uneditable_color")

## Can be overridden to handle the drop data. This method is called when the user drops something on the control.
## If the value should be updated ,this method should set the _value property.
func _do_drop_data(data:Resource):
	_value = data
	
	
## Whether this control can accept drop data. This method is called when the user drags something over the control.
func _accepts_drop_data(data:Resource) -> bool:
	return false
	
func _can_drop_data(at_position, data) -> bool:
	if data is Resource:
		return _accepts_drop_data(data)
	
	if not data is Dictionary:
		return false

	if data.has("files"):
		for file in data["files"]:
			if _accepts_drop_data(ResourceLoader.load(file)):
				return true

	return false


func _drop_data(at_position, data) -> void:
	if data is Resource:
		_do_drop_data(data)
		return
	
	for file in data["files"]:
		var item := ResourceLoader.load(file)
		_do_drop_data(item)
		

func _get_drag_data(at_position: Vector2) -> Variant:
	if is_instance_valid(_value):
		var _preview := TextureRect.new()
		_preview.texture = get_theme_icon("File", "EditorIcons")
		set_drag_preview(_preview)
		# if the value is shared, we just hand out the resource path
		if not GUIDEEditorUtils.is_inline(_value):
			return {"files": [_value.resource_path]}
		else:
			# otherwise we hand out a shallow copy
			return _value.duplicate()
	else:
		return null

func _gui_input(event):
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			if is_instance_valid(_value):
				EditorInterface.edit_resource(_value)
