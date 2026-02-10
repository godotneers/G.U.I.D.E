using System;
using System.Collections.Generic;
using Godot;

namespace Guide;

[Tool]
public partial class GUIDEControllerRenderer : GUIDEIconRenderer {
	private static readonly Dictionary<GUIDEFormattingUtils.ControllerType, GUIDEControllerRenderStyle> _controllerStyles = new()
	{
		{ GUIDEFormattingUtils.ControllerType.Microsoft, GD.Load<GUIDEControllerRenderStyle>("res://addons/GuideCS/UI/Renderers/Controllers/Styles/Microsoft.tres") },
		{ GUIDEFormattingUtils.ControllerType.Nintendo, GD.Load<GUIDEControllerRenderStyle>("res://addons/GuideCS/UI/Renderers/Controllers/Styles/Nintendo.tres") },
		{ GUIDEFormattingUtils.ControllerType.Sony, GD.Load<GUIDEControllerRenderStyle>("res://addons/GuideCS/UI/Renderers/Controllers/Styles/Sony.tres") },
	};

	private TextureRect _a_button;
	private TextureRect _b_button;
	private TextureRect _x_button;
	private TextureRect _y_button;
	private TextureRect _left_stick;
	private TextureRect _left_stick_click;
	private TextureRect _right_stick;
	private TextureRect _right_stick_click;
	private TextureRect _left_bumper;
	private TextureRect _right_bumper;
	private TextureRect _left_trigger;
	private TextureRect _right_trigger;
	private TextureRect _dpad_up;
	private TextureRect _dpad_left;
	private TextureRect _dpad_right;
	private TextureRect _dpad_down;
	private TextureRect _start;
	private TextureRect _misc1;
	private TextureRect _back;
	private TextureRect _left_right;
	private TextureRect _up_down;
	private Control _controls;
	private Control _directions;
	private TextureRect _touch_pad;

	public GUIDEControllerRenderer() {
		Priority = -10;
	}

	public override void _Ready() {
		base._Ready();
		_a_button = GetNode<TextureRect>("%AButton");
		_b_button = GetNode<TextureRect>("%BButton");
		_x_button = GetNode<TextureRect>("%XButton");
		_y_button = GetNode<TextureRect>("%YButton");
		_left_stick = GetNode<TextureRect>("%LeftStick");
		_left_stick_click = GetNode<TextureRect>("%LeftStickClick");
		_right_stick = GetNode<TextureRect>("%RightStick");
		_right_stick_click = GetNode<TextureRect>("%RightStickClick");
		_left_bumper = GetNode<TextureRect>("%LeftBumper");
		_right_bumper = GetNode<TextureRect>("%RightBumper");
		_left_trigger = GetNode<TextureRect>("%LeftTrigger");
		_right_trigger = GetNode<TextureRect>("%RightTrigger");
		_dpad_up = GetNode<TextureRect>("%DpadUp");
		_dpad_left = GetNode<TextureRect>("%DpadLeft");
		_dpad_right = GetNode<TextureRect>("%DpadRight");
		_dpad_down = GetNode<TextureRect>("%DpadDown");
		_start = GetNode<TextureRect>("%Start");
		_misc1 = GetNode<TextureRect>("%Misc1");
		_back = GetNode<TextureRect>("%Back");
		_left_right = GetNode<TextureRect>("%LeftRight");
		_up_down = GetNode<TextureRect>("%UpDown");
		_controls = GetNode<Control>("%Controls");
		_directions = GetNode<Control>("%Directions");
		_touch_pad = GetNode<TextureRect>("%TouchPad");
	}

	public static void SetStyle(GUIDEFormattingUtils.ControllerType type, GUIDEControllerRenderStyle style) {
		if (!IsInstanceValid(style)) {
			GD.PushError("Icon set must not be null.");
			return;
		}

		if (type == GUIDEFormattingUtils.ControllerType.Unknown) {
			GD.PushError("Cannot set icon set for the unknown controller. Use GUIDEInputFormattingOptions to set up how unknown controllers are rendered.");
			return;
		}

		_controllerStyles[type] = style;
	}

	private void _SetupTextures(GUIDEFormattingUtils.ControllerType type) {
		if (type == GUIDEFormattingUtils.ControllerType.Unknown) {
			GD.PushError("Tried to set up textures with unknown controller type. This is a bug, please report it.");
			return;
		}

		var style = _controllerStyles[type];

		_a_button.Texture = style.a_button;
		_b_button.Texture = style.b_button;
		_x_button.Texture = style.x_button;
		_y_button.Texture = style.y_button;
		_left_stick.Texture = style.left_stick;
		_left_stick_click.Texture = style.left_stick_click;
		_right_stick.Texture = style.right_stick;
		_right_stick_click.Texture = style.right_stick_click;
		_left_bumper.Texture = style.left_bumper;
		_right_bumper.Texture = style.right_bumper;
		_left_trigger.Texture = style.left_trigger;
		_right_trigger.Texture = style.right_trigger;
		_dpad_up.Texture = style.dpad_up;
		_dpad_left.Texture = style.dpad_left;
		_dpad_right.Texture = style.dpad_right;
		_dpad_down.Texture = style.dpad_down;
		_start.Texture = style.start;
		_misc1.Texture = style.misc1;
		_back.Texture = style.back;
		_touch_pad.Texture = style.touch_pad;
		_left_right.Texture = style.horizontal;
		_up_down.Texture = style.vertical;
	}

	public override bool Supports(GUIDEInput input, GUIDEInputFormattingOptions options) {
		return GUIDEFormattingUtils.EffectiveControllerType(input, options) != GUIDEFormattingUtils.ControllerType.Unknown;
	}

	public override void Render(GUIDEInput input, GUIDEInputFormattingOptions options) {
		var controllerType = GUIDEFormattingUtils.EffectiveControllerType(input, options);
		_SetupTextures(controllerType);

		foreach (Node control in _controls.GetChildren()) ((Control)control).Visible = false;
		foreach (Node direction in _directions.GetChildren()) ((Control)direction).Visible = false;
		_directions.Visible = false;

		if (input is GUIDEInputJoyAxis1D axis1D) {
			switch (axis1D.Axis) {
				case JoyAxis.LeftX:
					_left_stick.Visible = true;
					_ShowLeftRight();
					break;
				case JoyAxis.LeftY:
					_left_stick.Visible = true;
					_ShowUpDown();
					break;
				case JoyAxis.RightX:
					_right_stick.Visible = true;
					_ShowLeftRight();
					break;
				case JoyAxis.RightY:
					_right_stick.Visible = true;
					_ShowUpDown();
					break;
				case JoyAxis.TriggerLeft:
					_left_trigger.Visible = true;
					break;
				case JoyAxis.TriggerRight:
					_right_trigger.Visible = true;
					break;
			}
		}

		if (input is GUIDEInputJoyAxis2D axis2D) {
			switch (axis2D.X) {
				case JoyAxis.LeftX:
				case JoyAxis.LeftY:
					_left_stick.Visible = true;
					break;
				case JoyAxis.RightX:
				case JoyAxis.RightY:
					_right_stick.Visible = true;
					break;
			}
		}

		if (input is GUIDEInputJoyButton joyBtn) {
			switch (joyBtn.Button) {
				case JoyButton.A: _a_button.Visible = true; break;
				case JoyButton.B: _b_button.Visible = true; break;
				case JoyButton.X: _x_button.Visible = true; break;
				case JoyButton.Y: _y_button.Visible = true; break;
				case JoyButton.DpadLeft: _dpad_left.Visible = true; break;
				case JoyButton.DpadRight: _dpad_right.Visible = true; break;
				case JoyButton.DpadUp: _dpad_up.Visible = true; break;
				case JoyButton.DpadDown: _dpad_down.Visible = true; break;
				case JoyButton.LeftShoulder: _left_bumper.Visible = true; break;
				case JoyButton.RightShoulder: _right_bumper.Visible = true; break;
				case JoyButton.LeftStick: _left_stick_click.Visible = true; break;
				case JoyButton.RightStick: _right_stick_click.Visible = true; break;
				case JoyButton.Start: _start.Visible = true; break;
				case JoyButton.Back: _back.Visible = true; break;
				case JoyButton.Misc1: _misc1.Visible = true; break;
				case JoyButton.Touchpad: _touch_pad.Visible = true; break;
			}
		}

		Call("queue_sort");
	}

	private void _ShowLeftRight() {
		_directions.Visible = true;
		_left_right.Visible = true;
	}

	private void _ShowUpDown() {
		_directions.Visible = true;
		_up_down.Visible = true;
	}

	public override string CacheKey(GUIDEInput input, GUIDEInputFormattingOptions options) {
		var controllerType = GUIDEFormattingUtils.EffectiveControllerType(input, options);
		var iconSet = _controllerStyles[controllerType];
		return "7581f483-bc68-411f-98ad-dc246fd2593a" + input.ToString() + iconSet.ResourcePath;
	}
}
