using Godot;

namespace Guide;

// [Tool] //not htere in original gd script
[GlobalClass]
public partial class GUIDEInputJoyAxis2D : GUIDEInputJoyBase {
	private JoyAxis _x = JoyAxis.LeftX;
	[Export]
	public JoyAxis X {
		get => _x;
		set {
			if (_x == value) return;
			_x = value;
			EmitChanged();
		}
	}

	private JoyAxis _y = JoyAxis.LeftY;
	[Export]
	public JoyAxis Y {
		get => _y;
		set {
			if (_y == value) return;
			_y = value;
			EmitChanged();
		}
	}

	public override void _BeginUsage() {
		_State.JoyAxisStateChanged += _Refresh;
		_Refresh();
	}

	public override void _EndUsage() {
		_State.JoyAxisStateChanged -= _Refresh;
	}

	private void _Refresh() {
		_Value = new Vector3(_State.GetJoyAxisValue(JoyIndex, X), _State.GetJoyAxisValue(JoyIndex, Y), 0);
	}

	public override bool IsSameAs(GUIDEInput other) {
		return other is GUIDEInputJoyAxis2D joyAxis &&
			   joyAxis.X == X &&
			   joyAxis.Y == Y &&
			   joyAxis.JoyIndex == JoyIndex;
	}

	public override string ToString() => $"(GUIDEInputJoyAxis2D: x={X}, y={Y}, joy_index={JoyIndex})";

	public override string _EditorName() => "Joy Axis 2D";

	public override string _EditorDescription() => "The input from two Joy axes. Usually from a stick.";

	public override GUIDEAction.GUIDEActionValueType _NativeValueType() => GUIDEAction.GUIDEActionValueType.Axis2D;
}
