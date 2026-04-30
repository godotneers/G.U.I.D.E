using Godot;

namespace Guide;

[Tool]
[GlobalClass]
public partial class GUIDEInputJoyAxis1D : GUIDEInputJoyBase {
	private JoyAxis _axis = JoyAxis.LeftX;
	[Export]
	public JoyAxis Axis {
		get => _axis;
		set {
			if (_axis == value) return;
			_axis = value;
			EmitChanged();
		}
	}

	public override void _BeginUsage() {
		_State.JoyAxisStateChanged += _Refresh;
	}

	public override void _EndUsage() {
		_State.JoyAxisStateChanged -= _Refresh;
	}

	private void _Refresh() {
		_Value = new Vector3(_State.GetJoyAxisValue(JoyIndex, Axis), 0, 0);
	}

	public override bool IsSameAs(GUIDEInput other) {
		return other is GUIDEInputJoyAxis1D joyAxis &&
			   joyAxis.Axis == Axis &&
			   joyAxis.JoyIndex == JoyIndex;
	}

	public override string ToString() => $"(GUIDEInputJoyAxis1D: axis={Axis}, joy_index={JoyIndex})";

	public override string _EditorName() => "Joy Axis 1D";

	public override string _EditorDescription() => "The input from a single joy axis.";

	public override GUIDEAction.GUIDEActionValueType _NativeValueType() => GUIDEAction.GUIDEActionValueType.Axis1D;
}
