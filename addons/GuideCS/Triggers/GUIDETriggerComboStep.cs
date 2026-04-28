using Godot;

namespace Guide;

[GlobalClass, Icon("res://addons/GuideCS/GUIDEInternal.svg")]
public partial class GUIDETriggerComboStep : Resource {
	[Export] public GUIDEAction Action { get; set; }

	[Export(PropertyHint.Flags, "Triggered:1,Started:2,Ongoing:4,Cancelled:8,Completed:16")]
	public int CompletionEvents { get; set; } = (int)GUIDETriggerCombo.ActionEventType.Triggered;

	[Export] public float TimeToActuate { get; set; } = 0.5f;

	public bool IsSameAs(GUIDETriggerComboStep other) {
		return Action == other.Action &&
			   CompletionEvents == other.CompletionEvents &&
			   Mathf.IsEqualApprox(TimeToActuate, other.TimeToActuate);
	}

	internal bool _hasFired = false;

	internal void _Prepare() {
		if ((CompletionEvents & (int)GUIDETriggerCombo.ActionEventType.Triggered) != 0) Action.Triggered += _Fired;
		if ((CompletionEvents & (int)GUIDETriggerCombo.ActionEventType.Started) != 0) Action.Started += _Fired;
		if ((CompletionEvents & (int)GUIDETriggerCombo.ActionEventType.Ongoing) != 0) Action.Ongoing += _Fired;
		if ((CompletionEvents & (int)GUIDETriggerCombo.ActionEventType.Cancelled) != 0) Action.Cancelled += _Fired;
		if ((CompletionEvents & (int)GUIDETriggerCombo.ActionEventType.Completed) != 0) Action.Completed += _Fired;
		_hasFired = false;
	}

	private void _Fired() {
		_hasFired = true;
	}
}
