using System;
using Godot;

namespace Guide;

[Tool]
public partial class GUIDEJoyRenderer : GUIDEIconRenderer {
	private TextureRect _stick;
	private TextureRect _button;
	private Label _text;
	private Control _directions;
	private TextureRect _horizontal;
	private TextureRect _vertical;

	private static GUIDEJoyRenderStyle _style = GD.Load<GUIDEJoyRenderStyle>("res://addons/GuideCS/UI/Renderers/Joy/Styles/Default.tres");

	public override void _Ready() {
		base._Ready();
		_stick = GetNode<TextureRect>("%Stick");
		_button = GetNode<TextureRect>("%Button");
		_text = GetNode<Label>("%Text");
		_directions = GetNode<Control>("%Directions");
		_horizontal = GetNode<TextureRect>("%Horizontal");
		_vertical = GetNode<TextureRect>("%Vertical");
	}

	public static void SetStyle(GUIDEJoyRenderStyle style) {
		if (!IsInstanceValid(style)) {
			GD.PushError("Joy style must not be null.");
			return;
		}
		_style = style;
	}

	public override bool Supports(GUIDEInput input, GUIDEInputFormattingOptions options) {
		return input is GUIDEInputJoyBase;
	}

	public override void Render(GUIDEInput input, GUIDEInputFormattingOptions options) {
		_stick.Texture = _style.stick;
		_stick.Visible = false;

		_button.Texture = _style.button;
		_button.Visible = false;

		_directions.Visible = false;

		_horizontal.Texture = _style.horizontal;
		_horizontal.Visible = false;

		_vertical.Texture = _style.vertical;
		_vertical.Visible = false;

		_text.Text = "";
		_text.AddThemeColorOverride("font_color", _style.font_color);
		_text.AddThemeFontOverride("font", _style.font);
		_text.AddThemeFontSizeOverride("font_size", _style.font_size);

		if (input is GUIDEInputJoyAxis1D axis1D) {
			_stick.Visible = true;
			switch (axis1D.Axis) {
				case JoyAxis.LeftX:
					_directions.Visible = true;
					_text.Text = "1";
					_horizontal.Visible = true;
					break;
				case JoyAxis.RightX:
					_directions.Visible = true;
					_text.Text = "2";
					_horizontal.Visible = true;
					break;
				case JoyAxis.LeftY:
					_directions.Visible = true;
					_text.Text = "1";
					_vertical.Visible = true;
					break;
				case JoyAxis.RightY:
					_directions.Visible = true;
					_text.Text = "2";
					_vertical.Visible = true;
					break;
				case JoyAxis.TriggerLeft:
					_text.Text = "3";
					break;
				case JoyAxis.TriggerRight:
					_text.Text = "4";
					break;
			}
		}

		if (input is GUIDEInputJoyAxis2D axis2D) {
			_stick.Visible = true;
			switch (axis2D.X) {
				case JoyAxis.LeftX:
				case JoyAxis.LeftY:
					_text.Text = "1";
					break;
				case JoyAxis.RightX:
				case JoyAxis.RightY:
					_text.Text = "2";
					break;
				default:
					_text.Text = (axis2D.X + (int)axis2D.Y).ToString();
					break;
			}
		}

		if (input is GUIDEInputJoyButton joyBtn) {
			_button.Visible = true;
			_text.Text = ((int)joyBtn.Button).ToString();
		}

		Call("queue_sort");
	}

	public override string CacheKey(GUIDEInput input, GUIDEInputFormattingOptions options) {
		return "a9ced629-de65-4c31-9de0-8e4cbf88a2e0" + input.ToString() + _style.ResourcePath;
	}
}
