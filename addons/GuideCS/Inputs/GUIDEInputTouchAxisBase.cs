using System;
using Godot;

namespace Guide;

[Tool]
[GlobalClass]
public partial class GUIDEInputTouchAxisBase : GUIDEInputTouchBase {
	protected Vector2 _lastPosition = Vector2.Inf;

	public override bool _NeedsReset() => true;

	public override void _Reset() {
		_lastPosition = _State.GetFingerPosition(FingerIndex, FingerCount);
		_ApplyValue(_CalculateValue(_lastPosition));
	}

	public override void _BeginUsage() {
		_State.TouchStateChanged += _Refresh;
		_Refresh();
	}

	public override void _EndUsage() {
		_State.TouchStateChanged -= _Refresh;
	}

	private void _Refresh() {
		Vector2 newPosition = _State.GetFingerPosition(FingerIndex, FingerCount);
		_ApplyValue(_CalculateValue(newPosition));
	}

	protected virtual void _ApplyValue(Vector2 value) { }

	protected Vector2 _CalculateValue(Vector2 newPosition) {
		if (!_lastPosition.IsFinite() || !newPosition.IsFinite()) return Vector2.Zero;

		return newPosition - _lastPosition;
	}

	public override bool IsSameAs(GUIDEInput other) {
		return other is GUIDEInputTouchAxisBase touchAxis &&
			   touchAxis.FingerCount == FingerCount &&
			   touchAxis.FingerIndex == FingerIndex;
	}
}
