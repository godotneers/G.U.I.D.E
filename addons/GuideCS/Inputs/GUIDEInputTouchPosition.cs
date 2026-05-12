using System;
using Godot;

namespace Guide;

[Tool]
[GlobalClass]
public partial class GUIDEInputTouchPosition : GUIDEInputTouchBase {
	public override void _BeginUsage() {
		_State.TouchStateChanged += _Refresh;
		_Refresh();
	}

	public override void _EndUsage() {
		_State.TouchStateChanged -= _Refresh;
	}

	private void _Refresh() {
		Vector2 position = _State.GetFingerPosition(FingerIndex, FingerCount);
		if (!position.IsFinite()) {
			_Value = Vector3.Inf;
			return;
		}

		_Value = new Vector3(position.X, position.Y, 0);
	}

	public override bool IsSameAs(GUIDEInput other) {
		return other is GUIDEInputTouchPosition touchPos &&
			   touchPos.FingerCount == FingerCount &&
			   touchPos.FingerIndex == FingerIndex;
	}

	public override string ToString() => $"(GUIDEInputTouchPosition finger_count={FingerCount} finger_index={FingerIndex})";

	public override string _EditorName() => "Touch Position";

	public override string _EditorDescription() => "Position of a touching finger.";

	public override GUIDEAction.GUIDEActionValueType _NativeValueType() => GUIDEAction.GUIDEActionValueType.Axis2D;
}
