@tool
extends MarginContainer

const ClassScanner = preload("../class_scanner.gd")
const ResourceScanner = preload("../resource_scanner.gd")
const ArrayEdit = preload("../array_edit/array_edit.gd")

@export var action_mapping_editor_scene:PackedScene

@onready var _action_mappings:ArrayEdit = %ActionMappings
@onready var _editing_view:Control = %EditingView
@onready var _empty_view:Control = %EmptyView
@onready var _mapping_context_switcher:OptionButton = %MappingContextSwitcher

var _plugin:EditorPlugin
var _current_context:GUIDEMappingContext
var _undo_redo:EditorUndoRedoManager
var _list_dirty:bool

func _ready() -> void:
	if GUIDEEditorUtils.is_node_in_edited_scene(self):
		return
	
	_editing_view.visible = false
	_empty_view.visible = true
	
	_action_mappings.add_requested.connect(_on_action_mappings_add_requested)
	_action_mappings.move_requested.connect(_on_action_mappings_move_requested)
	_action_mappings.delete_requested.connect(_on_action_mapping_delete_requested)
	_action_mappings.clear_requested.connect(_on_action_mappings_clear_requested)
	_action_mappings.duplicate_requested.connect(_on_action_mapping_duplicate_requested)
	_action_mappings.collapse_state_changed.connect(_on_action_mappings_collapse_state_changed)
	
	_mapping_context_switcher.item_selected.connect(_on_mapping_context_switch_requested)
	
	_list_dirty = true
	visibility_changed.connect(func() -> void: if visible: _update_list())
	

func initialize(plugin:EditorPlugin) -> void:
	_plugin = plugin
	_undo_redo = plugin.get_undo_redo()
	# mark the list dirty in case the fiqddle system changed.
	EditorInterface.get_resource_filesystem().filesystem_changed.connect(func() -> void: _list_dirty = true)
	
	
func edit(context:GUIDEMappingContext) -> void:
	if is_instance_valid(_current_context):
		_current_context.changed.disconnect(_refresh)
		
	_current_context = context
	
	if is_instance_valid(_current_context):
		_current_context.changed.connect(_refresh)
	
	_refresh()
	
	
func _update_list() -> void:
	if not _list_dirty:
		return
		
	var context_paths:Array[String] = ResourceScanner.find_resources_of_type("GUIDEMappingContext")
	## Build a mapping of shortened labels -> full paths and populate the switcher
	var shortened:Dictionary = _build_shortened_path_map(context_paths)
	_mapping_context_switcher.clear()

	# Insert a dummy entry at the top so the user can intentionally pick a context.
	var dummy_label:String = "Select mapping context..."
	_mapping_context_switcher.add_item(dummy_label)
	# Metadata null marks the dummy entry.
	_mapping_context_switcher.set_item_metadata(0, null)

	var keys:Array[String] = []
	for k in shortened.keys():
		keys.append(k as String)
	keys.sort()

	for i in keys.size():
		var key:String = keys[i]
		var full_path:String = shortened[key]
		# +1 because of the dummy item at index 0
		var render_index:int = i + 1
		_mapping_context_switcher.add_item(key)
		_mapping_context_switcher.set_item_metadata(render_index, full_path)
		_mapping_context_switcher.set_item_tooltip(render_index, full_path)
	
	_list_dirty = false

	
func _refresh() -> void:
	_update_list()
	
	_editing_view.visible = is_instance_valid(_current_context)
	_empty_view.visible = not is_instance_valid(_current_context)
	

	if not is_instance_valid(_current_context):
		return

	# make sure the switcher shows the currently selected item.
	_mapping_context_switcher.tooltip_text = _current_context.resource_path
	var selected_index:int = 0
	for i in _mapping_context_switcher.item_count:
		var item_path = _mapping_context_switcher.get_item_metadata(i)
		if item_path == _current_context.resource_path:
			selected_index = i
			break
			
	_mapping_context_switcher.select(selected_index)
	
	_action_mappings.clear()
		
	for i in _current_context.mappings.size():
		var mapping := _current_context.mappings[i]
		
		var mapping_editor:Variant = action_mapping_editor_scene.instantiate()
		mapping_editor.initialize(_plugin)
		
		_action_mappings.add_item(mapping_editor)
		
		mapping_editor.edit(mapping)
		
	_action_mappings.collapsed = _current_context.get_meta("_guide_action_mappings_collapsed", false)


## Creates unique, human-friendly short labels for a list of resource paths by
## progressively adding parent directories to conflicting filenames until they
## become unique. The resulting keys are sorted elsewhere for display.
## @param paths All full resource paths to mapping contexts (e.g. res://foo/bar/baz.tres).
## @return Dictionary that maps a shortened label (e.g. "bar/baz.tres") to the full path.
func _build_shortened_path_map(paths:Array[String]) -> Dictionary:
	# Prepare path parts reversed per path for easy prefix growth from filename upwards.
	# Note: Avoid nested typed collections (Array[Array[String]]) due to GDScript limitations.
	var parts_per_path:Array = []
	parts_per_path.resize(paths.size())
	for i in paths.size():
		var p:String = paths[i]
		var without_scheme:String = p
		if without_scheme.begins_with("res://"):
			without_scheme = without_scheme.substr(6)
		var comps:Array = without_scheme.split("/", false)
		comps.reverse() # [filename, parent, grandparent, ...]
		parts_per_path[i] = comps

	# Track how many components from the end each entry currently uses for its label.
	var used_counts:Array[int] = []
	used_counts.resize(paths.size())
	for i in used_counts.size():
		used_counts[i] = 1 # start with filename only

	var current_label:Callable = func(idx:int) -> String:
		var parts:Array = parts_per_path[idx]
		var count:int = min(used_counts[idx], parts.size())
		var slice:Array = parts.slice(0, count)
		slice.reverse() # restore order to parent/.../filename
		return "/".join(slice)

	# Iteratively resolve collisions by adding parents to all entries in each clashing group.
	while true:
		var label_to_indices:Dictionary = {}
		for i in paths.size():
			var label:String = current_label.call(i)
			if not label_to_indices.has(label):
				label_to_indices[label] = []
			(label_to_indices[label] as Array).append(i)
		
		var had_collision:bool = false
		for label in label_to_indices.keys():
			var indices:Array = label_to_indices[label]
			if indices.size() > 1:
				had_collision = true
				for idx in indices:
					var i:int = int(idx)
					# Only increase if there are more parents available.
					if used_counts[i] < parts_per_path[i].size():
						used_counts[i] += 1
					# If exhausted, we leave it as full path-equivalent label.
		
		if not had_collision:
			break

	# Build the final dictionary mapping label -> full path.
	var result:Dictionary = {}
	for i in paths.size():
		var label:String = current_label.call(i)
		result[label] = paths[i]
	return result
	
	
		
		
func _on_mapping_context_switch_requested(index:int) -> void:
	var mc:Variant = _mapping_context_switcher.get_item_metadata(index)
	if mc != null:
		var context:GUIDEMappingContext = load(mc as String) as GUIDEMappingContext
		if context != null and context != _current_context:
			edit(context)
	
		
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
		copied_input_mapping.input = GUIDEEditorUtils.duplicate_if_inline(input_mapping.input)
		for modifier in input_mapping.modifiers:
			copied_input_mapping.modifiers.append(GUIDEEditorUtils.duplicate_if_inline(modifier))
		
		for trigger in input_mapping.triggers:
			copied_input_mapping.triggers.append(GUIDEEditorUtils.duplicate_if_inline(trigger))
			
		copy.input_mappings.append(copied_input_mapping)
			
	# insert the copy after the copied mapping
	mappings.insert(index+1, copy)
	
	
	_undo_redo.create_action("Duplicate action mapping")
	
	_undo_redo.add_do_property(_current_context, "mappings", mappings)
	_undo_redo.add_undo_property(_current_context, "mappings", _current_context.mappings)
	
	_undo_redo.commit_action()	

func _on_action_mappings_collapse_state_changed(new_state:bool) -> void:
	_current_context.set_meta("_guide_action_mappings_collapsed", new_state)
