using System;
using Godot;

namespace Guide;

[Tool]
[Icon("res://addons/GuideCS/UI/VirtualJoy/VirtualStick/GuideVirtualStick.svg")]
public partial class GUIDEVirtualStick : GUIDEVirtualJoyBase {
	public enum PositionMode {
		Fixed,
		Relative
	}

	public enum StickPosition {
		Left,
		Right
	}

	private float _interactionZoneRadius = 200;
	[Export]
	public float InteractionZoneRadius {
		get => _interactionZoneRadius;
		set {
			_interactionZoneRadius = value;
			QueueRedraw();
			EmitSignal(SignalName.ConfigurationChanged);
		}
	}

	private float _stickRadius = 100;
	[Export]
	public float StickRadius {
		get => _stickRadius;
		set {
			_stickRadius = value;
			QueueRedraw();
			EmitSignal(SignalName.ConfigurationChanged);
		}
	}

	private float _maxActuationRadius = 100;
	[Export]
	public float MaxActuationRadius {
		get => _maxActuationRadius;
		set {
			_maxActuationRadius = value;
			QueueRedraw();
			EmitSignal(SignalName.ConfigurationChanged);
		}
	}

	private StickPosition _stickPosition = StickPosition.Left;
	[Export]
	public StickPosition StickPositionValue {
		get => _stickPosition;
		set {
			_stickPosition = value;
			EmitSignal(SignalName.ConfigurationChanged);
		}
	}

	private PositionMode _positionMode = PositionMode.Fixed;
	[Export]
	public PositionMode PositionModeValue {
		get => _positionMode;
		set {
			_positionMode = value;
			EmitSignal(SignalName.ConfigurationChanged);
		}
	}

	private Vector2 _initialPos;
	internal Vector2 _startPos;
	internal Vector2 _currentPos;
	private int _fingerIndex = -1;

	public Vector2 StickRelativePosition => _currentPos - _startPos;

	public override void _Ready() {
		UseTopLeft = true;
		Size = Vector2.Zero;
		if (Engine.IsEditorHint()) {
			SetDeferred(Control.PropertyName.Size, Vector2.Zero);
		}
		_initialPos = GlobalPosition;
		_startPos = GlobalPosition;
		_currentPos = GlobalPosition;
		MouseFilter = MouseFilterEnum.Ignore;

		EmitSignal(SignalName.ConfigurationChanged);
		EmitSignal(SignalName.Changed);

		if (Engine.IsEditorHint()) return;

		_Reconnect();
		_ReportInput();
	}

	protected override void _HandleMouseInput(InputEventMouse @event) {
		if (!_isActuated) {
			if (@event is InputEventMouseMotion) return;

			if (@event is InputEventMouseButton mouseButton && mouseButton.Pressed && mouseButton.ButtonIndex == MouseButton.Left) {
				var pos = _ScreenToWorld(mouseButton.Position);
				_TryActuate(pos);
				if (_isActuated) {
					GetViewport().SetInputAsHandled();
				}
			}
			return;
		}

		if (@event is InputEventMouseMotion mouseMotion) {
			var pos = _ScreenToWorld(mouseMotion.Position);
			_MoveTowards(pos);
			GetViewport().SetInputAsHandled();
			return;
		}

		if (@event is InputEventMouseButton mouseBtn && !mouseBtn.Pressed && mouseBtn.ButtonIndex == MouseButton.Left) {
			_Release();
			GetViewport().SetInputAsHandled();
		}
	}

	protected override void _HandleTouchInput(InputEvent @event) {
		if (!_isActuated) {
			if (@event is InputEventScreenDrag) return;

			if (@event is InputEventScreenTouch screenTouch && screenTouch.Pressed) {
				var pos = _ScreenToWorld(screenTouch.Position);
				_TryActuate(pos);
				if (_isActuated) {
					_fingerIndex = screenTouch.Index;
					GetViewport().SetInputAsHandled();
				}
			}
			return;
		}

		if (@event is InputEventScreenDrag screenDrag && screenDrag.Index == _fingerIndex) {
			var pos = _ScreenToWorld(screenDrag.Position);
			_MoveTowards(pos);
			GetViewport().SetInputAsHandled();
			return;
		}

		if (@event is InputEventScreenTouch touchEvent && touchEvent.Index == _fingerIndex && !touchEvent.Pressed) {
			_Release();
			GetViewport().SetInputAsHandled();
			_fingerIndex = -1;
		}
	}

	private void _TryActuate(Vector2 worldPosition) {
		switch (PositionModeValue) {
			case PositionMode.Fixed:
				if (worldPosition.DistanceTo(GlobalPosition) > StickRadius) return;
				_startPos = GlobalPosition;
				_currentPos = worldPosition;
				_isActuated = true;
				_ReportInput();
				break;

			case PositionMode.Relative:
				if (worldPosition.DistanceTo(GlobalPosition) > InteractionZoneRadius) return;
				GlobalPosition = worldPosition;
				_startPos = worldPosition;
				_currentPos = worldPosition;
				_isActuated = true;
				_ReportInput();
				break;
		}
	}

	private void _MoveTowards(Vector2 worldPosition) {
		var direction = _startPos.DirectionTo(worldPosition);
		var distance = _startPos.DistanceTo(worldPosition);
		_currentPos = _startPos + direction * Math.Min(distance, MaxActuationRadius);
		_ReportInput();
	}

	private void _Release() {
		_isActuated = false;
		GlobalPosition = _initialPos;
		_startPos = GlobalPosition;
		_currentPos = GlobalPosition;
		_ReportInput();
	}

	private void _ReportInput() {
		var direction = Vector2.Zero;
		if (!_startPos.IsEqualApprox(_currentPos)) {
			direction = _startPos.DirectionTo(_currentPos);
		}

		var distance = _startPos.DistanceTo(_currentPos);
		var offset = direction * (distance / MaxActuationRadius);

		switch (StickPositionValue) {
			case StickPosition.Left:
				_SendEvent(JoyAxis.LeftX, offset.X);
				_SendEvent(JoyAxis.LeftY, offset.Y);
				break;
			case StickPosition.Right:
				_SendEvent(JoyAxis.RightX, offset.X);
				_SendEvent(JoyAxis.RightY, offset.Y);
				break;
		}

		if (DrawDebug) QueueRedraw();
		EmitSignal(SignalName.Changed);
	}

	private void _SendEvent(JoyAxis axis, float value) {
		var @event = new InputEventJoypadMotion();
		@event.Axis = axis;
		@event.AxisValue = value;
		@event.Device = _virtualJoyId;
		GUIDE.Singleton?.InjectInput(@event);
	}

	public override void _Draw() {
		if (!DrawDebug) return;

		DrawCircle(Vector2.Zero, InteractionZoneRadius, new Color(0.5f, 0.5f, 1.0f, 0.5f));
		DrawCircle(Vector2.Zero, MaxActuationRadius, new Color(0.9f, 0.2f, 0.2f, 0.5f));
		DrawCircle(Vector2.Zero, StickRadius, new Color(0.9f, 0.9f, 0.3f, 0.5f));

		if (_isActuated) {
			DrawCircle(StickRelativePosition, StickRadius, new Color(0.9f, 0.9f, 0.7f, 0.5f));
		}
	}

	public override string[] _GetConfigurationWarnings() {
		if (GetParent() is Container) {
			return new[] { "Virtual sticks must be top level elements. They cannot be a child of a container." };
		}
		return Array.Empty<string>();
	}
}
