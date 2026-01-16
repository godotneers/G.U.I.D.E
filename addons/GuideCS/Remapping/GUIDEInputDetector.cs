using System;
using System.Collections.Generic;
using System.Linq;
using Godot;

namespace Guide;

[Tool]
public partial class GUIDEInputDetector : Node {
	public enum JoyIndex {
		Any = 0,
		Detected = 1
	}

	public enum DetectionState {
		Idle = 0,
		Countdown = 3,
		InputPreClear = 4,
		Detecting = 1,
		InputPostClear = 2,
	}

	[Export(PropertyHint.Range, "0,2,0.1,or_greater")]
	public float DetectionCountdownSeconds { get; set; } = 0.5f;
	[Export(PropertyHint.Range, "0,1,0.1,or_greater")]
	public float MinimumAxisAmplitude { get; set; } = 0.2f;
	[Export] public Godot.Collections.Array<GUIDEInput> AbortDetectionOn { get; set; } = new();
	[Export] public JoyIndex UseJoyIndex { get; set; } = JoyIndex.Any;
	[Export] public bool AllowTriggersForBooleanActions { get; set; } = true;

	[Signal] public delegate void DetectionStartedEventHandler();
	[Signal] public delegate void InputDetectedEventHandler(GUIDEInput input);

	private Timer _timer;
	private DetectionState _status = DetectionState.Idle;
	private List<GUIDEMappingContext> _savedMappingContexts = new();
	private GUIDEInput _lastDetectedInput = null;

	public override void _Ready() {
		SetProcess(false);
		_timer = new Timer();
		_timer.OneShot = true;
		AddChild(_timer, false, InternalMode.Front);
		_timer.Timeout += _BeginDetection;
	}

	public bool IsDetecting => _status != DetectionState.Idle;

	private GUIDEAction.GUIDEActionValueType _valueType;
	private GUIDEInput.DeviceType[] _deviceTypes = Array.Empty<GUIDEInput.DeviceType>();

	public void DetectBool(GUIDEInput.DeviceType[] deviceTypes = null) => Detect(GUIDEAction.GUIDEActionValueType.Bool, deviceTypes);
	public void DetectAxis1D(GUIDEInput.DeviceType[] deviceTypes = null) => Detect(GUIDEAction.GUIDEActionValueType.Axis1D, deviceTypes);
	public void DetectAxis2D(GUIDEInput.DeviceType[] deviceTypes = null) => Detect(GUIDEAction.GUIDEActionValueType.Axis2D, deviceTypes);
	public void DetectAxis3D(GUIDEInput.DeviceType[] deviceTypes = null) => Detect(GUIDEAction.GUIDEActionValueType.Axis3D, deviceTypes);

	public void Detect(GUIDEAction.GUIDEActionValueType valueType, GUIDEInput.DeviceType[] deviceTypes = null) {
		_deviceTypes = deviceTypes ?? Array.Empty<GUIDEInput.DeviceType>();

		if (_deviceTypes.Contains(GUIDEInput.DeviceType.Touch)) {
			GD.PushError("Detecting touch events is not supported.");
		}

		if (_status == DetectionState.Detecting || _status == DetectionState.InputPreClear || _status == DetectionState.InputPostClear) {
			foreach (var input in AbortDetectionOn) input._EndUsage();
		}

		_status = DetectionState.Countdown;
		_valueType = valueType;
		_timer.Stop();

		if (DetectionCountdownSeconds > 0) {
			_timer.Start(DetectionCountdownSeconds);
		}
		else {
			Callable.From(_BeginDetection).CallDeferred();
		}
	}

	private void _BeginDetection() {
		_status = DetectionState.InputPreClear;

		foreach (var input in AbortDetectionOn) {
			input._State = GUIDE.Singleton?._InputState;
			input._BeginUsage();
		}

		if (!Engine.IsEditorHint()) {
			_savedMappingContexts = GUIDE.Singleton?.GetEnabledMappingContexts().ToList() ?? new List<GUIDEMappingContext>();
			foreach (var context in _savedMappingContexts) {
				GUIDE.Singleton?.DisableMappingContext(context);
			}
		}

		SetProcess(true);
	}

	public void AbortDetection() {
		_timer.Stop();
		if (_status == DetectionState.Detecting) {
			_Deliver(null);
		}
	}

	public override void _Process(double delta) {
		if (_status != DetectionState.InputPreClear && _status != DetectionState.InputPostClear) {
			SetProcess(false);
			return;
		}

		foreach (var input in AbortDetectionOn) {
			if (input._Value.IsFinite() && input._Value.Length() > 0) return;
		}

		if (_status == DetectionState.InputPreClear) {
			_status = DetectionState.Detecting;
			SetProcess(false);
			EmitSignal(SignalName.DetectionStarted);
			return;
		}

		foreach (var input in AbortDetectionOn) input._EndUsage();

		if (!Engine.IsEditorHint()) {
			foreach (var context in _savedMappingContexts) {
				GUIDE.Singleton?.EnableMappingContext(context);
			}
		}

		_status = DetectionState.Idle;
		EmitSignal(SignalName.InputDetected, _lastDetectedInput);
	}

	public override void _Input(InputEvent @event) {
		if (_status == DetectionState.Idle) return;

		GetViewport().SetInputAsHandled();
		if (!Engine.IsEditorHint()) {
			GUIDE.Singleton?.InjectInput(@event);
		}

		if (_status == DetectionState.Detecting) {
			foreach (var input in AbortDetectionOn) {
				if (input._Value.IsFinite() && input._Value.Length() > 0) {
					AbortDetection();
					return;
				}
			}

			if (!_MatchesDeviceTypes(@event)) return;

			switch (_valueType) {
				case GUIDEAction.GUIDEActionValueType.Bool:
					_TryDetectBool(@event);
					break;
				case GUIDEAction.GUIDEActionValueType.Axis1D:
					_TryDetectAxis1D(@event);
					break;
				case GUIDEAction.GUIDEActionValueType.Axis2D:
					_TryDetectAxis2D(@event);
					break;
				case GUIDEAction.GUIDEActionValueType.Axis3D:
					_TryDetectAxis3D(@event);
					break;
			}
		}
	}

	private bool _MatchesDeviceTypes(InputEvent @event) {
		if (_deviceTypes.Length == 0) return true;

		if (@event is InputEventKey) return _deviceTypes.Contains(GUIDEInput.DeviceType.Keyboard);
		if (@event is InputEventMouse) return _deviceTypes.Contains(GUIDEInput.DeviceType.Mouse);
		if (@event is InputEventJoypadButton || @event is InputEventJoypadMotion) return _deviceTypes.Contains(GUIDEInput.DeviceType.Joy);

		return false;
	}

	private void _TryDetectBool(InputEvent @event) {
		if (@event is InputEventKey keyEvent && keyEvent.IsReleased()) {
			var result = new GUIDEInputKey {
				Key = keyEvent.PhysicalKeycode,
				Shift = keyEvent.ShiftPressed,
				Control = keyEvent.CtrlPressed,
				Meta = keyEvent.MetaPressed,
				Alt = keyEvent.AltPressed
			};
			_Deliver(result);
			return;
		}

		if (@event is InputEventMouseButton mouseButton && mouseButton.IsReleased()) {
			var result = new GUIDEInputMouseButton { Button = mouseButton.ButtonIndex };
			_Deliver(result);
			return;
		}

		if (@event is InputEventJoypadButton joyButton && joyButton.IsReleased()) {
			var result = new GUIDEInputJoyButton {
				Button = joyButton.ButtonIndex,
				JoyIndex = _FindJoyIndex(joyButton.Device)
			};
			_Deliver(result);
			return;
		}

		if (AllowTriggersForBooleanActions) {
			if (@event is not InputEventJoypadMotion joyMotion) return;
			if (joyMotion.Axis != JoyAxis.TriggerLeft && joyMotion.Axis != JoyAxis.TriggerRight) return;

			var result = new GUIDEInputJoyAxis1D {
				Axis = joyMotion.Axis,
				JoyIndex = _FindJoyIndex(joyMotion.Device)
			};
			_Deliver(result);
		}
	}

	private void _TryDetectAxis1D(InputEvent @event) {
		if (@event is InputEventMouseMotion mouseMotion && mouseMotion.Relative.LengthSquared() > 0) {
			var result = new GUIDEInputMouseAxis1D();
			if (Math.Abs(mouseMotion.Relative.X) > Math.Abs(mouseMotion.Relative.Y)) {
				result.Axis = GUIDEInputMouseAxis1D.GuideInputMouseAxis.X;
			}
			else {
				result.Axis = GUIDEInputMouseAxis1D.GuideInputMouseAxis.Y;
			}
			_Deliver(result);
			return;
		}

		if (@event is InputEventJoypadMotion joyMotion) {
			if (Math.Abs(joyMotion.AxisValue) < MinimumAxisAmplitude) return;

			var result = new GUIDEInputJoyAxis1D {
				Axis = joyMotion.Axis,
				JoyIndex = _FindJoyIndex(joyMotion.Device)
			};
			_Deliver(result);
		}
	}

	private void _TryDetectAxis2D(InputEvent @event) {
		if (@event is InputEventMouseMotion) {
			_Deliver(new GUIDEInputMouseAxis2D());
			return;
		}

		if (@event is InputEventJoypadMotion joyMotion) {
			if (Math.Abs(joyMotion.AxisValue) < MinimumAxisAmplitude) return;

			var result = new GUIDEInputJoyAxis2D();
			switch (joyMotion.Axis) {
				case JoyAxis.LeftX:
				case JoyAxis.LeftY:
					result.X = JoyAxis.LeftX;
					result.Y = JoyAxis.LeftY;
					break;
				case JoyAxis.RightX:
				case JoyAxis.RightY:
					result.X = JoyAxis.RightX;
					result.Y = JoyAxis.RightY;
					break;
				default:
					return;
			}
			result.JoyIndex = _FindJoyIndex(joyMotion.Device);
			_Deliver(result);
		}
	}

	private void _TryDetectAxis3D(InputEvent @event) { }

	private int _FindJoyIndex(int deviceId) {
		if (UseJoyIndex == JoyIndex.Any) return -1;
		var pads = Input.GetConnectedJoypads();
		for (int i = 0; i < pads.Count; i++) {
			if (pads[i] == deviceId) return i;
		}
		return -1;
	}

	private void _Deliver(GUIDEInput input) {
		_lastDetectedInput = input;
		_status = DetectionState.InputPostClear;
		SetProcess(true);
	}
}
