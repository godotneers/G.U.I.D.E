using System;
using Godot;

namespace Guide;

[Tool]
[GlobalClass]
public partial class GUIDEInputMousePosition : GUIDEInput {
	public override void _BeginUsage() {
		_State.MousePositionChanged += _Refresh;
		_Refresh();
	}

	public override void _EndUsage() {
		_State.MousePositionChanged -= _Refresh;
	}

	private void _Refresh() {
		Vector2 position = _State.GetMousePosition();
		_Value = new Vector3(position.X, position.Y, 0);
	}

	public override bool IsSameAs(GUIDEInput other) {
		return other is GUIDEInputMousePosition;
	}

	public override string ToString() => "(GUIDEInputMousePosition)";

	public override string _EditorName() => "Mouse Position";

	public override string _EditorDescription() => "Position of the mouse in the main viewport.";

	public override GUIDEAction.GUIDEActionValueType _NativeValueType() => GUIDEAction.GUIDEActionValueType.Axis2D;

	public override DeviceType _DeviceType() => DeviceType.Mouse;
}
