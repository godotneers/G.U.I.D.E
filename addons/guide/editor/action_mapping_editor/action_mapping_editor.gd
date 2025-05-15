@tool
extends MarginContainer

const ActionSlot = preload("../action_slot/action_slot.gd")
const Utils = preload("../utils.gd")
const ArrayEdit = preload("../array_edit/array_edit.gd")

signal delete_requested()
signal duplicate_requested()

@export var input_mapping_editor_scene:PackedScene
@onready var _action_slot:ActionSlot = %ActionSlot
@onready var _input_mappings:ArrayEdit = %InputMappings

const ClassScanner = preload("../class_scanner.gd")

var _plugin:EditorPlugin
var _scanner:ClassScanner
var _undo_redo:EditorUndoRedoManager

var _mapping:GUIDEActionMapping

func _ready():
	_action_slot.action_changed.connect(_on_action_changed)
	_input_mappings.delete_requested.connect(_on_input_mapping_delete_requested)
	_input_mappings.add_requested.connect(_on_input_mappings_add_requested)
	_input_mappings.move_requested.connect(_on_input_mappings_move_requested)
	_input_mappings.clear_requested.connect(_on_input_mappings_clear_requested)
	_input_mappings.duplicate_requested.connect(_on_input_mappings_duplicate_requested)
	_input_mappings.collapse_state_changed.connect(_on_input_mappings_collapse_state_changed)

func initialize(plugin:EditorPlugin, scanner:ClassScanner):
	_plugin = plugin
	_scanner = scanner
	_undo_redo = _plugin.get_undo_redo()


func edit(mapping:GUIDEActionMapping):
	assert(_mapping == null)
	_mapping = mapping

	_mapping.changed.connect(_update)

	_update()


func _update():
	_input_mappings.clear()

	_action_slot.action = _mapping.action

	for i in _mapping.input_mappings.size():
		var input_mapping = _mapping.input_mappings[i]
		var input_mapping_editor = input_mapping_editor_scene.instantiate()
		_input_mappings.add_item(input_mapping_editor)

		input_mapping_editor.initialize(_plugin, _scanner)
		input_mapping_editor.edit(input_mapping)

	_input_mappings.collapsed = _mapping.get_meta("_guide_input_mappings_collapsed", false)


func _on_action_changed():
	_undo_redo.create_action("Change action")
	_undo_redo.add_do_property(_mapping, "action", _action_slot.action)
	_undo_redo.add_undo_property(_mapping, "action", _mapping.action)
	_undo_redo.commit_action()


func _on_input_mappings_add_requested():
	var values = _mapping.input_mappings.duplicate()
	var new_mapping = GUIDEInputMapping.new()
	values.append(new_mapping)

	_undo_redo.create_action("Add input mapping")

	_undo_redo.add_do_property(_mapping, "input_mappings", values)
	_undo_redo.add_undo_property(_mapping, "input_mappings", _mapping.input_mappings)

	_undo_redo.commit_action()


func _on_input_mapping_delete_requested(index:int):
	var values = _mapping.input_mappings.duplicate()
	values.remove_at(index)

	_undo_redo.create_action("Delete input mapping")
	_undo_redo.add_do_property(_mapping, "input_mappings", values)
	_undo_redo.add_undo_property(_mapping, "input_mappings", _mapping.input_mappings)

	_undo_redo.commit_action()


func _on_input_mappings_move_requested(from:int, to:int):
	var values = _mapping.input_mappings.duplicate()
	var mapping = values[from]
	values.remove_at(from)
	if from < to:
		to -= 1
	values.insert(to, mapping)

	_undo_redo.create_action("Move input mapping")
	_undo_redo.add_do_property(_mapping, "input_mappings", values)
	_undo_redo.add_undo_property(_mapping, "input_mappings", _mapping.input_mappings)

	_undo_redo.commit_action()


func _on_input_mappings_clear_requested():
	var values:Array[GUIDEInputMapping] = []
	_undo_redo.create_action("Clear input mappings")
	_undo_redo.add_do_property(_mapping, "input_mappings", values)
	_undo_redo.add_undo_property(_mapping, "input_mappings", _mapping.input_mappings)

	_undo_redo.commit_action()

func _on_input_mappings_duplicate_requested(index:int):
	var values = _mapping.input_mappings.duplicate()
	var copy:GUIDEInputMapping = values[index].duplicate()
	copy.input = Utils.duplicate_if_inline(copy.input)

	for i in copy.modifiers.size():
		copy.modifiers[i] = Utils.duplicate_if_inline(copy.modifiers[i])

	for i in copy.triggers.size():
		copy.triggers[i] = Utils.duplicate_if_inline(copy.triggers[i])

	# insert copy after original
	values.insert(index+1, copy)

	_undo_redo.create_action("Duplicate input mapping")
	_undo_redo.add_do_property(_mapping, "input_mappings", values)
	_undo_redo.add_undo_property(_mapping, "input_mappings", _mapping.input_mappings)

	_undo_redo.commit_action()


func _on_input_mappings_collapse_state_changed(new_state:bool):
	_mapping.set_meta("_guide_input_mappings_collapsed", new_state)

