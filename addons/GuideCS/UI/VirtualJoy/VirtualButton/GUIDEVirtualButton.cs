using System;
using System.Collections.Generic;
using Godot;

namespace Guide;

[Tool]
[Icon("res://addons/GuideCS/UI/VirtualJoy/VirtualButton/GuideVirtualButton.svg")]
public partial class GUIDEVirtualButton : GUIDEVirtualJoyBase {
	private float _buttonRadius = 100;
	[Export]
	public float ButtonRadius {
		get => _buttonRadius;
		set {
			_buttonRadius = value;
			QueueRedraw();
			EmitSignal(SignalName.ConfigurationChanged);
		}
	}

	private JoyButton _buttonIndex = JoyButton.A;
	[Export]
	public JoyButton ButtonIndexValue {
		get => _buttonIndex;
		set {
			_buttonIndex = value;
			EmitSignal(SignalName.ConfigurationChanged);
		}
	}

	private Dictionary<int, Vector2> _fingerPositions = new();
	private bool _mouseDownConsumed = false;

	public override void _Ready() {
		UseTopLeft = true;
		MouseFilter = MouseFilterEnum.Ignore;
		Size = Vector2.Zero;

		if (Engine.IsEditorHint()) {
			SetDeferred(Control.PropertyName.Size, Vector2.Zero);
		}

		EmitSignal(SignalName.ConfigurationChanged);
		EmitSignal(SignalName.Changed);

		if (Engine.IsEditorHint()) return;

		_Reconnect();
		_ReportInput();
	}

	protected override void _HandleMouseInput(InputEventMouse @event) {
		var pos = _ScreenToWorld(@event.Position);
		if (!_isActuated) {
			if (@event is InputEventMouseMotion) {
				if (Input.IsMouseButtonPressed(MouseButton.Left)) {
					_TryActuate(pos);
					if (_IsOverButton(pos)) {
						GetViewport().SetInputAsHandled();
					}
				}
				return;
			}

			if (@event is InputEventMouseButton mouseButton && mouseButton.Pressed && mouseButton.ButtonIndex == MouseButton.Left) {
				_TryActuate(pos);
				if (_IsOverButton(pos)) {
					_mouseDownConsumed = true;
					GetViewport().SetInputAsHandled();
				}
			}
			return;
		}

		if (@event is InputEventMouseMotion) {
			if (!_IsOverButton(pos)) {
				_Release();
			}
			GetViewport().SetInputAsHandled();
			return;
		}

		if (@event is InputEventMouseButton mouseBtn && !mouseBtn.Pressed && mouseBtn.ButtonIndex == MouseButton.Left) {
			_Release();
			GetViewport().SetInputAsHandled();
		}
	}

	protected override void _HandleTouchInput(InputEvent @event) {
		if (@event is InputEventScreenTouch screenTouch) {
			if (screenTouch.Pressed) {
				_fingerPositions[screenTouch.Index] = screenTouch.Position;
			}
			else {
				_fingerPositions.Remove(screenTouch.Index);
			}
		}
		else if (@event is InputEventScreenDrag screenDrag) {
			_fingerPositions[screenDrag.Index] = screenDrag.Position;
		}

		if (_IsOverButton(@event.GetType().GetProperty("Position")?.GetValue(@event) as Vector2? ?? Vector2.Zero)) {
			GetViewport().SetInputAsHandled();
		}

		if (!_isActuated) {
			foreach (var position in _fingerPositions.Values) {
				var pos = _ScreenToWorld(position);
				_TryActuate(pos);
			}
			return;
		}

		foreach (var position in _fingerPositions.Values) {
			var pos = _ScreenToWorld(position);
			if (_IsOverButton(pos)) return;
		}

		_Release();
	}

	private bool _IsOverButton(Vector2 worldPosition) {
		return GlobalPosition.DistanceSquaredTo(worldPosition) <= ButtonRadius * ButtonRadius;
	}

	private void _TryActuate(Vector2 worldPosition) {
		if (!_isActuated && _IsOverButton(worldPosition)) {
			_isActuated = true;
			_ReportInput();
		}
	}

	private void _Release() {
		if (_isActuated) {
			_isActuated = false;
			_ReportInput();
		}
	}

	private void _ReportInput() {
		var @event = new InputEventJoypadButton();
		@event.ButtonIndex = ButtonIndexValue;
		@event.Pressed = _isActuated;
		@event.Device = _virtualJoyId;
		GUIDE.Singleton?.InjectInput(@event);
		if (DrawDebug) QueueRedraw();
		EmitSignal(SignalName.Changed);
	}

	public override void _Draw() {
		if (!DrawDebug) return;
		var color = _isActuated ? new Color(0.9f, 0.9f, 0.9f, 0.8f) : new Color(0.5f, 0.5f, 0.5f, 0.5f);
		DrawCircle(Vector2.Zero, ButtonRadius, color);
	}
}
