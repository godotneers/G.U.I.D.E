using System;
using Godot;

namespace Guide;

[Tool]
[GlobalClass, Icon("res://addons/GuideCS/GUIDEInternal.svg")]
public partial class GUIDEActionMapping : Resource {
	private GUIDEAction _action;
	[Export]
	public GUIDEAction Action {
		get => _action;
		set {
			if (_action == value) return;
			_action = value;
			EmitChanged();
		}
	}

	private Godot.Collections.Array<GUIDEInputMapping> _inputMappings = new();
	[Export]
	public Godot.Collections.Array<GUIDEInputMapping> InputMappings {
		get => _inputMappings;
		set {
			if (_inputMappings == value) return;
			_inputMappings = value;
			EmitChanged();
		}
	}
}
