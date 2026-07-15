using System;
using Godot;

namespace Guide;

[Tool]
[Icon("res://addons/GuideCS/UI/Renderers/Style.svg")]
public partial class GUIDETouchRenderStyle : Resource {
	[Export] public Texture2D one_finger { get; set; }
	[Export] public Texture2D two_fingers { get; set; }
	[Export] public Texture2D three_fingers { get; set; }
	[Export] public Texture2D four_fingers { get; set; }
	[Export] public Texture2D rotate { get; set; }
	[Export] public Texture2D zoom { get; set; }

	[ExportGroup("Directions")]
	[Export] public Texture2D horizontal { get; set; }
	[Export] public Texture2D vertical { get; set; }
	[Export] public Texture2D both { get; set; }
}
