using System;
using System.Collections.Generic;
using Godot;

namespace Guide;

[Tool]
[GlobalClass]
public partial class GUIDETriggerCombo : GUIDETrigger {
	[Flags]
	public enum ActionEventType {
		Triggered = 1,
		Started = 2,
		Ongoing = 4,
		Cancelled = 8,
		Completed = 16
	}

	[Export] public bool EnableDebugPrint { get; set; } = false;
	[Export] public Godot.Collections.Array<GUIDETriggerComboStep> Steps { get; set; } = new();
	[Export] public Godot.Collections.Array<GUIDETriggerComboCancelAction> CancellationActions { get; set; } = new();

	private int _currentStep = -1;
	private float _remainingTime = 0;

	public override bool IsSameAs(GUIDETrigger other) {
		if (other is not GUIDETriggerCombo combo) return false;
		if (Steps.Count != combo.Steps.Count) return false;
		if (CancellationActions.Count != combo.CancellationActions.Count) return false;

		for (int i = 0; i < Steps.Count; i++) {
			if (!Steps[i].IsSameAs(combo.Steps[i])) return false;
		}

		for (int i = 0; i < CancellationActions.Count; i++) {
			if (!CancellationActions[i].IsSameAs(combo.CancellationActions[i])) return false;
		}

		return true;
	}

	public override GUIDETriggerState _UpdateState(Vector3 input, float delta, GUIDEAction.GUIDEActionValueType valueType) {
		if (Steps.Count == 0) {
			GD.PushWarning("Combo with no steps will never fire.");
			return GUIDETriggerState.None;
		}

		if (_currentStep == -1) {
			foreach (var step in Steps) step._Prepare();
			foreach (var action in CancellationActions) action._Prepare();
			_ResetCombo();
		}

		var currentAction = Steps[_currentStep].Action;
		if (currentAction == null) {
			GD.PushWarning($"Step {_currentStep} has no action {ResourcePath}");
			return GUIDETriggerState.None;
		}

		foreach (var action in CancellationActions) {
			if (action.Action == currentAction) continue;
			if (action._hasFired) {
				if (EnableDebugPrint) GD.Print($"Combo cancelled by action '{action.Action.EditorName()}'.");
				_ResetCombo();
				return GUIDETriggerState.None;
			}
		}

		foreach (var step in Steps) {
			if (step.Action == currentAction) continue;
			if (step._hasFired) {
				if (EnableDebugPrint) GD.Print($"Combo out of order step by action '{step.Action.EditorName()}'.");
				_ResetCombo();
				return GUIDETriggerState.None;
			}
		}

		if (_currentStep > 0) {
			_remainingTime -= delta;
			if (_remainingTime <= 0.0f) {
				if (EnableDebugPrint) GD.Print($"Step time for step {_currentStep} exceeded.");
				_ResetCombo();
				return GUIDETriggerState.None;
			}
		}

		if (Steps[_currentStep]._hasFired) {
			Steps[_currentStep]._hasFired = false;
			if (_currentStep + 1 >= Steps.Count) {
				if (EnableDebugPrint) GD.Print("Combo fired.");
				_ResetCombo();
				return GUIDETriggerState.Triggered;
			}

			_currentStep++;
			if (EnableDebugPrint) GD.Print($"Combo advanced to step {_currentStep}.");
			_remainingTime = Steps[_currentStep].TimeToActuate;

			foreach (var step in Steps) step._hasFired = false;
			foreach (var action in CancellationActions) action._hasFired = false;
		}

		return GUIDETriggerState.Ongoing;
	}

	private void _ResetCombo() {
		if (EnableDebugPrint) GD.Print("Combo reset.");
		_currentStep = 0;
		_remainingTime = Steps[0].TimeToActuate;
		foreach (var step in Steps) step._hasFired = false;
		foreach (var action in CancellationActions) action._hasFired = false;
	}

	public override string _EditorName() => "Combo";

	public override string _EditorDescription() => "Fires, when the input exceeds the actuation threshold.";
}
