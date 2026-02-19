using System;
using Godot;

namespace Guide;

[Tool]
public partial class GUIDEProjectSettings : RefCounted {
	public const string SettingEditorJoyIcons = "Guide/Editor/Joy Icons";
	public const string SettingEditorJoyType = "Guide/Editor/Joy Type";

	public static void Initialize() {
		if (!ProjectSettings.HasSetting(SettingEditorJoyIcons)) {
			EditorJoyRendering = GUIDEInputFormattingOptions.JoyRendering.Default;
		}

		ProjectSettings.SetInitialValue(SettingEditorJoyIcons, 0);
		ProjectSettings.AddPropertyInfo(new Godot.Collections.Dictionary
		{
			{ "name", SettingEditorJoyIcons },
			{ "type", (int)Variant.Type.Int },
			{ "hint", (int)PropertyHint.Enum },
			{ "hint_string", "Detect from device:0,Use fixed joy type:2" },
			{ "description", "Controls, how the joy icons are displayed in the mapping context editor." }
		});

		if (!ProjectSettings.HasSetting(SettingEditorJoyType)) {
			EditorJoyType = GUIDEInputFormattingOptions.JoyType.GenericJoy;
		}

		ProjectSettings.AddPropertyInfo(new Godot.Collections.Dictionary
		{
			{ "name", SettingEditorJoyType },
			{ "type", (int)Variant.Type.Int },
			{ "hint", (int)PropertyHint.Enum },
			{ "hint_string", "Generic Joy:0,Microsoft Controller:1,Nintendo Controller:2,Sony Controller:3" },
			{ "description", "When a fixed joy type is used for rendering in the editor, this selects the icon set that is used." }
		});
		ProjectSettings.SetInitialValue(SettingEditorJoyType, 0);
	}

	public static GUIDEInputFormattingOptions.JoyRendering EditorJoyRendering {
		get => (GUIDEInputFormattingOptions.JoyRendering)ProjectSettings.GetSetting(SettingEditorJoyIcons, (int)GUIDEInputFormattingOptions.JoyRendering.Default).AsInt32();
		set => ProjectSettings.SetSetting(SettingEditorJoyIcons, (int)value);
	}

	public static GUIDEInputFormattingOptions.JoyType EditorJoyType {
		get => (GUIDEInputFormattingOptions.JoyType)ProjectSettings.GetSetting(SettingEditorJoyType, (int)GUIDEInputFormattingOptions.JoyType.GenericJoy).AsInt32();
		set => ProjectSettings.SetSetting(SettingEditorJoyType, (int)value);
	}
}
