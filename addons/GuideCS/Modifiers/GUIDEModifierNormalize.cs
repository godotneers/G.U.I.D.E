using System;
using Godot;

namespace Guide;

[Tool]
[GlobalClass]
public partial class GUIDEModifierNormalize : GUIDEModifier {
	public override bool IsSameAs(GUIDEModifier other) => other is GUIDEModifierNormalize;

	public override Vector3 _ModifyInput(Vector3 input, float delta, GUIDEAction.GUIDEActionValueType valueType) {
		if (!input.IsFinite()) return Vector3.Inf;
		return input.Normalized();
	}

	public override string _EditorName() => "Normalize";

	public override string _EditorDescription() => "Normalizes the input vector.";
}
