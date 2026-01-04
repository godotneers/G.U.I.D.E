using System;
using Godot;

namespace Guide;

public partial class GUIDEInputTracker : Node {
	public static void _Instrument(Viewport viewport) {
		if (viewport.HasMeta("x_guide_instrumented")) return;

		var tracker = new GUIDEInputTracker();
		tracker.ProcessMode = ProcessModeEnum.Always;
		viewport.AddChild(tracker, false, InternalMode.Back);
		viewport.GuiFocusChanged += tracker._ControlFocused;
		viewport.SetMeta("x_guide_instrumented", true);
	}

	public override void _UnhandledInput(InputEvent @event) {
		GUIDE.Singleton?.InjectInput(@event);
	}

	private void _ControlFocused(Control control) {
		if (control is OptionButton || control is ColorPickerButton ||
			control is MenuButton || control is TabContainer) {
			var popup = (Viewport)control.Call("get_popup");
			if (popup != null) {
				_Instrument(popup);
			}
		}
	}
}
