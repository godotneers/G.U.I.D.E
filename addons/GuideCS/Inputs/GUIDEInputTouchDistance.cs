using System;
using Godot;

namespace Guide;

[Tool]
[GlobalClass]
public partial class GUIDEInputTouchDistance : GUIDEInput {
	private float _initialDistance = float.PositiveInfinity;

	public override bool _NeedsReset() => true;

	public override void _Reset() {
		float distance = _CalculateDistance();
		if (float.IsFinite(_initialDistance) != float.IsFinite(distance)) {
			_initialDistance = distance;
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
		float distance = _CalculateDistance();
		if (!float.IsFinite(distance) || !float.IsFinite(_initialDistance)) {
			_Value = Vector3.Zero;
			return;
		}

		_Value = new Vector3(distance / _initialDistance, 0, 0);
	}

	private float _CalculateDistance() {
		Vector2 pos1 = _State.GetFingerPosition(0, 2);
		if (!pos1.IsFinite()) return float.PositiveInfinity;

		Vector2 pos2 = _State.GetFingerPosition(1, 2);
		if (!pos2.IsFinite()) return float.PositiveInfinity;

		return pos1.DistanceTo(pos2);
	}

	public override bool IsSameAs(GUIDEInput other) {
		return other is GUIDEInputTouchDistance;
	}

	public override string ToString() => "(GUIDEInputTouchDistance)";

	public override string _EditorName() => "Touch Distance";

	public override string _EditorDescription() => "Distance of two touching fingers.";

	public override GUIDEAction.GUIDEActionValueType _NativeValueType() => GUIDEAction.GUIDEActionValueType.Axis1D;

	public override DeviceType _DeviceType() => DeviceType.Touch;
}
