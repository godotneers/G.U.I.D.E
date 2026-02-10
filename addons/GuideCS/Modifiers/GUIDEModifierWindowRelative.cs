using System;
using Godot;

namespace Guide;

[Tool]
[GlobalClass]
public partial class GUIDEModifierWindowRelative : GUIDEModifier {
	public override bool IsSameAs(GUIDEModifier other) => other is GUIDEModifierWindowRelative;

	public override Vector3 _ModifyInput(Vector3 input, float delta, GUIDEAction.GUIDEActionValueType valueType) {
		if (!input.IsFinite()) return Vector3.Inf;

		if (Engine.GetMainLoop() is not SceneTree tree) return Vector3.Inf;
		var window = tree.Root;
		var windowSize = window.GetScreenTransform().AffineInverse() * window.Size;
		return new Vector3(input.X / windowSize.X, input.Y / windowSize.Y, input.Z);
	}

	public override string _EditorName() => "Window relative";

	public override string _EditorDescription() => "Converts the value of the input into window-relative units between 0 and 1.\nE.g. if a mouse cursor moves half a screen to the right and down, then \nthis modifier will return (0.5, 0.5).";
}
