using System;
using Godot;

namespace Guide;

[Tool]
[GlobalClass]
public partial class GUIDETriggerChordedAction : GUIDETrigger {
	[Export]
	public GUIDEAction Action { get; set; }

	public override bool IsSameAs(GUIDETrigger other) {
		return other is GUIDETriggerChordedAction chorded && Action == chorded.Action;
	}

	public override GUIDETriggerType _GetTriggerType() => GUIDETriggerType.Implicit;

	public override GUIDETriggerState _UpdateState(Vector3 input, float delta, GUIDEAction.GUIDEActionValueType valueType) {
		if (Action == null) {
			GD.PushWarning("Chorded trigger without action will never trigger.");
			return GUIDETriggerState.None;
		}

		if (Action.IsTriggered()) {
			return GUIDETriggerState.Triggered;
		}
		return GUIDETriggerState.None;
	}

	public override string _EditorName() => "Chorded Action";

	public override string _EditorDescription() => "Fires, when the given action is currently triggering. This trigger is implicit,\nso it will prevent the action from triggering even if other triggers are successful.";
}
