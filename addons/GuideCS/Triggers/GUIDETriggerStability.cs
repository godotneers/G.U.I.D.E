using System;
using Godot;

namespace Guide;

[Tool]
[GlobalClass]
public partial class GUIDETriggerStability : GUIDETrigger {
	public enum TriggerWhen {
		InputIsStable,
		InputChanges
	}

	[Export] public float MaxDeviation { get; set; } = 1.0f;
	[Export] public TriggerWhen TriggerWhenValue { get; set; } = TriggerWhen.InputIsStable;

	private Vector3 _initialValue;
	private bool _deviated = false;

	public override bool IsSameAs(GUIDETrigger other) {
		return other is GUIDETriggerStability otherStability &&
			   TriggerWhenValue == otherStability.TriggerWhenValue &&
			   Mathf.IsEqualApprox(MaxDeviation, otherStability.MaxDeviation);
	}

	public override GUIDETriggerType _GetTriggerType() => GUIDETriggerType.Implicit;

	public override GUIDETriggerState _UpdateState(Vector3 input, float delta, GUIDEAction.GUIDEActionValueType valueType) {
		if (_IsActuated(input, valueType)) {
			if (_deviated) {
				if (TriggerWhenValue == TriggerWhen.InputIsStable) return GUIDETriggerState.None;
				return GUIDETriggerState.Triggered;
			}

			if (!_IsActuated(_LastValue, valueType)) {
				_initialValue = input;
				if (TriggerWhenValue == TriggerWhen.InputIsStable) return GUIDETriggerState.Triggered;
				return GUIDETriggerState.Ongoing;
			}

			if (_initialValue.DistanceSquaredTo(input) > (MaxDeviation * MaxDeviation)) {
				_deviated = true;
				if (TriggerWhenValue == TriggerWhen.InputIsStable) return GUIDETriggerState.None;
				return GUIDETriggerState.Triggered;
			}

			if (TriggerWhenValue == TriggerWhen.InputIsStable) return GUIDETriggerState.Triggered;
			return GUIDETriggerState.Ongoing;
		}

		_deviated = false;
		return GUIDETriggerState.None;
	}

	public override string _EditorName() => "Stability";

	public override string _EditorDescription() => "Triggers depending on whether the input changes while actuated. This trigger\nis implicit, so it must succeed for all other triggers to succeed.";
}
