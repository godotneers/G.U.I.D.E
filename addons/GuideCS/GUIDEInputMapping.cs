using System;
using System.Collections.Generic;
using Godot;

namespace Guide;

[Tool]
[GlobalClass, Icon("res://addons/GuideCS/GUIDEInternal.svg")]
public partial class GUIDEInputMapping : Resource {
	private bool _overrideActionSettings = false;
	[Export]
	public bool OverrideActionSettings {
		get => _overrideActionSettings;
		set {
			if (_overrideActionSettings == value) return;
			_overrideActionSettings = value;
			EmitChanged();
		}
	}

	private bool _isRemappable = false;
	[Export]
	public bool IsRemappable {
		get => _isRemappable;
		set {
			if (_isRemappable == value) return;
			_isRemappable = value;
			EmitChanged();
		}
	}

	private string _displayName = "";
	[Export]
	public string DisplayName {
		get => _displayName;
		set {
			if (_displayName == value) return;
			_displayName = value;
			EmitChanged();
		}
	}

	private string _displayCategory = "";
	[Export]
	public string DisplayCategory {
		get => _displayCategory;
		set {
			if (_displayCategory == value) return;
			_displayCategory = value;
			EmitChanged();
		}
	}

	[ExportGroup("Mappings")]
	private GUIDEInput _input;
	[Export]
	public GUIDEInput Input {
		get => _input;
		set {
			if (_input == value) return;
			_input = value;
			EmitChanged();
		}
	}

	private Godot.Collections.Array<GUIDEModifier> _modifiers = new();
	[Export]
	public Godot.Collections.Array<GUIDEModifier> Modifiers {
		get => _modifiers;
		set {
			if (_modifiers == value) return;
			_modifiers = value;
			EmitChanged();
		}
	}

	private Godot.Collections.Array<GUIDETrigger> _triggers = new();
	[Export]
	public Godot.Collections.Array<GUIDETrigger> Triggers {
		get => _triggers;
		set {
			if (_triggers == value) return;
			_triggers = value;
			EmitChanged();
		}
	}

	internal float _triggerHoldThreshold = -1.0f;
	internal GUIDETrigger.GUIDETriggerState _state = GUIDETrigger.GUIDETriggerState.None;
	internal Vector3 _value = Vector3.Zero;

	private List<GUIDETrigger> _triggerList = new();
	private int _implicitCount = 0;
	private int _explicitCount = 0;

	internal void _Initialize(GUIDEAction.GUIDEActionValueType valueType) {
		_triggerList.Clear();
		_implicitCount = 0;
		_explicitCount = 0;
		_triggerHoldThreshold = -1.0f;

		if (Triggers.Count == 0) {
			var defaultTrigger = new GUIDETriggerDown();
			defaultTrigger.ActuationThreshold = 0;
			_explicitCount = 1;
			_triggerList.Add(defaultTrigger);
			return;
		}

		Vector3 input_value = Input != null ? Input._Value : Vector3.Zero;

		foreach (var modifier in Modifiers) {
			input_value = modifier._ModifyInput(input_value, 0, valueType);
		}

		foreach (var trigger in Triggers) {
			switch (trigger._GetTriggerType()) {
				case GUIDETrigger.GUIDETriggerType.Explicit:
					_explicitCount++;
					break;
				case GUIDETrigger.GUIDETriggerType.Implicit:
					_implicitCount++;
					break;
			}
			_triggerList.Add(trigger);

			if (trigger is GUIDETriggerHold holdTrigger) {
				if (_triggerHoldThreshold == -1) {
					_triggerHoldThreshold = holdTrigger.HoldTreshold;
				}
				else {
					_triggerHoldThreshold = Math.Min(_triggerHoldThreshold, holdTrigger.HoldTreshold);
				}
			}

			trigger._LastValue = input_value;
		}
	}

	internal void _UpdateState(float delta, GUIDEAction.GUIDEActionValueType valueType) {
		Vector3 input_value = Input != null ? Input._Value : Vector3.Zero;

		foreach (var modifier in Modifiers) {
			input_value = modifier._ModifyInput(input_value, delta, valueType);
		}

		_value = input_value;

		int triggeredImplicits = 0;
		int triggeredExplicits = 0;
		int triggeredBlocked = 0;

		GUIDETrigger.GUIDETriggerState result = GUIDETrigger.GUIDETriggerState.None;

		foreach (var trigger in _triggerList) {
			var triggerResult = trigger._UpdateState(_value, delta, valueType);
			trigger._LastValue = _value;

			var triggerType = trigger._GetTriggerType();
			if (triggerResult == GUIDETrigger.GUIDETriggerState.Triggered) {
				switch (triggerType) {
					case GUIDETrigger.GUIDETriggerType.Explicit:
						triggeredExplicits++;
						break;
					case GUIDETrigger.GUIDETriggerType.Implicit:
						triggeredImplicits++;
						break;
					case GUIDETrigger.GUIDETriggerType.Blocking:
						triggeredBlocked++;
						break;
				}
			}

			if (triggerType == GUIDETrigger.GUIDETriggerType.Explicit) {
				result = (GUIDETrigger.GUIDETriggerState)Math.Max((int)result, (int)triggerResult);
			}
		}

		if (triggeredBlocked > 0) {
			_state = GUIDETrigger.GUIDETriggerState.None;
			return;
		}

		if (triggeredImplicits < _implicitCount) {
			_state = GUIDETrigger.GUIDETriggerState.None;
			return;
		}

		if (_explicitCount == 0 && _implicitCount > 0) {
			_state = GUIDETrigger.GUIDETriggerState.Triggered;
			return;
		}

		_state = result;
	}
}
