using System;
using Godot;

namespace Guide;

[Tool]
[GlobalClass]
public partial class GUIDETriggerPulse : GUIDETrigger {
	[Export] public bool TriggerOnStart { get; set; } = true;

	private float _initialDelay = 0.3f;
	[Export]
	public float InitialDelay {
		get => _initialDelay;
		set => _initialDelay = Math.Max(0, value);
	}

	private float _pulseInterval = 0.1f;
	[Export]
	public float PulseInterval {
		get => _pulseInterval;
		set => _pulseInterval = Math.Max(0, value);
	}

	[Export] public int MaxPulses { get; set; } = 0;

	private float _delayUntilNextPulse = 0;
	private int _emittedPulses = 0;

	public override bool IsSameAs(GUIDETrigger other) {
		return other is GUIDETriggerPulse pulse &&
			   Mathf.IsEqualApprox(InitialDelay, pulse.InitialDelay) &&
			   Mathf.IsEqualApprox(PulseInterval, pulse.PulseInterval) &&
			   MaxPulses == pulse.MaxPulses &&
			   TriggerOnStart == pulse.TriggerOnStart;
	}

	public override GUIDETriggerState _UpdateState(Vector3 input, float delta, GUIDEAction.GUIDEActionValueType valueType) {
		if (_IsActuated(input, valueType)) {
			if (!_IsActuated(_LastValue, valueType)) {
				_delayUntilNextPulse = InitialDelay;
				if (TriggerOnStart) return GUIDETriggerState.Triggered;
				return GUIDETriggerState.Ongoing;
			}

			if (MaxPulses > 0 && _emittedPulses >= MaxPulses) return GUIDETriggerState.None;

			_delayUntilNextPulse -= delta;
			if (_delayUntilNextPulse > 0) return GUIDETriggerState.Ongoing;

			if (Mathf.IsEqualApprox(PulseInterval, 0)) {
				_delayUntilNextPulse = 0;
				if (MaxPulses > 0) _emittedPulses++;
				return GUIDETriggerState.Triggered;
			}

			_delayUntilNextPulse += PulseInterval;
			if (_delayUntilNextPulse <= 0) {
				int skippedPulses = (int)(-_delayUntilNextPulse / PulseInterval);
				_delayUntilNextPulse += skippedPulses * PulseInterval;
				if (MaxPulses > 0) {
					_emittedPulses += skippedPulses;
					if (_emittedPulses >= MaxPulses) return GUIDETriggerState.None;
				}
			}

			if (MaxPulses > 0) _emittedPulses++;
			return GUIDETriggerState.Triggered;
		}

		_emittedPulses = 0;
		_delayUntilNextPulse = 0;
		return GUIDETriggerState.None;
	}

	public override string _EditorName() => "Pulse";

	public override string _EditorDescription() => "Fires at an interval while the input is actuated.";
}
