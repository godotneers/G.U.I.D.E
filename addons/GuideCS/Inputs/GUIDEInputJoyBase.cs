using Godot;

namespace Guide;

[Tool]
[GlobalClass]
public partial class GUIDEInputJoyBase : GUIDEInput {
	private int _joyIndex = -1;

	[Export(PropertyHint.Enum, "Any:-1,1:0,2:1,3:2,4:3,Virtual 1:-2,Virtual 2:-3,Virtual 3:-4,Virtual 4:-5")]
	public int JoyIndex {
		get => _joyIndex;
		set {
			if (_joyIndex == value) return;
			_joyIndex = value;
			EmitChanged();
		}
	}

	public override DeviceType _DeviceType() => DeviceType.Joy;
}
