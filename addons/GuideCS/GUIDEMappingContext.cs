using Godot;

namespace Guide;

[Tool]
[GlobalClass, Icon("res://addons/GuideCS/GUIDEMappingContext.svg")]
public partial class GUIDEMappingContext : Resource {
	[Signal]
	public delegate void EnabledEventHandler();

	[Signal]
	public delegate void DisabledEventHandler();

	private string _displayName;
	[Export]
	public string DisplayName {
		get => _displayName;
		set {
			if (_displayName == value) return;
			_displayName = value;
			EmitChanged();
		}
	}

	private Godot.Collections.Array<GUIDEActionMapping> _mappings = new();
	[Export]
	public Godot.Collections.Array<GUIDEActionMapping> Mappings {
		get => _mappings;
		set {
			if (_mappings == value) return;
			_mappings = value;
			EmitChanged();
		}
	}

	public string EditorName() {
		if (string.IsNullOrEmpty(DisplayName)) {
			return ResourcePath.GetFile();
		}
		else {
			return DisplayName;
		}
	}
}
