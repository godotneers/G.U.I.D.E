using System;
using Godot;

namespace Guide;

[Tool]
[Icon("res://addons/GuideCS/UI/Renderers/Style.svg")]
public partial class GUIDEKeyRenderStyle : Resource {
	[Export] public Texture2D keycaps { get; set; }
	[Export] public Rect2 region_rect { get; set; } = new Rect2();

	[ExportGroup("Patch margin", "patch_margin")]
	[Export(PropertyHint.Range, "0,100,1,or_greater")] public int patch_margin_left { get; set; } = 0;
	[Export(PropertyHint.Range, "0,100,1,or_greater")] public int patch_margin_top { get; set; } = 0;
	[Export(PropertyHint.Range, "0,100,1,or_greater")] public int patch_margin_right { get; set; } = 0;
	[Export(PropertyHint.Range, "0,100,1,or_greater")] public int patch_margin_bottom { get; set; } = 0;

	[Export] public Font font { get; set; }
	[Export] public Color font_color { get; set; } = new Color(0.843f, 0.843f, 0.843f);
	[Export] public int font_size { get; set; } = 45;
}
