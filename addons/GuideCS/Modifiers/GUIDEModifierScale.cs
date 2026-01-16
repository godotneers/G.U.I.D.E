using System;
using Godot;

namespace Guide;

[Tool]
[GlobalClass]
public partial class GUIDEModifierScale : GUIDEModifier {
	private Vector3 _scale = Vector3.One;
	[Export]
	public Vector3 Scale {
		get => _scale;
		set {
			_scale = value;
			EmitChanged();
		}
	}

	private bool _applyDeltaTime = false;
	[Export]
	public bool ApplyDeltaTime {
		get => _applyDeltaTime;
		set {
			_applyDeltaTime = value;
			EmitChanged();
		}
	}

	public override bool IsSameAs(GUIDEModifier other) {
		return other is GUIDEModifierScale otherScale &&
			   ApplyDeltaTime == otherScale.ApplyDeltaTime &&
			   Scale.IsEqualApprox(otherScale.Scale);
	}

	public override Vector3 _ModifyInput(Vector3 input, float delta, GUIDEAction.GUIDEActionValueType valueType) {
		if (!input.IsFinite()) return Vector3.Inf;

		if (ApplyDeltaTime) {
			return input * Scale * delta;
		}
		else {
			return input * Scale;
		}
	}

	public override string _EditorName() => "Scale";

	public override string _EditorDescription() => "Scales the input by the given value and optionally, delta time.";
}
