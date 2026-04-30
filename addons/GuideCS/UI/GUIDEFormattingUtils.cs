using System;
using System.Collections.Generic;
using Godot;

namespace Guide;

[Tool]
public partial class GUIDEFormattingUtils : RefCounted {
	public enum ControllerType {
		Unknown = 0,
		Microsoft = 1,
		Nintendo = 2,
		Sony = 3,
	}

	private static readonly Dictionary<ControllerType, string[]> _controllerDetectionStrings = new() {
		{ ControllerType.Microsoft, new[] { "XBox", "XInput" } },
		{ ControllerType.Nintendo, new[] { "Nintendo Switch" } },
		{ ControllerType.Sony, new[] { "DualSense", "DualShock", "PlayStation", "PS3", "PS4", "PS5" } },
	};

	public static ControllerType EffectiveControllerType(GUIDEInput input, GUIDEInputFormattingOptions options) {
		if (input is not GUIDEInputJoyBase) return ControllerType.Unknown;

		if (options.joy_rendering == GUIDEInputFormattingOptions.JoyRendering.ForceJoyType) {
			return _ControllerTypeFromJoyType(options.preferred_joy_type);
		}

		var controllerType = _DetectControllerType(input);

		if (options.joy_rendering == GUIDEInputFormattingOptions.JoyRendering.PreferJoyType) {
			if (controllerType == ControllerType.Unknown) {
				return _ControllerTypeFromJoyType(options.preferred_joy_type);
			}
		}

		return controllerType;
	}

	private static ControllerType _DetectControllerType(GUIDEInput input) {
		var haystack = _JoyNameForInput(input).ToLower();
		if (string.IsNullOrEmpty(haystack)) return ControllerType.Unknown;

		foreach (var kvp in _controllerDetectionStrings) {
			foreach (var needle in kvp.Value) {
				if (haystack.Contains(needle.ToLower())) return kvp.Key;
			}
		}

		return ControllerType.Unknown;
	}

	private static ControllerType _ControllerTypeFromJoyType(GUIDEInputFormattingOptions.JoyType joyType) {
		return joyType switch {
			GUIDEInputFormattingOptions.JoyType.MicrosoftController => ControllerType.Microsoft,
			GUIDEInputFormattingOptions.JoyType.NintendoController => ControllerType.Nintendo,
			GUIDEInputFormattingOptions.JoyType.SonyController => ControllerType.Sony,
			_ => ControllerType.Unknown,
		};
	}

	private static string _JoyNameForInput(GUIDEInput input) {
		if (input is not GUIDEInputJoyBase joyInput) return "";

		var joypads = Input.GetConnectedJoypads();
		int joyIndex = joyInput.JoyIndex;
		if (joyIndex < 0) joyIndex = 0;

		if (joypads.Count <= joyIndex) return "";

		int id = joypads[joyIndex];
		return Input.GetJoyName(id);
	}
}
