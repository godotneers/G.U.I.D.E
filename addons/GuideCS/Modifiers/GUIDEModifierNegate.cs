using System;
using Godot;

namespace Guide;

[Tool]
[GlobalClass]
public partial class GUIDEModifierNegate : GUIDEModifier {
	private bool _x = true;
	[Export]
	public bool X {
		get => _x;
		set {
			if (_x == value) return;
			_x = value;
			_UpdateCaches();
			EmitChanged();
		}
	}

	private bool _y = true;
	[Export]
	public bool Y {
		get => _y;
		set {
			if (_y == value) return;
			_y = value;
			_UpdateCaches();
			EmitChanged();
		}
	}

	private bool _z = true;
	[Export]
	public bool Z {
		get => _z;
		set {
			if (_z == value) return;
			_z = value;
			_UpdateCaches();
			EmitChanged();
		}
	}

	private Vector3 _multiplier = new Vector3(-1, -1, -1);

	public override bool IsSameAs(GUIDEModifier other) {
		return other is GUIDEModifierNegate otherNeg &&
			   X == otherNeg.X &&
			   Y == otherNeg.Y &&
			   Z == otherNeg.Z;
	}

	private void _UpdateCaches() {
		_multiplier = new Vector3(X ? -1 : 1, Y ? -1 : 1, Z ? -1 : 1);
	}

	public override Vector3 _ModifyInput(Vector3 input, float delta, GUIDEAction.GUIDEActionValueType valueType) {
		if (!input.IsFinite()) return Vector3.Inf;
		return input * _multiplier;
	}

	public override string _EditorName() => "Negate";

	public override string _EditorDescription() => "Inverts input per axis.";
}
