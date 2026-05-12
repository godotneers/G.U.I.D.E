using System;
using Godot;

namespace Guide;

[Tool]
[GlobalClass]
public partial class GUIDETriggerTap : GUIDETrigger {
	[Export] public float TapThreshold { get; set; } = 0.2f;

	private float _accumulatedTime = 0;

	public override bool IsSameAs(GUIDETrigger other) {
		return other is GUIDETriggerTap otherTap &&
			   Mathf.IsEqualApprox(TapThreshold, otherTap.TapThreshold);
	}

	public override GUIDETriggerState _UpdateState(Vector3 input, float delta, GUIDEAction.GUIDEActionValueType valueType) {
		if (_IsActuated(input, valueType)) {
			if (_IsActuated(_LastValue, valueType) && _accumulatedTime > TapThreshold) {
				return GUIDETriggerState.None;
			}

			_accumulatedTime += delta;

			if (_accumulatedTime < TapThreshold) {
				return GUIDETriggerState.Ongoing;
			}
			else {
				return GUIDETriggerState.None;
			}
		}
		else {
			if (_IsActuated(_LastValue, valueType)) {
				if (_accumulatedTime < TapThreshold) {
					_accumulatedTime = 0;
					return GUIDETriggerState.Triggered;
				}
				_accumulatedTime = 0;
			}
			return GUIDETriggerState.None;
		}
	}

	public override string _EditorName() => "Tap";

	public override string _EditorDescription() => "Fires when the input is actuated and released within the given timeframe.";
}
