@tool

const SETTING_EDITOR_JOY_ICONS = "Guide/Editor/Joy Icons"
const SETTING_EDITOR_JOY_TYPE = "Guide/Editor/Joy Type"

static func initialize():
	if not ProjectSettings.has_setting(SETTING_EDITOR_JOY_ICONS):
		editor_joy_rendering = GUIDEInputFormattingOptions.JoyRendering.DEFAULT
	
	ProjectSettings.set_initial_value(SETTING_EDITOR_JOY_ICONS, 0)
	ProjectSettings.add_property_info({
		"name": SETTING_EDITOR_JOY_ICONS,
		"type": TYPE_INT,
		"hint": PROPERTY_HINT_ENUM,
		"hint_string": "Detect from device:0,Use fixed joy type:2",
		"description": "Controls, how the joy icons are displayed in the mapping context editor."
	})

	if not ProjectSettings.has_setting(SETTING_EDITOR_JOY_TYPE):
		editor_joy_type = GUIDEInputFormattingOptions.JoyType.GENERIC_JOY

	ProjectSettings.add_property_info({
		"name": SETTING_EDITOR_JOY_TYPE,
		"type": TYPE_INT,
		"hint": PROPERTY_HINT_ENUM,
		"hint_string": "Generic Joy:0,Microsoft Controller:1,Nintendo Controller:2,Sony Controller:3,Steam Deck Controller:4",
		"description": "When a fixed joy type is used for rendering in the editor, this selects the icon set that is used."
	})
	ProjectSettings.set_initial_value(SETTING_EDITOR_JOY_TYPE, 0)
	
	
	
static var editor_joy_rendering:GUIDEInputFormattingOptions.JoyRendering:
	set(value):
		ProjectSettings.set_setting(SETTING_EDITOR_JOY_ICONS, value)
	get:
		return ProjectSettings.get_setting(SETTING_EDITOR_JOY_ICONS, GUIDEInputFormattingOptions.JoyRendering.DEFAULT)
		
static var editor_joy_type:GUIDEInputFormattingOptions.JoyType:
	set(value):
		ProjectSettings.set_setting(SETTING_EDITOR_JOY_TYPE, value)
	get:
		return ProjectSettings.get_setting(SETTING_EDITOR_JOY_TYPE, GUIDEInputFormattingOptions.JoyType.GENERIC_JOY)
