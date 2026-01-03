@tool
extends MarginContainer

const ArrayEdit = preload("../array_edit/array_edit.gd")
const ClassScanner = preload("../class_scanner.gd")

@export var modifier_slot_scene:PackedScene
@export var trigger_slot_scene:PackedScene
@export var binding_dialog_scene:PackedScene

@onready var _edit_input_mapping_button:Button = %EditInputMappingButton
@onready var _input_display:RichTextLabel = %InputDisplay
@onready var _edit_input_button:Button = %EditInputButton
@onready var _clear_input_button:Button = %ClearInputButton

@onready var _modifiers:ArrayEdit = %Modifiers
@onready var _add_modifier_popup:PopupMenu = %AddModifierPopup

@onready var _triggers:ArrayEdit = %Triggers
@onready var _add_trigger_popup:PopupMenu = %AddTriggerPopup

var _plugin:EditorPlugin
var _undo_redo:EditorUndoRedoManager

var _mapping:GUIDEInputMapping

func _ready():
	_edit_input_button.icon = get_theme_icon("Edit", "EditorIcons")
	_clear_input_button.icon = get_theme_icon("Remove", "EditorIcons")
	_edit_input_mapping_button.icon = get_theme_icon("Tools", "EditorIcons")
	
	_modifiers.add_requested.connect(_on_modifiers_add_requested)
	_modifiers.delete_requested.connect(_on_modifier_delete_requested)
	_modifiers.duplicate_requested.connect(_on_modifier_duplicate_requested)
	_modifiers.move_requested.connect(_on_modifier_move_requested)
	_modifiers.clear_requested.connect(_on_modifiers_clear_requested)
	_modifiers.collapse_state_changed.connect(_on_modifiers_collapse_state_changed)
	
	_triggers.add_requested.connect(_on_triggers_add_requested)
	_triggers.delete_requested.connect(_on_trigger_delete_requested)
	_triggers.duplicate_requested.connect(_on_trigger_duplicate_requested)
	_triggers.move_requested.connect(_on_trigger_move_requested)
	_triggers.clear_requested.connect(_on_triggers_clear_requested)
	_triggers.collapse_state_changed.connect(_on_triggers_collapse_state_changed)
	
	
func initialize(plugin:EditorPlugin) -> void:
	_plugin = plugin
	_undo_redo = plugin.get_undo_redo()
	_input_display.clicked.connect(_on_input_display_clicked)
	
	
func edit(mapping:GUIDEInputMapping) -> void:
	assert(_mapping == null)
	_mapping = mapping
	_mapping.changed.connect(_update)
	_update()
	
	
func _update() -> void:
	_modifiers.clear()
	_triggers.clear()
	
	_input_display.input = _mapping.input
	for i in _mapping.modifiers.size():
		var modifier_slot := modifier_slot_scene.instantiate()
		_modifiers.add_item(modifier_slot)

		modifier_slot.modifier = _mapping.modifiers[i]
		modifier_slot.changed.connect(_on_modifier_changed.bind(i, modifier_slot))
		
	for i in _mapping.triggers.size():
		var trigger_slot := trigger_slot_scene.instantiate()
		_triggers.add_item(trigger_slot)

		trigger_slot.trigger = _mapping.triggers[i]
		trigger_slot.changed.connect(_on_trigger_changed.bind(i, trigger_slot))
		
	_modifiers.collapsed = _mapping.get_meta("_guide_modifiers_collapsed", false)
	_triggers.collapsed = _mapping.get_meta("_guide_triggers_collapsed", false)
	

func _on_modifiers_add_requested():
	_fill_popup(_add_modifier_popup, "GUIDEModifier")
	_add_modifier_popup.popup(Rect2(get_screen_position() + get_local_mouse_position(), Vector2.ZERO))


func _on_triggers_add_requested():
	_fill_popup(_add_trigger_popup, "GUIDETrigger")
	_add_trigger_popup.popup(Rect2(get_screen_position() + get_local_mouse_position(), Vector2.ZERO))
	
	
func _fill_popup(popup:PopupMenu, base_clazz:StringName):
	popup.clear(true)
	
	print("Debug: Looking for inheritors of ", base_clazz)
	
	# First, get C++ classes from ClassDB
	var cpp_inheritors := ClassDB.get_inheriters_from_class(base_clazz)
	print("Debug: Found ", cpp_inheritors.size(), " C++ inheritors: ", cpp_inheritors)
	
	for cpp_class in cpp_inheritors:
		# Skip the base class itself
		if cpp_class == base_clazz:
			continue
			
		print("Debug: Processing C++ class: ", cpp_class)
		
		# Try to create an instance to get editor info
		var instance = ClassDB.instantiate(cpp_class)
		if instance:
			# For C++ classes, use the class name as the display name if _editor_name is missing
			var editor_name: String
			if instance.has_method("_editor_name"):
				editor_name = instance._editor_name()
			else:
				# Create a readable name from the class name
				editor_name = cpp_class.replace("GUIDEModifier", "")
				editor_name = editor_name.replace("GUIDETrigger", "")
				# Add spaces for camel case
				var result = ""
				for i in range(editor_name.length()):
					if i > 0 and editor_name[i].to_upper() == editor_name[i]:
						result += " "
					result += editor_name[i]
				editor_name = result
				print("Debug: Using generated name: ", editor_name)
			
			print("Debug: Adding C++ class: ", editor_name)
			popup.add_item(editor_name)
			
			# Add description if available
			if instance.has_method("_editor_description"):
				popup.set_item_tooltip(popup.item_count - 1, instance._editor_description())
			else:
				# Add a default description
				popup.set_item_tooltip(popup.item_count - 1, "C++ " + base_clazz.replace("GUIDE", "") + " class")
			
			# Store the class name for instantiation later
			popup.set_item_metadata(popup.item_count - 1, cpp_class)
			
			# C++ classes are Resources, not Nodes, so they don't need queue_free()
		else:
			print("Debug: Failed to instantiate C++ class: ", cpp_class)
	
	# Then, get GDScript classes from ClassScanner
	var gdscript_inheritors := ClassScanner.find_inheritors(base_clazz)
	print("Debug: Found ", gdscript_inheritors.size(), " GDScript inheritors: ", gdscript_inheritors.keys())
	
	for type in gdscript_inheritors.keys():
		var class_script:Script = gdscript_inheritors[type]
		print("Debug: Processing GDScript class: ", type)
		var dummy:Variant = class_script.new()
		var editor_name = dummy._editor_name()
		print("Debug: Adding GDScript class: ", editor_name)
		popup.add_item(editor_name)
		popup.set_item_tooltip(popup.item_count -1, dummy._editor_description())
		popup.set_item_metadata(popup.item_count - 1, class_script)
	
	print("Debug: Popup now has ", popup.item_count, " items")

func _on_input_display_clicked():
	if is_instance_valid(_mapping.input):
		EditorInterface.edit_resource(_mapping.input)


func _on_input_changed(input:GUIDEInput):
	_undo_redo.create_action("Change input")
	
	_undo_redo.add_do_property(_mapping, "input", input)
	_undo_redo.add_undo_property(_mapping, "input", _mapping.input)
	
	_undo_redo.commit_action()
	
	if is_instance_valid(input):
		EditorInterface.edit_resource(input)
	

func _on_edit_input_button_pressed():
	var dialog:Window = binding_dialog_scene.instantiate()
	EditorInterface.popup_dialog_centered(dialog)	
	dialog.initialize()
	dialog.input_selected.connect(_on_input_changed)


func _on_clear_input_button_pressed():
	_undo_redo.create_action("Delete bound input")
	
	_undo_redo.add_do_property(_mapping, "input", null)
	_undo_redo.add_undo_property(_mapping, "triggers", _mapping.input)
	
	_undo_redo.commit_action()


func _on_add_modifier_popup_index_pressed(index:int) -> void:
	var metadata = _add_modifier_popup.get_item_metadata(index)
	var new_modifier: Variant
	
	# Check if it's a C++ class name (String) or GDScript (Script)
	if metadata is String:
		# C++ class
		new_modifier = ClassDB.instantiate(metadata)
	else:
		# GDScript class
		new_modifier = metadata.new()
	
	# Get the action name for the undo/redo action
	var action_name: String
	if new_modifier.has_method("_editor_name"):
		action_name = new_modifier._editor_name()
	else:
		# Use the metadata (class name) if no _editor_name method
		action_name = str(metadata)
		action_name = action_name.replace("GUIDEModifier", "")
	
	_undo_redo.create_action("Add " + action_name + " modifier")
	var modifiers := _mapping.modifiers.duplicate()
	modifiers.append(new_modifier)
	
	_undo_redo.add_do_property(_mapping, "modifiers", modifiers)
	_undo_redo.add_undo_property(_mapping, "modifiers", _mapping.modifiers)
	
	_undo_redo.commit_action()


func _on_add_trigger_popup_index_pressed(index):
	var metadata = _add_trigger_popup.get_item_metadata(index)
	var new_trigger: Variant
	
	# Check if it's a C++ class name (String) or GDScript (Script)
	if metadata is String:
		# C++ class
		new_trigger = ClassDB.instantiate(metadata)
	else:
		# GDScript class
		new_trigger = metadata.new()
	
	# Get the action name for the undo/redo action
	var action_name: String
	if new_trigger.has_method("_editor_name"):
		action_name = new_trigger._editor_name()
	else:
		# Use the metadata (class name) if no _editor_name method
		action_name = str(metadata)
		action_name = action_name.replace("GUIDETrigger", "")
	
	_undo_redo.create_action("Add " + action_name + " trigger")
	var triggers := _mapping.triggers.duplicate()
	triggers.append(new_trigger)
	
	_undo_redo.add_do_property(_mapping, "triggers", triggers)
	_undo_redo.add_undo_property(_mapping, "triggers", _mapping.triggers)
	
	_undo_redo.commit_action()


func _on_modifier_changed(index:int, slot) -> void:
	var new_modifier = slot.modifier
	
	_undo_redo.create_action("Replace modifier")
	var modifiers := _mapping.modifiers.duplicate()
	modifiers[index] = new_modifier
	
	_undo_redo.add_do_property(_mapping, "modifiers", modifiers)
	_undo_redo.add_undo_property(_mapping, "modifiers", _mapping.modifiers)
	
	_undo_redo.commit_action()
	
	
func _on_trigger_changed(index:int, slot) -> void:
	var new_trigger = slot.trigger
	
	_undo_redo.create_action("Replace trigger")
	var triggers := _mapping.triggers.duplicate()
	triggers[index] = new_trigger
	
	_undo_redo.add_do_property(_mapping, "triggers", triggers)
	_undo_redo.add_undo_property(_mapping, "triggers", _mapping.triggers)
	
	_undo_redo.commit_action()
	
	
func _on_modifier_move_requested(from:int, to:int) -> void:
	_undo_redo.create_action("Move modifier")
	var modifiers := _mapping.modifiers.duplicate()
	var modifier = modifiers[from]
	modifiers.remove_at(from)
	if from < to:
		to -= 1
	modifiers.insert(to, modifier)
	
	_undo_redo.add_do_property(_mapping, "modifiers", modifiers)
	_undo_redo.add_undo_property(_mapping, "modifiers", _mapping.modifiers)
	
	_undo_redo.commit_action()


func _on_trigger_move_requested(from:int, to:int) -> void:
	_undo_redo.create_action("Move trigger")
	var triggers := _mapping.triggers.duplicate()
	var trigger:GUIDETrigger = triggers[from]
	triggers.remove_at(from)
	if from < to:
		to -= 1
	triggers.insert(to, trigger)
	
	_undo_redo.add_do_property(_mapping, "triggers", triggers)
	_undo_redo.add_undo_property(_mapping, "triggers", _mapping.triggers)
	
	_undo_redo.commit_action()

func _on_modifier_duplicate_requested(index:int) -> void:
	_undo_redo.create_action("Duplicate modifier")
	var modifiers := _mapping.modifiers.duplicate()
	var copy := GUIDEEditorUtils.duplicate_if_inline(modifiers[index])
	modifiers.insert(index+1, copy)
	
	_undo_redo.add_do_property(_mapping, "modifiers", modifiers)
	_undo_redo.add_undo_property(_mapping, "modifiers", _mapping.modifiers)
	
	_undo_redo.commit_action()		

func _on_trigger_duplicate_requested(index:int) -> void:
	_undo_redo.create_action("Duplicate trigger")
	var triggers := _mapping.triggers.duplicate()
	var copy := GUIDEEditorUtils.duplicate_if_inline(triggers[index])
	triggers.insert(index+1, copy)
	
	_undo_redo.add_do_property(_mapping, "triggers", triggers)
	_undo_redo.add_undo_property(_mapping, "triggers", _mapping.triggers)
	
	_undo_redo.commit_action()	



func _on_modifier_delete_requested(index:int) -> void:
	_undo_redo.create_action("Delete modifier")
	var modifiers := _mapping.modifiers.duplicate()
	modifiers.remove_at(index)
	
	_undo_redo.add_do_property(_mapping, "modifiers", modifiers)
	_undo_redo.add_undo_property(_mapping, "modifiers", _mapping.modifiers)
	
	_undo_redo.commit_action()		

	
func _on_trigger_delete_requested(index:int) -> void:
	_undo_redo.create_action("Delete trigger")
	var triggers := _mapping.triggers.duplicate()
	triggers.remove_at(index)
	
	_undo_redo.add_do_property(_mapping, "triggers", triggers)
	_undo_redo.add_undo_property(_mapping, "triggers", _mapping.triggers)
	
	_undo_redo.commit_action()	
	

func _on_modifiers_clear_requested() -> void:
	_undo_redo.create_action("Clear modifiers")
	# if this is inlined into the do_property, then it doesn't work
	# so lets keep it a local variable
	var value:Array[GUIDEModifier] = []
	_undo_redo.add_do_property(_mapping, "modifiers", value)
	_undo_redo.add_undo_property(_mapping, "modifiers", _mapping.modifiers)
	
	_undo_redo.commit_action()	


func _on_triggers_clear_requested() -> void:
	_undo_redo.create_action("Clear triggers")
	# if this is inlined into the do_property, then it doesn't work
	# so lets keep it a local variable
	var value:Array[GUIDETrigger] = []
	_undo_redo.add_do_property(_mapping, "triggers", value)
	_undo_redo.add_undo_property(_mapping, "triggers", _mapping.triggers)
	
	_undo_redo.commit_action()	
	
	
func _on_modifiers_collapse_state_changed(new_state:bool):
	_mapping.set_meta("_guide_modifiers_collapsed", new_state)
	
func _on_triggers_collapse_state_changed(new_state:bool):
	_mapping.set_meta("_guide_triggers_collapsed", new_state)


func _on_edit_input_mapping_button_pressed():
	EditorInterface.edit_resource(_mapping)
