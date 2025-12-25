using System;
using Godot;

namespace Guide;

[Tool]
[GlobalClass]
public partial class GUIDEModifierMapRange : GUIDEModifier {
	[Export] public bool ApplyClamp { get; set; } = true;
	[Export] public float InputMin { get; set; } = 0.0f;
	[Export] public float InputMax { get; set; } = 1.0f;
	[Export] public float OutputMin { get; set; } = 0.0f;
	[Export] public float OutputMax { get; set; } = 1.0f;
	[Export] public bool X { get; set; } = true;
	[Export] public bool Y { get; set; } = true;
	[Export] public bool Z { get; set; } = true;

	private float _omin;
	private float _omax;

	public override bool IsSameAs(GUIDEModifier other) {
		return other is GUIDEModifierMapRange otherMap &&
			   ApplyClamp == otherMap.ApplyClamp &&
			   X == otherMap.X &&
			   Y == otherMap.Y &&
			   Z == otherMap.Z &&
			   Mathf.IsEqualApprox(InputMin, otherMap.InputMin) &&
			   Mathf.IsEqualApprox(InputMax, otherMap.InputMax) &&
			   Mathf.IsEqualApprox(OutputMin, otherMap.OutputMin) &&
			   Mathf.IsEqualApprox(OutputMax, otherMap.OutputMax);
	}

	public override void _BeginUsage() {
		_omin = Math.Min(OutputMin, OutputMax);
		_omax = Math.Max(OutputMin, OutputMax);
	}

	public override Vector3 _ModifyInput(Vector3 input, float delta, GUIDEAction.GUIDEActionValueType valueType) {
		if (!input.IsFinite()) return Vector3.Inf;

		float xValue = Mathf.Remap(input.X, InputMin, InputMax, OutputMin, OutputMax);
		float yValue = Mathf.Remap(input.Y, InputMin, InputMax, OutputMin, OutputMax);
		float zValue = Mathf.Remap(input.Z, InputMin, InputMax, OutputMin, OutputMax);

		if (ApplyClamp) {
			xValue = Mathf.Clamp(xValue, _omin, _omax);
			yValue = Mathf.Clamp(yValue, _omin, _omax);
			zValue = Mathf.Clamp(zValue, _omin, _omax);
		}

		return new Vector3(
			X ? xValue : input.X,
			Y ? yValue : input.Y,
			Z ? zValue : input.Z
		);
	}

	public override string _EditorName() => "Map Range";

	public override string _EditorDescription() => "Maps an input range to an output range and optionally clamps the output";
}
