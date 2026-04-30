using System;
using Godot;

namespace Guide;

[Tool]
public partial class ActionSlotLineEdit : LineEdit {
	[Signal] public delegate void ActionDroppedEventHandler(GUIDEAction action);

	public override bool _CanDropData(Vector2 atPosition, Variant data) {
		if (data.VariantType != Variant.Type.Dictionary) return false;
		var dict = data.AsGodotDictionary();

		if (dict.ContainsKey("files")) {
			var files = dict["files"].AsStringArray();
			foreach (var file in files) {
				if (ResourceLoader.Load(file) is GUIDEAction action) return true;
			}
		}
		return false;
	}

	public override void _DropData(Vector2 atPosition, Variant data) {
		var dict = data.AsGodotDictionary();
		var files = dict["files"].AsStringArray();
		foreach (var file in files) {
			if (ResourceLoader.Load(file) is GUIDEAction action) {
				EmitSignal(SignalName.ActionDropped, action);
				break;
			}
		}
	}
}
