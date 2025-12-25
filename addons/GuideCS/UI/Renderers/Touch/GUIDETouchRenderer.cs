using Godot;

namespace Guide;

[Tool]
public partial class GUIDETouchRenderer : GUIDEIconRenderer {
	private Control _controls;
	private TextureRect _1_finger;
	private TextureRect _2_finger;
	private TextureRect _3_finger;
	private TextureRect _4_finger;
	private TextureRect _rotate;
	private TextureRect _zoom;

	private Control _directions;
	private TextureRect _horizontal;
	private TextureRect _vertical;
	private TextureRect _axis2d;

	private static GUIDETouchRenderStyle _style = GD.Load<GUIDETouchRenderStyle>("res://addons/GuideCS/UI/Renderers/Touch/Styles/Default.tres");

	public override void _Ready() {
		base._Ready();
		_controls = GetNode<Control>("%Controls");
		_1_finger = GetNode<TextureRect>("%T1Finger");
		_2_finger = GetNode<TextureRect>("%T2Fingers");
		_3_finger = GetNode<TextureRect>("%T3Fingers");
		_4_finger = GetNode<TextureRect>("%T4Fingers");
		_rotate = GetNode<TextureRect>("%Rotate");
		_zoom = GetNode<TextureRect>("%Zoom");

		_directions = GetNode<Control>("%Directions");
		_horizontal = GetNode<TextureRect>("%Horizontal");
		_vertical = GetNode<TextureRect>("%Vertical");
		_axis2d = GetNode<TextureRect>("%Axis2D");
	}

	public static void SetStyle(GUIDETouchRenderStyle style) {
		if (!IsInstanceValid(style)) {
			GD.PushError("Touch style must not be null.");
			return;
		}
		_style = style;
	}

	public override bool Supports(GUIDEInput input, GUIDEInputFormattingOptions options) {
		return input is GUIDEInputTouchAxis1D ||
			   input is GUIDEInputTouchAxis2D ||
			   input is GUIDEInputTouchPosition ||
			   input is GUIDEInputTouchAngle ||
			   input is GUIDEInputTouchDistance;
	}

	public override void Render(GUIDEInput input, GUIDEInputFormattingOptions options) {
		foreach (Node child in _controls.GetChildren()) ((Control)child).Visible = false;
		foreach (Node child in _directions.GetChildren()) ((Control)child).Visible = false;
		_directions.Visible = false;

		_1_finger.Texture = _style.one_finger;
		_2_finger.Texture = _style.two_fingers;
		_3_finger.Texture = _style.three_fingers;
		_4_finger.Texture = _style.four_fingers;
		_rotate.Texture = _style.rotate;
		_zoom.Texture = _style.zoom;
		_horizontal.Texture = _style.horizontal;
		_vertical.Texture = _style.vertical;
		_axis2d.Texture = _style.both;

		if (input is GUIDEInputTouchBase touchBase) {
			switch (touchBase.FingerCount) {
				case 2: _2_finger.Visible = true; break;
				case 3: _3_finger.Visible = true; break;
				case 4: _4_finger.Visible = true; break;
				default: _1_finger.Visible = true; break;
			}
		}

		if (input is GUIDEInputTouchAxis2D) {
			_directions.Visible = true;
			_axis2d.Visible = true;
		}

		if (input is GUIDEInputTouchAxis1D touchAxis1D) {
			_directions.Visible = true;
			if (touchAxis1D.Axis == GUIDEInputTouchAxis1D.GUIDEInputTouchAxis.X) _horizontal.Visible = true;
			else _vertical.Visible = true;
		}

		if (input is GUIDEInputTouchDistance) _zoom.Visible = true;
		if (input is GUIDEInputTouchAngle) _rotate.Visible = true;

		Call("queue_sort");
	}

	public override string CacheKey(GUIDEInput input, GUIDEInputFormattingOptions options) {
		return "1f4c5082-d419-465f-aba8-f889caaff335" + input.ToString() + _style.ResourcePath;
	}
}
