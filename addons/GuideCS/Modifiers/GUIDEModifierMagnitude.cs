using System;
using Godot;

namespace Guide;

[Tool]
[GlobalClass]
public partial class GUIDEModifierMagnitude : GUIDEModifier {
	public override bool IsSameAs(GUIDEModifier other) => other is GUIDEModifierMagnitude;

	public override Vector3 _ModifyInput(Vector3 input, float delta, GUIDEAction.GUIDEActionValueType valueType) {
		if (!input.IsFinite()) return Vector3.Inf;
		return new Vector3(input.Length(), 0, 0);
	}

	public override string _EditorName() => "Magnitude";

	public override string _EditorDescription() => "Returns the magnitude of the input vector.";
}
