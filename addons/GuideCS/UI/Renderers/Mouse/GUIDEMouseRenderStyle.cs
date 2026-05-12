using System;
using Godot;

namespace Guide;

[Tool]
[Icon("res://addons/GuideCS/UI/Renderers/Style.svg")]
public partial class GUIDEMouseRenderStyle : Resource {
	[Export] public Texture2D mouse_blank { get; set; }
	[Export] public Texture2D mouse_left { get; set; }
	[Export] public Texture2D mouse_right { get; set; }
	[Export] public Texture2D mouse_middle { get; set; }
	[Export] public Texture2D mouse_side_a { get; set; }
	[Export] public Texture2D mouse_side_b { get; set; }
	[Export] public Texture2D mouse_cursor { get; set; }

	[ExportGroup("Directions")]
	[Export] public Texture2D left { get; set; }
	[Export] public Texture2D right { get; set; }
	[Export] public Texture2D up { get; set; }
	[Export] public Texture2D down { get; set; }
	[Export] public Texture2D horizontal { get; set; }
	[Export] public Texture2D vertical { get; set; }
}
