using System;
using Godot;

namespace Guide;

[Tool]
public partial class GUIDEMouseRenderer : GUIDEIconRenderer {
	private Control _controls;
	private TextureRect _mouse_left;
	private TextureRect _mouse_right;
	private TextureRect _mouse_middle;
	private TextureRect _mouse_side_a;
	private TextureRect _mouse_side_b;
	private TextureRect _mouse_blank;
	private TextureRect _mouse_cursor;

	private Control _directions;
	private TextureRect _left;
	private TextureRect _right;
	private TextureRect _up;
	private TextureRect _down;
	private TextureRect _horizontal;
	private TextureRect _vertical;

	private static GUIDEMouseRenderStyle _style = GD.Load<GUIDEMouseRenderStyle>("res://addons/GuideCS/UI/Renderers/Mouse/Styles/Default.tres");

	public override void _Ready() {
		base._Ready();
		_controls = GetNode<Control>("%Controls");
		_mouse_left = GetNode<TextureRect>("%MouseLeft");
		_mouse_right = GetNode<TextureRect>("%MouseRight");
		_mouse_middle = GetNode<TextureRect>("%MouseMiddle");
		_mouse_side_a = GetNode<TextureRect>("%MouseSideA");
		_mouse_side_b = GetNode<TextureRect>("%MouseSideB");
		_mouse_blank = GetNode<TextureRect>("%MouseBlank");
		_mouse_cursor = GetNode<TextureRect>("%MouseCursor");

		_directions = GetNode<Control>("%Directions");
		_left = GetNode<TextureRect>("%Left");
		_right = GetNode<TextureRect>("%Right");
		_up = GetNode<TextureRect>("%Up");
		_down = GetNode<TextureRect>("%Down");
		_horizontal = GetNode<TextureRect>("%Horizontal");
		_vertical = GetNode<TextureRect>("%Vertical");
	}

	public static void SetStyle(GUIDEMouseRenderStyle style) {
		if (!IsInstanceValid(style)) {
			GD.PushError("Mouse style must not be null.");
			return;
		}
		_style = style;
	}

	public override bool Supports(GUIDEInput input, GUIDEInputFormattingOptions options) {
		return input is GUIDEInputMouseButton ||
			   input is GUIDEInputMouseAxis1D ||
			   input is GUIDEInputMouseAxis2D ||
			   input is GUIDEInputMousePosition;
	}

	public override void Render(GUIDEInput input, GUIDEInputFormattingOptions options) {
		foreach (Node child in _controls.GetChildren()) ((Control)child).Visible = false;
		foreach (Node child in _directions.GetChildren()) ((Control)child).Visible = false;
		_directions.Visible = false;

		_mouse_blank.Texture = _style.mouse_blank;
		_mouse_left.Texture = _style.mouse_left;
		_mouse_right.Texture = _style.mouse_right;
		_mouse_middle.Texture = _style.mouse_middle;
		_mouse_side_a.Texture = _style.mouse_side_a;
		_mouse_side_b.Texture = _style.mouse_side_b;
		_mouse_cursor.Texture = _style.mouse_cursor;

		_left.Texture = _style.left;
		_right.Texture = _style.right;
		_up.Texture = _style.up;
		_down.Texture = _style.down;
		_horizontal.Texture = _style.horizontal;
		_vertical.Texture = _style.vertical;

		if (input is GUIDEInputMouseButton mouseBtn) {
			switch (mouseBtn.Button) {
				case MouseButton.Left: _mouse_left.Visible = true; break;
				case MouseButton.Right: _mouse_right.Visible = true; break;
				case MouseButton.Middle: _mouse_middle.Visible = true; break;
				case MouseButton.WheelUp:
					_directions.Visible = true; _up.Visible = true; _mouse_middle.Visible = true; break;
				case MouseButton.WheelDown:
					_directions.Visible = true; _down.Visible = true; _mouse_middle.Visible = true; break;
				case MouseButton.WheelLeft:
					_directions.Visible = true; _left.Visible = true; _mouse_middle.Visible = true; break;
				case MouseButton.WheelRight:
					_directions.Visible = true; _right.Visible = true; _mouse_middle.Visible = true; break;
				case MouseButton.Xbutton1: _mouse_side_a.Visible = true; break;
				case MouseButton.Xbutton2: _mouse_side_b.Visible = true; break;
			}
		}

		if (input is GUIDEInputMouseAxis1D mouseAxis1D) {
			_mouse_blank.Visible = true;
			_directions.Visible = true;
			if (mouseAxis1D.Axis == GUIDEInputMouseAxis1D.GuideInputMouseAxis.X) _horizontal.Visible = true;
			else _vertical.Visible = true;
		}

		if (input is GUIDEInputMouseAxis2D) _mouse_blank.Visible = true;
		if (input is GUIDEInputMousePosition) _mouse_cursor.Visible = true;

		Call("queue_sort");
	}

	public override string CacheKey(GUIDEInput input, GUIDEInputFormattingOptions options) {
		return "7e27520a-b6d8-4451-858d-e94330c82e85" + input.ToString() + _style.ResourcePath;
	}
}
