using System;
using Godot;

namespace Guide;

[Tool]
[GlobalClass]
public partial class GUIDEInputJoyButton : GUIDEInputJoyBase {
	private JoyButton _button = JoyButton.A;
	[Export]
	public JoyButton Button {
		get => _button;
		set {
			if (_button == value) return;
			_button = value;
			EmitChanged();
		}
	}

	public override void _BeginUsage() {
		_State.JoyButtonStateChanged += _Refresh;
		_Refresh();
	}

	public override void _EndUsage() {
		_State.JoyButtonStateChanged -= _Refresh;
	}

	private void _Refresh() {
		_Value = new Vector3(_State.IsJoyButtonPressed(JoyIndex, Button) ? 1.0f : 0.0f, 0, 0);
	}

	public override bool IsSameAs(GUIDEInput other) {
		return other is GUIDEInputJoyButton joyButton &&
			   joyButton.Button == Button &&
			   joyButton.JoyIndex == JoyIndex;
	}

	public override string ToString() => $"(GUIDEInputJoyButton: button={Button}, joy_index={JoyIndex})";

	public override string _EditorName() => "Joy Button";

	public override string _EditorDescription() => "A button press from a joy button.";

	public override GUIDEAction.GUIDEActionValueType _NativeValueType() => GUIDEAction.GUIDEActionValueType.Bool;
}
