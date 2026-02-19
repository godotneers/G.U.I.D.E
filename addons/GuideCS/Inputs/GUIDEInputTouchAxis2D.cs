using System;
using Godot;

namespace Guide;

[Tool]
[GlobalClass]
public partial class GUIDEInputTouchAxis2D : GUIDEInputTouchAxisBase {
	protected override void _ApplyValue(Vector2 value) {
		_Value = new Vector3(value.X, value.Y, 0);
	}

	public override bool IsSameAs(GUIDEInput other) {
		return other is GUIDEInputTouchAxis2D && base.IsSameAs(other);
	}

	public override string ToString() => $"(GUIDEInputTouchAxis2D finger_count={FingerCount} finger_index={FingerIndex})";

	public override string _EditorName() => "Touch Axis2D";

	public override string _EditorDescription() => "2D relative movement of a touching finger.";

	public override GUIDEAction.GUIDEActionValueType _NativeValueType() => GUIDEAction.GUIDEActionValueType.Axis2D;
}
