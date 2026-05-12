using System;
using Godot;

namespace Guide;

[Tool]
[GlobalClass]
public partial class GUIDETriggerDown : GUIDETrigger {
	public override bool IsSameAs(GUIDETrigger other) {
		return other is GUIDETriggerDown;
	}

	public override GUIDETriggerState _UpdateState(Vector3 input, float delta, GUIDEAction.GUIDEActionValueType valueType) {
		if (_IsActuated(input, valueType)) {
			return GUIDETriggerState.Triggered;
		}
		return GUIDETriggerState.None;
	}

	public override string _EditorName() => "Down";

	public override string _EditorDescription() => "Fires, when the input exceeds the actuation threshold. This is\nthe default trigger when no trigger is specified.";
}
