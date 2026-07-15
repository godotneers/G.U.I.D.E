using System;
using Godot;

namespace Guide;

[Tool]
[GlobalClass, Icon("res://addons/GuideCS/Triggers/GUIDETrigger.svg")]
public partial class GUIDETrigger : Resource, IEditorDescription {
	public enum GUIDETriggerState {
		None,
		Ongoing,
		Triggered
	}

	public enum GUIDETriggerType {
		Explicit = 1,
		Implicit = 2,
		Blocking = 3
	}

	[Export]
	public float ActuationThreshold { get; set; } = 0.5f;

	internal Vector3 _LastValue;

	public virtual bool IsSameAs(GUIDETrigger other) => this == other;

	public virtual GUIDETriggerType _GetTriggerType() => GUIDETriggerType.Explicit;

	public virtual GUIDETriggerState _UpdateState(Vector3 input, float delta, GUIDEAction.GUIDEActionValueType valueType) => GUIDETriggerState.None;

	public bool _IsActuated(Vector3 input, GUIDEAction.GUIDEActionValueType valueType) {
		switch (valueType) {
			case GUIDEAction.GUIDEActionValueType.Axis1D:
			case GUIDEAction.GUIDEActionValueType.Bool:
				return _IsAxis1DActuated(input);
			case GUIDEAction.GUIDEActionValueType.Axis2D:
				return _IsAxis2DActuated(input);
			case GUIDEAction.GUIDEActionValueType.Axis3D:
				return _IsAxis3DActuated(input);
		}
		return false;
	}

	protected bool _IsAxis1DActuated(Vector3 input) {
		return float.IsFinite(input.X) && Math.Abs(input.X) > ActuationThreshold;
	}

	protected bool _IsAxis2DActuated(Vector3 input) {
		return float.IsFinite(input.X) && float.IsFinite(input.Y) && new Vector2(input.X, input.Y).LengthSquared() > ActuationThreshold * ActuationThreshold;
	}

	protected bool _IsAxis3DActuated(Vector3 input) {
		return input.IsFinite() && input.LengthSquared() > ActuationThreshold * ActuationThreshold;
	}

	public virtual string _EditorName() => "GUIDETrigger";

	public virtual string _EditorDescription() => "";
}
