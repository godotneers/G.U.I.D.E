using System;
using Godot;

namespace Guide;

public partial class GUIDEInputFormattingOptions : RefCounted {
	public enum JoyRendering {
		Default = 0,
		PreferJoyType = 1,
		ForceJoyType = 2,
	}

	public enum JoyType {
		GenericJoy = 0,
		MicrosoftController = 1,
		NintendoController = 2,
		SonyController = 3
	}

	public static readonly Func<Variant, bool> InputFilterShowAll = (context) => true;

	public Func<Variant, bool> input_filter = InputFilterShowAll;

	public JoyRendering joy_rendering = JoyRendering.Default;

	public JoyType preferred_joy_type = JoyType.GenericJoy;
}
