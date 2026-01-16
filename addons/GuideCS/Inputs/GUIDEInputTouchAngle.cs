using System;
using Godot;

namespace Guide;

[Tool]
[GlobalClass]
public partial class GUIDEInputTouchAngle : GUIDEInput {
	public enum AngleUnit {
		Radians = 0,
		Degrees = 1
	}

	[Export]
	public AngleUnit Unit { get; set; } = AngleUnit.Radians;

	private float _initialAngle = float.PositiveInfinity;

	public override bool _NeedsReset() => true;

	public override void _Reset() {
		float angle = _CalculateAngle();
		if (float.IsFinite(_initialAngle) != float.IsFinite(angle)) {
			_initialAngle = angle;
		}
	}

	public override void _BeginUsage() {
		_State.TouchStateChanged += _Refresh;
		_Refresh();
	}

	public override void _EndUsage() {
		_State.TouchStateChanged -= _Refresh;
	}

	private void _Refresh() {
		float angle = _CalculateAngle();
		if (!float.IsFinite(angle) || !float.IsFinite(_initialAngle)) {
			_Value = Vector3.Zero;
			return;
		}

		float finalAngle = angle - _initialAngle;
		if (Unit == AngleUnit.Degrees) {
			finalAngle = Mathf.RadToDeg(finalAngle);
		}

		_Value = new Vector3(finalAngle, 0, 0);
	}

	private float _CalculateAngle() {
		Vector2 pos1 = _State.GetFingerPosition(0, 2);
		if (!float.IsFinite(pos1.X)) return float.PositiveInfinity;

		Vector2 pos2 = _State.GetFingerPosition(1, 2);
		if (!float.IsFinite(pos2.X)) return float.PositiveInfinity;

		return -pos1.AngleToPoint(pos2);
	}

	public override bool IsSameAs(GUIDEInput other) {
		return other is GUIDEInputTouchAngle touchAngle && touchAngle.Unit == Unit;
	}

	public override string ToString() => $"(GUIDEInputTouchAngle unit={(Unit == AngleUnit.Radians ? "radians" : "degrees")})";

	public override string _EditorName() => "Touch Angle";

	public override string _EditorDescription() => "Angle changes of two touching fingers.";

	public override GUIDEAction.GUIDEActionValueType _NativeValueType() => GUIDEAction.GUIDEActionValueType.Axis1D;

	public override DeviceType _DeviceType() => DeviceType.Touch;
}
