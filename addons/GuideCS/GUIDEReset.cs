using System.Collections.Generic;
using Godot;

namespace Guide;

public partial class GUIDEReset : Node {
	internal List<GUIDEInput> _inputsToReset = new();

	public override void _EnterTree() {
		// this should run at the end of the frame, so we put in a low priority (= high number)
		ProcessPriority = 10000000;
	}

	public override void _Process(double delta) {
		foreach (var input in _inputsToReset) {
			input._Reset();
		}

		GUIDE.Singleton?._InputState._Reset();
	}
}
