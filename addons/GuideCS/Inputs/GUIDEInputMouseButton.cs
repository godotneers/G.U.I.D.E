using System;
using Godot;

namespace Guide;

[Tool]
[GlobalClass]
public partial class GUIDEInputMouseButton : GUIDEInput {
	private MouseButton _button = MouseButton.Left;
	[Export]
	public MouseButton Button {
		get => _button;
		set {
			if (_button == value) return;
			_button = value;
			EmitChanged();
		}
	}

	private Vector3 _resetTo;
	private bool _wasPressedThisFrame;

	public override bool _NeedsReset() {
		return Button == MouseButton.WheelUp || Button == MouseButton.WheelDown;
	}

	public override void _Reset() {
		_wasPressedThisFrame = false;
		_Value = _resetTo;
	}

	public override void _BeginUsage() {
		_State.MouseButtonStateChanged += _Refresh;
		_Refresh();
	}

	public override void _EndUsage() {
		_State.MouseButtonStateChanged -= _Refresh;
	}

	private void _Refresh() {
		bool isPressed = _State.IsMouseButtonPressed(Button);

		if (_NeedsReset()) {
			_resetTo = new Vector3(isPressed ? 1.0f : 0.0f, 0, 0);

			if (isPressed) _wasPressedThisFrame = true;

			if (!isPressed && _wasPressedThisFrame) return;
		}

		_Value = new Vector3(isPressed ? 1.0f : 0.0f, 0, 0);
	}

	public override bool IsSameAs(GUIDEInput other) {
		return other is GUIDEInputMouseButton mouseButton && mouseButton.Button == Button;
	}

	public override string ToString() => $"(GUIDEInputMouseButton: button={Button})";

	public override string _EditorName() => "Mouse Button";

	public override string _EditorDescription() => "A press of a mouse button. The mouse wheel is also a button.";

	public override GUIDEAction.GUIDEActionValueType _NativeValueType() => GUIDEAction.GUIDEActionValueType.Bool;

	public override DeviceType _DeviceType() => DeviceType.Mouse;
}
