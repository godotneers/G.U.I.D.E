using System;
using Godot;

namespace Guide;

[Tool]
[GlobalClass]
public partial class GUIDEInputTouchAxis1D : GUIDEInputTouchAxisBase {
	public enum GUIDEInputTouchAxis {
		X,
		Y
	}

	private GUIDEInputTouchAxis _axis;
	[Export]
	public GUIDEInputTouchAxis Axis {
		get => _axis;
		set {
			if (_axis == value) return;
			_axis = value;
			EmitChanged();
		}
	}

	public override bool IsSameAs(GUIDEInput other) {
		return other is GUIDEInputTouchAxis1D touchAxis &&
			   base.IsSameAs(other) &&
			   touchAxis.Axis == Axis;
	}

	protected override void _ApplyValue(Vector2 value) {
		switch (Axis) {
			case GUIDEInputTouchAxis.X:
				_Value = new Vector3(value.X, 0, 0);
				break;
			case GUIDEInputTouchAxis.Y:
				_Value = new Vector3(0, value.Y, 0);
				break;
		}
	}

	public override string ToString() => $"(GUIDEInputTouchAxis1D finger_count={FingerCount} finger_index={FingerIndex} axis={Axis})";

	public override string _EditorName() => "Touch Axis1D";

	public override string _EditorDescription() => "Relative movement of a touching finger on a single axis.";

	public override GUIDEAction.GUIDEActionValueType _NativeValueType() => GUIDEAction.GUIDEActionValueType.Axis1D;
}
