using System;
using Godot;

namespace Guide;

[Tool]
[Icon("res://addons/GuideCS/UI/Renderers/Style.svg")]
public partial class GUIDEJoyRenderStyle : Resource {
	[Export] public Texture2D button { get; set; }
	[Export] public Texture2D stick { get; set; }
	[Export] public Font font { get; set; }
	[Export] public Color font_color { get; set; } = new Color(0.843f, 0.843f, 0.843f);
	[Export] public int font_size { get; set; } = 50;

	[ExportGroup("Directions")]
	[Export] public Texture2D horizontal { get; set; }
	[Export] public Texture2D vertical { get; set; }
}
