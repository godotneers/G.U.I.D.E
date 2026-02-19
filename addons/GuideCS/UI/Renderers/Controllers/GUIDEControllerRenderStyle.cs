using System;
using Godot;

namespace Guide;

[Tool]
[Icon("res://addons/GuideCS/UI/Renderers/Style.svg")]
public partial class GUIDEControllerRenderStyle : Resource {
	[Export] public Texture2D a_button { get; set; }
	[Export] public Texture2D b_button { get; set; }
	[Export] public Texture2D x_button { get; set; }
	[Export] public Texture2D y_button { get; set; }
	[Export] public Texture2D left_stick { get; set; }
	[Export] public Texture2D left_stick_click { get; set; }
	[Export] public Texture2D right_stick { get; set; }
	[Export] public Texture2D right_stick_click { get; set; }
	[Export] public Texture2D left_bumper { get; set; }
	[Export] public Texture2D right_bumper { get; set; }
	[Export] public Texture2D left_trigger { get; set; }
	[Export] public Texture2D right_trigger { get; set; }
	[Export] public Texture2D dpad_up { get; set; }
	[Export] public Texture2D dpad_left { get; set; }
	[Export] public Texture2D dpad_right { get; set; }
	[Export] public Texture2D dpad_down { get; set; }
	[Export] public Texture2D start { get; set; }
	[Export] public Texture2D misc1 { get; set; }
	[Export] public Texture2D back { get; set; }
	[Export] public Texture2D touch_pad { get; set; }

	[ExportGroup("Directions")]
	[Export] public Texture2D horizontal { get; set; }
	[Export] public Texture2D vertical { get; set; }
}
