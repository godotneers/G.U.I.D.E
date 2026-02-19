using System;
using Godot;

namespace Guide;

[Tool]
[GlobalClass]
public partial class GUIDETriggerHold : GUIDETrigger {
	[Export]
	public float HoldTreshold { get; set; } = 1.0f;

	[Export]
	public bool IsOneShot { get; set; } = false;

	private float _accumulatedTime = 0;
	private bool _didShoot = false;

	public override bool IsSameAs(GUIDETrigger other) {
		return other is GUIDETriggerHold hold &&
			   IsOneShot == hold.IsOneShot &&
			   Mathf.IsEqualApprox(HoldTreshold, hold.HoldTreshold);
	}

	public override GUIDETriggerState _UpdateState(Vector3 input, float delta, GUIDEAction.GUIDEActionValueType valueType) {
		if (_IsActuated(input, valueType)) {
			_accumulatedTime += delta;

			if (_accumulatedTime >= HoldTreshold) {
				if (IsOneShot && _didShoot) return GUIDETriggerState.None;
				else {
					_didShoot = true;
					return GUIDETriggerState.Triggered;
				}
			}
			else return GUIDETriggerState.Ongoing;
		}
		else {
			_accumulatedTime = 0;
			_didShoot = false;
			return GUIDETriggerState.None;
		}
	}

	public override string _EditorName() => "Hold";

	public override string _EditorDescription() => "Fires, once the input has remained actuated for hold_threshold seconds.\nMy fire once or repeatedly.";
}
