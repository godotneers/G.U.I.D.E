using Godot;

namespace Guide;

[Tool]
[GlobalClass]
public partial class GUIDETriggerReleased : GUIDETrigger {
	public override bool IsSameAs(GUIDETrigger other) => other is GUIDETriggerReleased;

	public override GUIDETriggerState _UpdateState(Vector3 input, float delta, GUIDEAction.GUIDEActionValueType valueType) {
		if (!_IsActuated(input, valueType)) {
			if (_IsActuated(_LastValue, valueType)) return GUIDETriggerState.Triggered;
		}
		return GUIDETriggerState.None;
	}

	public override string _EditorName() => "Released";

	public override string _EditorDescription() => "Fires once, when the input goes from actuated to not actuated. The opposite of the Pressed trigger.";
}
