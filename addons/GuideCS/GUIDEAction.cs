using System;
using Godot;

namespace Guide;

[Tool]
[GlobalClass, Icon("res://addons/GuideCS/GUIDEAction.svg")]
public partial class GUIDEAction : Resource {
	public enum GUIDEActionValueType {
		Bool = 0,
		Axis1D = 1,
		Axis2D = 2,
		Axis3D = 3
	}

	public enum GUIDEActionState {
		Triggered,
		Ongoing,
		Completed
	}

	private StringName _name;
	[Export]
	public StringName Name {
		get => _name;
		set {
			if (_name == value) return;
			_name = value;
			EmitChanged();
		}
	}

	private GUIDEActionValueType _actionValueType = GUIDEActionValueType.Bool;
	[Export]
	public GUIDEActionValueType ActionValueType {
		get => _actionValueType;
		set {
			if (_actionValueType == value) return;
			_actionValueType = value;
			EmitChanged();
		}
	}

	private bool _blockLowerPriorityActions = true;
	[Export]
	public bool BlockLowerPriorityActions {
		get => _blockLowerPriorityActions;
		set {
			if (_blockLowerPriorityActions == value) return;
			_blockLowerPriorityActions = value;
			EmitChanged();
		}
	}

	[ExportGroup("Godot Actions")]
	private bool _emitAsGodotActions = false;
	[Export]
	public bool EmitAsGodotActions {
		get => _emitAsGodotActions;
		set {
			if (_emitAsGodotActions == value) return;
			_emitAsGodotActions = value;
			EmitChanged();
		}
	}

	[ExportGroup("Action Remapping")]
	private bool _isRemappable;
	[Export]
	public bool IsRemappable {
		get => _isRemappable;
		set {
			if (_isRemappable == value) return;
			_isRemappable = value;
			EmitChanged();
		}
	}

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

	private string _displayCategory;
	[Export]
	public string DisplayCategory {
		get => _displayCategory;
		set {
			if (_displayCategory == value) return;
			_displayCategory = value;
			EmitChanged();
		}
	}

	[Signal]
	public delegate void TriggeredEventHandler();

	[Signal]
	public delegate void StartedEventHandler();

	[Signal]
	public delegate void OngoingEventHandler();

	[Signal]
	public delegate void CompletedEventHandler();

	[Signal]
	public delegate void CancelledEventHandler();

	public GUIDEActionState LastState { get; internal set; } = GUIDEActionState.Completed;

	public bool ValueBool { get; private set; }
	public float ValueAxis1D => Value.X;
	public Vector2 ValueAxis2D { get; private set; } = Vector2.Zero;
	public Vector3 Value { get; private set; } = Vector3.Zero;

	public float ElapsedSeconds { get; private set; }
	public float ElapsedRatio { get; private set; }
	public float TriggeredSeconds { get; private set; }

	internal float _triggerHoldThreshold = -1.0f;

	internal void _Triggered(Vector3 value, float delta) {
		TriggeredSeconds += delta;
		ElapsedRatio = 1.0f;
		_UpdateValue(value);
		LastState = GUIDEActionState.Triggered;
		EmitSignal(SignalName.Triggered);
		_EmitGodotActionMaybe(true);
	}

	internal void _Started(Vector3 value) {
		ElapsedRatio = 0.0f;
		_UpdateValue(value);
		LastState = GUIDEActionState.Ongoing;
		EmitSignal(SignalName.Started);
		EmitSignal(SignalName.Ongoing);
	}

	internal void _Ongoing(Vector3 value, float delta) {
		ElapsedSeconds += delta;
		if (_triggerHoldThreshold > 0) {
			ElapsedRatio = ElapsedSeconds / _triggerHoldThreshold;
		}
		_UpdateValue(value);
		bool wasTriggered = LastState == GUIDEActionState.Triggered;
		LastState = GUIDEActionState.Ongoing;
		EmitSignal(SignalName.Ongoing);
		if (wasTriggered) {
			_EmitGodotActionMaybe(false);
		}
	}

	internal void _Cancelled(Vector3 value) {
		ElapsedSeconds = 0;
		ElapsedRatio = 0;
		_UpdateValue(value);
		LastState = GUIDEActionState.Completed;
		EmitSignal(SignalName.Cancelled);
		EmitSignal(SignalName.Completed);
	}

	internal void _Completed(Vector3 value) {
		ElapsedSeconds = 0;
		ElapsedRatio = 0;
		TriggeredSeconds = 0;
		_UpdateValue(value);
		LastState = GUIDEActionState.Completed;
		EmitSignal(SignalName.Completed);
		_EmitGodotActionMaybe(false);
	}

	private void _EmitGodotActionMaybe(bool pressed) {
		if (!EmitAsGodotActions) return;

		if (string.IsNullOrEmpty(Name)) {
			GD.PushError("Cannot emit action into Godot's system because name is empty.");
			return;
		}

		var godotAction = new InputEventAction();
		godotAction.Action = Name;
		godotAction.Strength = Value.X;
		godotAction.Pressed = pressed;
		Input.ParseInputEvent(godotAction);
	}

	internal void _UpdateValue(Vector3 value) {
		switch (ActionValueType) {
			case GUIDEActionValueType.Bool:
			case GUIDEActionValueType.Axis1D:
				ValueBool = Math.Abs(value.X) > 0;
				ValueAxis2D = new Vector2(Math.Abs(value.X), 0);
				Value = new Vector3(value.X, 0, 0);
				break;
			case GUIDEActionValueType.Axis2D:
				ValueBool = Math.Abs(value.X) > 0;
				ValueAxis2D = new Vector2(value.X, value.Y);
				Value = new Vector3(value.X, value.Y, 0);
				break;
			case GUIDEActionValueType.Axis3D:
				ValueBool = Math.Abs(value.X) > 0;
				ValueAxis2D = new Vector2(value.X, value.Y);
				Value = value;
				break;
		}
	}

	public bool IsTriggered() => LastState == GUIDEActionState.Triggered;
	public bool IsCompleted() => LastState == GUIDEActionState.Completed;
	public bool IsOngoing() => LastState == GUIDEActionState.Ongoing;

	public string EditorName() {
		if (!string.IsNullOrEmpty(DisplayName)) return DisplayName;
		if (!string.IsNullOrEmpty(Name)) return Name;
		return ResourcePath.GetFile().Replace(".tres", "");
	}
}
