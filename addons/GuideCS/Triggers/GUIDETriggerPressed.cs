using System;
using Godot;

namespace Guide;

[Tool]
[GlobalClass]
public partial class GUIDETriggerPressed : GUIDETrigger {
	public override bool IsSameAs(GUIDETrigger other) => other is GUIDETriggerPressed;

	public override GUIDETriggerState _UpdateState(Vector3 input, float delta, GUIDEAction.GUIDEActionValueType valueType) {
		if (_IsActuated(input, valueType)) {
			if (!_IsActuated(_LastValue, valueType)) return GUIDETriggerState.Triggered;
		}
		return GUIDETriggerState.None;
	}

	public override string _EditorName() => "Pressed";

	public override string _EditorDescription() => "Fires once, when the input exceeds actuation threshold. Holding the input\nwill not fire additional triggers.";
}
