using System;
using Godot;

namespace Guide;

[Tool]
public partial class GuideControllerLabelSet : Resource {
	[Export] public string a_button { get; set; } = "";
	[Export] public string b_button { get; set; } = "";
	[Export] public string x_button { get; set; } = "";
	[Export] public string y_button { get; set; } = "";
	[Export] public string left_stick { get; set; } = "Left Stick";
	[Export] public string left_stick_click { get; set; } = "";
	[Export] public string left_stick_horizontal_movement { get; set; } = "Left Stick Horizontal";
	[Export] public string left_stick_vertical_movement { get; set; } = "Left Stick Horizontal";
	[Export] public string right_stick { get; set; } = "Right Stick";
	[Export] public string right_stick_click { get; set; } = "";
	[Export] public string right_stick_horizontal_movement { get; set; } = "Left Stick Horizontal";
	[Export] public string right_stick_vertical_movement { get; set; } = "Left Stick Horizontal";
	[Export] public string left_bumper { get; set; } = "";
	[Export] public string right_bumper { get; set; } = "";
	[Export] public string left_trigger { get; set; } = "";
	[Export] public string right_trigger { get; set; } = "";
	[Export] public string dpad_up { get; set; } = "DPAD Up";
	[Export] public string dpad_left { get; set; } = "DPAD Left";
	[Export] public string dpad_right { get; set; } = "DPAD Right";
	[Export] public string dpad_down { get; set; } = "DPAD Down";
	[Export] public string start { get; set; } = "";
	[Export] public string misc1 { get; set; } = "";
	[Export] public string back { get; set; } = "";
	[Export] public string touch_pad { get; set; } = "";
}
