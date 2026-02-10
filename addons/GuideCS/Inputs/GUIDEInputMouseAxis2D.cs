using System;
using Godot;

namespace Guide;

[Tool]
[GlobalClass]
public partial class GUIDEInputMouseAxis2D : GUIDEInput {
	public override bool _NeedsReset() => true;

	public override void _BeginUsage() {
		_State.MousePositionChanged += _Refresh;
		_Refresh();
	}

	public override void _EndUsage() {
		_State.MousePositionChanged -= _Refresh;
	}

	private void _Refresh() {
		Vector2 delta = _State.GetMouseDeltaSinceLastFrame();
		_Value = new Vector3(delta.X, delta.Y, 0);
	}

	public override bool IsSameAs(GUIDEInput other) {
		return other is GUIDEInputMouseAxis2D;
	}

	public override string ToString() => "(GUIDEInputMouseAxis2D)";

	public override string _EditorName() => "Mouse Axis 2D";

	public override string _EditorDescription() => "Relative mouse movement on 2 axes.";

	public override GUIDEAction.GUIDEActionValueType _NativeValueType() => GUIDEAction.GUIDEActionValueType.Axis2D;

	public override DeviceType _DeviceType() => DeviceType.Mouse;
}
