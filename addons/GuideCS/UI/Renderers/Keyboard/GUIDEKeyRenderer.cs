using System;
using Godot;

namespace Guide;

[Tool]
public partial class GUIDEKeyRenderer : GUIDEIconRenderer {
	private Label _label;
	private NinePatchRect _ninePatchRect;

	private static GUIDEKeyRenderStyle _style = GD.Load<GUIDEKeyRenderStyle>("res://addons/GuideCS/UI/Renderers/Keyboard/Styles/Default.tres");

	public override void _Ready() {
		base._Ready();
		_label = GetNode<Label>("%Label");
		_ninePatchRect = GetNode<NinePatchRect>("%NinePatchRect");
	}

	public static void SetStyle(GUIDEKeyRenderStyle style) {
		if (!IsInstanceValid(style)) {
			GD.PushError("Key style must not be null.");
			return;
		}
		_style = style;
	}

	public override bool Supports(GUIDEInput input, GUIDEInputFormattingOptions options) {
		return input is GUIDEInputKey;
	}

	public override void Render(GUIDEInput input, GUIDEInputFormattingOptions options) {
		if (input is not GUIDEInputKey keyInput) return;

		_ninePatchRect.Texture = _style.keycaps;
		_ninePatchRect.RegionRect = _style.region_rect;
		_ninePatchRect.PatchMarginLeft = _style.patch_margin_left;
		_ninePatchRect.PatchMarginTop = _style.patch_margin_top;
		_ninePatchRect.PatchMarginRight = _style.patch_margin_right;
		_ninePatchRect.PatchMarginBottom = _style.patch_margin_bottom;

		var labelKey = DisplayServer.KeyboardGetLabelFromPhysical(keyInput.Key);
		_label.Text = OS.GetKeycodeString(labelKey).StripEdges();
		_label.AddThemeColorOverride("font_color", _style.font_color);
		_label.AddThemeFontOverride("font", _style.font);
		_label.AddThemeFontSizeOverride("font_size", _style.font_size);
		Size = Vector2.Zero;

		Call("queue_sort");
	}

	public override string CacheKey(GUIDEInput input, GUIDEInputFormattingOptions options) {
		return "ed6923d5-4115-44bd-b35e-2c4102ffc83e" + input.ToString() + _style.ResourcePath;
	}
}
