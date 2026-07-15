using System;
using Godot;

namespace Guide;

public partial class GUIDEVirtualJoyBase : CenterContainer {
	[Signal] public delegate void ChangedEventHandler();
	[Signal] public delegate void ConfigurationChangedEventHandler();

	public enum InputMode {
		Touch,
		Mouse,
		MouseAndTouch
	}

	private int _virtualDevice = 0;
	[Export(PropertyHint.Enum, "Any:-1,1:0,2:1,3:2,4:3,Virtual 1:-2,Virtual 2:-3,Virtual 3:-4,Virtual 4:-5")]
	public int VirtualDevice {
		get => _virtualDevice;
		set {
			_virtualDevice = value;
			_Reconnect();
			EmitSignal(SignalName.ConfigurationChanged);
		}
	}

	private InputMode _inputMode = InputMode.Touch;
	[Export]
	public InputMode InputModeValue {
		get => _inputMode;
		set {
			_inputMode = value;
			EmitSignal(SignalName.ConfigurationChanged);
		}
	}

	private bool _drawDebug = false;
	[Export]
	public bool DrawDebug {
		get => _drawDebug;
		set {
			_drawDebug = value;
			QueueRedraw();
			EmitSignal(SignalName.ConfigurationChanged);
		}
	}

	internal bool _isActuated = false;
	protected int _virtualJoyId = 0;

	protected void _Reconnect() {
		if (!IsNodeReady()) return;

		if (_virtualJoyId != 0) {
			GUIDE.Singleton?._InputState.DisconnectVirtualStick(_virtualJoyId);
		}

		_virtualJoyId = GUIDE.Singleton?._InputState.ConnectVirtualStick(VirtualDevice) ?? 0;
	}

	public override void _Input(InputEvent @event) {
		if (@event is InputEventMouse mouseEvent) {
			if (InputModeValue == InputMode.Mouse || InputModeValue == InputMode.MouseAndTouch) {
				_HandleMouseInput(mouseEvent);
			}
		}

		if (@event is InputEventScreenTouch || @event is InputEventScreenDrag) {
			if (InputModeValue == InputMode.Touch || InputModeValue == InputMode.MouseAndTouch) {
				_HandleTouchInput(@event);
			}
		}
	}

	protected virtual void _HandleMouseInput(InputEventMouse @event) { }
	protected virtual void _HandleTouchInput(InputEvent @event) { }

	protected Vector2 _ScreenToWorld(Vector2 input) {
		return GetCanvasTransform().AffineInverse() * input;
	}
}
