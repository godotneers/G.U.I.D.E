using System;
using System.Collections.Generic;
using Godot;

namespace Guide;

public partial class DefaultTextProvider : GUIDETextProvider {
	private bool _isOnDesktop = false;

	public DefaultTextProvider() {
		Priority = 0;
		_isOnDesktop = OS.HasFeature("linuxbsd") || OS.HasFeature("macos") || OS.HasFeature("windows");
	}

	public override bool Supports(GUIDEInput input, GUIDEInputFormattingOptions options) => true;

	private string _Format(string input) => $"[{input}]";

	public override string GetText(GUIDEInput input, GUIDEInputFormattingOptions options) {
		if (input is GUIDEInputKey keyInput) {
			var theKey = keyInput.Key;
			if (_isOnDesktop) {
				theKey = DisplayServer.KeyboardGetLabelFromPhysical(keyInput.Key);
			}
			return _Format(OS.GetKeycodeString(theKey));
		}

		if (input is GUIDEInputMouseAxis1D mouseAxis1D) {
			return mouseAxis1D.Axis switch {
				GUIDEInputMouseAxis1D.GuideInputMouseAxis.X => _Format(TranslationServer.Translate("Mouse Left/Right")),
				GUIDEInputMouseAxis1D.GuideInputMouseAxis.Y => _Format(TranslationServer.Translate("Mouse Up/Down")),
				_ => _Format("??")
			};
		}

		if (input is GUIDEInputMouseAxis2D) return _Format(TranslationServer.Translate("Mouse"));

		if (input is GUIDEInputMouseButton mouseBtn) {
			return mouseBtn.Button switch {
				MouseButton.Left => _Format(TranslationServer.Translate("Left Mouse Button")),
				MouseButton.Right => _Format(TranslationServer.Translate("Right Mouse Button")),
				MouseButton.Middle => _Format(TranslationServer.Translate("Middle Mouse Button")),
				MouseButton.WheelUp => _Format(TranslationServer.Translate("Mouse Wheel Up")),
				MouseButton.WheelDown => _Format(TranslationServer.Translate("Mouse Wheel Down")),
				MouseButton.WheelLeft => _Format(TranslationServer.Translate("Mouse Wheel Left")),
				MouseButton.WheelRight => _Format(TranslationServer.Translate("Mouse Wheel Right")),
				MouseButton.Xbutton1 => _Format(TranslationServer.Translate("Mouse Side 1")),
				MouseButton.Xbutton2 => _Format(TranslationServer.Translate("Mouse Side 2")),
				_ => _Format("??")
			};
		}

		if (input is GUIDEInputJoyAxis1D joyAxis1D) {
			return joyAxis1D.Axis switch {
				JoyAxis.LeftX => _Format(TranslationServer.Translate("Stick 1 Horizontal")),
				JoyAxis.LeftY => _Format(TranslationServer.Translate("Stick 1 Vertical")),
				JoyAxis.RightX => _Format(TranslationServer.Translate("Stick 2 Horizontal")),
				JoyAxis.RightY => _Format(TranslationServer.Translate("Stick 2 Vertical")),
				JoyAxis.TriggerLeft => _Format(TranslationServer.Translate("Axis 3")),
				JoyAxis.TriggerRight => _Format(TranslationServer.Translate("Axis 4")),
				_ => _Format("??")
			};
		}

		if (input is GUIDEInputJoyAxis2D joyAxis2D) {
			return joyAxis2D.X switch {
				JoyAxis.LeftX or JoyAxis.LeftY => _Format(TranslationServer.Translate("Stick 1")),
				JoyAxis.RightX or JoyAxis.RightY => _Format(TranslationServer.Translate("Stick 2")),
				_ => _Format("??")
			};
		}

		if (input is GUIDEInputJoyButton joyBtn) return _Format(string.Format(TranslationServer.Translate("Joy {0}"), joyBtn.Button));

		if (input is GUIDEInputAction actionInput) return _Format(string.Format(TranslationServer.Translate("Action {0}"), actionInput.Action == null ? "?" : actionInput.Action.EditorName()));

		if (input is GUIDEInputAny anyInput) {
			var parts = new List<string>();
			if (anyInput.JoyButtons) parts.Add(TranslationServer.Translate("Joy Button"));
			if (anyInput.MouseButtons) parts.Add(TranslationServer.Translate("Mouse Button"));
			if (anyInput.Keyboard) parts.Add(TranslationServer.Translate("Key"));
			return _Format(string.Format(TranslationServer.Translate("Any {0}"), string.Join("/", parts)));
		}

		if (input is GUIDEInputMousePosition) return _Format(TranslationServer.Translate("Mouse Position"));

		if (input is GUIDEInputTouchPosition touchPos) return _Format(string.Format(TranslationServer.Translate("Touch Position {0}"), touchPos.FingerIndex >= 0 ? touchPos.FingerIndex.ToString() : "Average"));

		if (input is GUIDEInputTouchAngle) return _Format(TranslationServer.Translate("Touch Angle"));

		if (input is GUIDEInputTouchDistance) return _Format(TranslationServer.Translate("Touch Distance"));

		if (input is GUIDEInputTouchAxis1D touchAxis1D) {
			return touchAxis1D.Axis switch {
				GUIDEInputTouchAxis1D.GUIDEInputTouchAxis.X => _Format(string.Format(TranslationServer.Translate("Touch Left/Right {0}"), touchAxis1D.FingerIndex >= 0 ? touchAxis1D.FingerIndex.ToString() : "Average")),
				GUIDEInputTouchAxis1D.GUIDEInputTouchAxis.Y => _Format(string.Format(TranslationServer.Translate("Touch Up/Down {0}"), touchAxis1D.FingerIndex >= 0 ? touchAxis1D.FingerIndex.ToString() : "Average")),
				_ => _Format("??")
			};
		}

		if (input is GUIDEInputTouchAxis2D touchAxis2D) return _Format(string.Format(TranslationServer.Translate("Touch Axis 2D {0}"), touchAxis2D.FingerIndex >= 0 ? touchAxis2D.FingerIndex.ToString() : "Average"));

		return _Format("??");
	}
}
