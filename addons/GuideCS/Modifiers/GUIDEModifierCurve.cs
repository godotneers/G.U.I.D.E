using Godot;

namespace Guide;

[Tool]
[GlobalClass]
public partial class GUIDEModifierCurve : GUIDEModifier {
	[Export] public Curve Curve { get; set; } = DefaultCurve();
	[Export] public bool X { get; set; } = true;
	[Export] public bool Y { get; set; } = true;
	[Export] public bool Z { get; set; } = true;

	public static Curve DefaultCurve() {
		var curve = new Curve();
		curve.AddPoint(new Vector2(0.0f, 0.0f));
		curve.AddPoint(new Vector2(1.0f, 1.0f));
		return curve;
	}

	public override bool IsSameAs(GUIDEModifier other) {
		return other is GUIDEModifierCurve otherCurve &&
			   Curve == otherCurve.Curve &&
			   X == otherCurve.X &&
			   Y == otherCurve.Y &&
			   Z == otherCurve.Z;
	}

	public override Vector3 _ModifyInput(Vector3 input, float delta, GUIDEAction.GUIDEActionValueType valueType) {
		if (Curve == null) {
			GD.PushError("No curve added to Curve modifier.");
			return input;
		}

		if (!input.IsFinite()) return Vector3.Inf;

		return new Vector3(
			X ? Curve.Sample(input.X) : input.X,
			Y ? Curve.Sample(input.Y) : input.Y,
			Z ? Curve.Sample(input.Z) : input.Z
		);
	}

	public override string _EditorName() => "Curve";

	public override string _EditorDescription() => "Applies a curve to each input axis.";
}
