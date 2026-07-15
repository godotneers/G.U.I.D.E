using System;
using Godot;

namespace Guide;

[Tool]
[GlobalClass]
public partial class GUIDEInputMouseAxis1D : GUIDEInput {
	public enum GuideInputMouseAxis {
		X,
		Y
	}

	private GuideInputMouseAxis _axis;
	[Export]
	public GuideInputMouseAxis Axis {
		get => _axis;
		set {
			if (_axis == value) return;
			_axis = value;
			EmitChanged();
		}
	}

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
		switch (Axis) {
			case GuideInputMouseAxis.X:
				_Value = new Vector3(delta.X, 0, 0);
				break;
			case GuideInputMouseAxis.Y:
				_Value = new Vector3(delta.Y, 0, 0);
				break;
		}
	}

	public override bool IsSameAs(GUIDEInput other) {
		return other is GUIDEInputMouseAxis1D mouseAxis && mouseAxis.Axis == Axis;
	}

	public override string ToString() => $"(GuideInputMouseAxis1D: axis={Axis})";

	public override string _EditorName() => "Mouse Axis 1D";

	public override string _EditorDescription() => "Relative mouse movement on a single axis.";

	public override GUIDEAction.GUIDEActionValueType _NativeValueType() => GUIDEAction.GUIDEActionValueType.Axis1D;

	public override DeviceType _DeviceType() => DeviceType.Mouse;
}
