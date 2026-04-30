using System;
using System.Collections.Generic;
using Godot;

namespace Guide;

[Tool]
public partial class GUIDEControllerTextProvider : GUIDETextProvider {
	private static readonly Dictionary<GUIDEFormattingUtils.ControllerType, GuideControllerLabelSet> _controllerLabelSets = new() {
		{ GUIDEFormattingUtils.ControllerType.Microsoft, GD.Load<GuideControllerLabelSet>("res://addons/GuideCS/UI/TextProviders/Controllers/LabelSets/Microsoft.tres") },
		{ GUIDEFormattingUtils.ControllerType.Nintendo, GD.Load<GuideControllerLabelSet>("res://addons/GuideCS/UI/TextProviders/Controllers/LabelSets/Nintendo.tres") },
		{ GUIDEFormattingUtils.ControllerType.Sony, GD.Load<GuideControllerLabelSet>("res://addons/GuideCS/UI/TextProviders/Controllers/LabelSets/Sony.tres") },
	};

	public GUIDEControllerTextProvider() {
		Priority = -10;
	}

	public static void SetLabelSet(GUIDEFormattingUtils.ControllerType type, GuideControllerLabelSet labelSet) {
		if (!IsInstanceValid(labelSet)) {
			GD.PushError("Label set must not be null.");
			return;
		}

		if (type == GUIDEFormattingUtils.ControllerType.Unknown) {
			GD.PushError("Cannot set label set for the unknown controller. Use GuideInputFormattingOptions to set up how unknown controllers are rendered.");
			return;
		}

		_controllerLabelSets[type] = labelSet;
	}

	public override bool Supports(GUIDEInput input, GUIDEInputFormattingOptions options) {
		return GUIDEFormattingUtils.EffectiveControllerType(input, options) != GUIDEFormattingUtils.ControllerType.Unknown;
	}

	private string _Format(string input) => $"[{input}]";

	public override string GetText(GUIDEInput input, GUIDEInputFormattingOptions options) {
		var controllerType = GUIDEFormattingUtils.EffectiveControllerType(input, options);
		var labelSet = _controllerLabelSets[controllerType];

		if (input is GUIDEInputJoyAxis1D axis1D) {
			return axis1D.Axis switch {
				JoyAxis.LeftX => _Format(TranslationServer.Translate(labelSet.left_stick_horizontal_movement)),
				JoyAxis.LeftY => _Format(TranslationServer.Translate(labelSet.left_stick_vertical_movement)),
				JoyAxis.RightX => _Format(TranslationServer.Translate(labelSet.right_stick_horizontal_movement)),
				JoyAxis.RightY => _Format(TranslationServer.Translate(labelSet.right_stick_vertical_movement)),
				JoyAxis.TriggerLeft => _Format(TranslationServer.Translate(labelSet.left_trigger)),
				JoyAxis.TriggerRight => _Format(TranslationServer.Translate(labelSet.right_trigger)),
				_ => _Format("??")
			};
		}

		if (input is GUIDEInputJoyAxis2D axis2D) {
			return axis2D.X switch {
				JoyAxis.LeftX or JoyAxis.LeftY => _Format(TranslationServer.Translate(labelSet.left_stick)),
				JoyAxis.RightX or JoyAxis.RightY => _Format(TranslationServer.Translate(labelSet.right_stick)),
				_ => _Format("??")
			};
		}

		if (input is GUIDEInputJoyButton joyBtn) {
			return joyBtn.Button switch {
				JoyButton.A => _Format(TranslationServer.Translate(labelSet.a_button)),
				JoyButton.B => _Format(TranslationServer.Translate(labelSet.b_button)),
				JoyButton.X => _Format(TranslationServer.Translate(labelSet.x_button)),
				JoyButton.Y => _Format(TranslationServer.Translate(labelSet.y_button)),
				JoyButton.DpadLeft => _Format(TranslationServer.Translate(labelSet.dpad_left)),
				JoyButton.DpadRight => _Format(TranslationServer.Translate(labelSet.dpad_right)),
				JoyButton.DpadUp => _Format(TranslationServer.Translate(labelSet.dpad_up)),
				JoyButton.DpadDown => _Format(TranslationServer.Translate(labelSet.dpad_down)),
				JoyButton.LeftShoulder => _Format(TranslationServer.Translate(labelSet.left_bumper)),
				JoyButton.RightShoulder => _Format(TranslationServer.Translate(labelSet.right_bumper)),
				JoyButton.LeftStick => _Format(TranslationServer.Translate(labelSet.left_stick_click)),
				JoyButton.RightStick => _Format(TranslationServer.Translate(labelSet.right_stick_click)),
				JoyButton.Back => _Format(TranslationServer.Translate(labelSet.back)),
				JoyButton.Misc1 => _Format(TranslationServer.Translate(labelSet.misc1)),
				JoyButton.Start => _Format(TranslationServer.Translate(labelSet.start)),
				JoyButton.Touchpad => _Format(TranslationServer.Translate(labelSet.touch_pad)),
				_ => _Format("??")
			};
		}

		return _Format("??");
	}
}
