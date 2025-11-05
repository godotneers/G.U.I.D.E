@tool
extends MarginContainer

const ClassScanner = preload("../class_scanner.gd")
const Utils = preload("../utils.gd")
const ArrayEdit = preload("../array_edit/array_edit.gd")

@export var action_mapping_editor_scene:PackedScene

@onready var _title_label:Label = %TitleLabel
@onready var _action_mappings:ArrayEdit = %ActionMappings
@onready var _editing_view:Control = %EditingView
@onready var _empty_view:Control = %EmptyView

var _plugin:EditorPlugin
var _current_context:GUIDEMappingContext
var _undo_redo:EditorUndoRedoManager
var _scanner:ClassScanner


func _ready() -> void:
	_title_label.add_theme_font_override("font", get_theme_font("title", "EditorFonts"))
	_scanner = ClassScanner.new()
	
	_editing_view.visible = false
	_empty_view.visible = true
	
	_action_mappings.add_requested.connect(_on_action_mappings_add_requested)
	_action_mappings.move_requested.connect(_on_action_mappings_move_requested)
	_action_mappings.delete_requested.connect(_on_action_mapping_delete_requested)
	_action_mappings.clear_requested.connect(_on_action_mappings_clear_requested)
	_action_mappings.duplicate_requested.connect(_on_action_mapping_duplicate_requested)
	_action_mappings.collapse_state_changed.connect(_on_action_mappings_collapse_state_changed)

func initialize(plugin:EditorPlugin) -> void:
	_plugin = plugin
	_undo_redo = plugin.get_undo_redo()
	
	
func edit(context:GUIDEMappingContext) -> void:
	if is_instance_valid(_current_context):
		_current_context.changed.disconnect(_refresh)
		
	_current_context = context
	
	if is_instance_valid(_current_context):
		_current_context.changed.connect(_refresh)
	
	_refresh()
	
	
func _refresh() -> void:
	_editing_view.visible = is_instance_valid(_current_context)
	_empty_view.visible = not is_instance_valid(_current_context)
	
	if not is_instance_valid(_current_context):
		return
	
	_title_label.text = _current_context._editor_name()
	_title_label.tooltip_text = _current_context.resource_path
	
	_action_mappings.clear()
		
	for i in _current_context.mappings.size():
		var mapping := _current_context.mappings[i]
		
		var mapping_editor:Variant = action_mapping_editor_scene.instantiate()
		mapping_editor.initialize(_plugin, _scanner)
		
		_action_mappings.add_item(mapping_editor)
		
		mapping_editor.edit(mapping)
		
	_action_mappings.collapsed = _current_context.get_meta("_guide_action_mappings_collapsed", false)
		
func _on_action_mappings_add_requested() -> void:
	var mappings := _current_context.mappings.duplicate()
	var new_mapping := GUIDEActionMapping.new()
	# don't set an action because they should come from the file system
	mappings.append(new_mapping)
	
	_undo_redo.create_action("Add action mapping")
	
	_undo_redo.add_do_property(_current_context, "mappings", mappings)
	_undo_redo.add_undo_property(_current_context, "mappings", _current_context.mappings)
	
	_undo_redo.commit_action()


func _on_action_mappings_move_requested(from:int, to:int) -> void:
	var mappings := _current_context.mappings.duplicate()
	var mapping:Variant = mappings[from]
	mappings.remove_at(from)
	if from < to:
		to -= 1
	mappings.insert(to, mapping)
	
	_undo_redo.create_action("Move action mapping")
	
	_undo_redo.add_do_property(_current_context, "mappings", mappings)
	_undo_redo.add_undo_property(_current_context, "mappings", _current_context.mappings)
	
	_undo_redo.commit_action()


func _on_action_mapping_delete_requested(index:int) -> void:
	var mappings := _current_context.mappings.duplicate()
	mappings.remove_at(index)
	
	_undo_redo.create_action("Delete action mapping")
	
	_undo_redo.add_do_property(_current_context, "mappings", mappings)
	_undo_redo.add_undo_property(_current_context, "mappings", _current_context.mappings)
	
	_undo_redo.commit_action()


func _on_action_mappings_clear_requested() -> void:
	var mappings:Array[GUIDEActionMapping] = []
	
	_undo_redo.create_action("Clear action mappings")
	
	_undo_redo.add_do_property(_current_context, "mappings", mappings)
	_undo_redo.add_undo_property(_current_context, "mappings", _current_context.mappings)
	
	_undo_redo.commit_action()
	
func _on_action_mapping_duplicate_requested(index:int) -> void:
	var mappings := _current_context.mappings.duplicate()
	var to_duplicate:GUIDEActionMapping = mappings[index]
	
	var copy := GUIDEActionMapping.new()
	# don't set the action, because each mapping should have a unique mapping
	for input_mapping:GUIDEInputMapping in to_duplicate.input_mappings:
		var copied_input_mapping := GUIDEInputMapping.new()
		copied_input_mapping.input = Utils.duplicate_if_inline(input_mapping.input)
		for modifier in input_mapping.modifiers:
			copied_input_mapping.modifiers.append(Utils.duplicate_if_inline(modifier))
		
		for trigger in input_mapping.triggers:
			copied_input_mapping.triggers.append(Utils.duplicate_if_inline(trigger))
			
		copy.input_mappings.append(copied_input_mapping)
			
	# insert the copy after the copied mapping
	mappings.insert(index+1, copy)
	
	
	_undo_redo.create_action("Duplicate action mapping")
	
	_undo_redo.add_do_property(_current_context, "mappings", mappings)
	_undo_redo.add_undo_property(_current_context, "mappings", _current_context.mappings)
	
	_undo_redo.commit_action()	

func _on_action_mappings_collapse_state_changed(new_state:bool) -> void:
	_current_context.set_meta("_guide_action_mappings_collapsed", new_state)


