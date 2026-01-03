@tool
extends EditorPlugin

const GUIDEProjectSettings = preload("plugin/editor/guide_project_settings.gd")
const MainPanel:PackedScene = preload("plugin/editor/mapping_context_editor/mapping_context_editor.tscn")

var _main_panel:Control


func _enable_plugin() -> void:
	add_autoload_singleton("GUIDE", "plugin/guide.gd")
	
func _enter_tree() -> void:
	_main_panel = MainPanel.instantiate()
	_main_panel.initialize(self)
	EditorInterface.get_editor_main_screen().add_child(_main_panel)
	GUIDEProjectSettings.initialize()
	# Hide the main panel. Very much required.
	_make_visible(false)

func _exit_tree() -> void:
	if is_instance_valid(_main_panel):
		_main_panel.queue_free()
	GUIDEInputFormatter.cleanup()

func _disable_plugin() -> void:
	remove_autoload_singleton("GUIDE")
	

func _edit(object) -> void:
	if object is GUIDEMappingContext:
		_main_panel.edit(object)

func _get_plugin_name() -> String:
	return "G.U.I.D.E"

func _get_plugin_icon() -> Texture2D:
	return preload("plugin/editor/logo_editor_small.svg")

func _has_main_screen() -> bool:
	return true

func _handles(object:Variant) -> bool:
	return object is GUIDEMappingContext

func _make_visible(visible) -> void:
	if is_instance_valid(_main_panel):
		_main_panel.visible = visible
