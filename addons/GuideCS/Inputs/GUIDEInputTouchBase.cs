using System;
using Godot;

namespace Guide;

[Tool]
[GlobalClass]
public partial class GUIDEInputTouchBase : GUIDEInput {
	private int _fingerCount = 1;
	[Export(PropertyHint.Range, "1,5,1,or_greater")]
	public int FingerCount {
		get => _fingerCount;
		set {
			if (value < 1) value = 1;
			_fingerCount = value;
			EmitChanged();
		}
	}

	private int _fingerIndex = 0;
	[Export(PropertyHint.Range, "-1,4,1,or_greater")]
	public int FingerIndex {
		get => _fingerIndex;
		set {
			if (value < -1) value = -1;
			_fingerIndex = value;
			EmitChanged();
		}
	}

	public override DeviceType _DeviceType() => DeviceType.Touch;
}
