using System;
using Godot;

namespace Guide;

[Tool]
[GlobalClass]
public partial class GUIDEModifierPositiveNegative : GUIDEModifier {
	public enum LimitRange {
		Positive = 1,
		Negative = 2
	}

	private LimitRange _range = LimitRange.Positive;
	[Export]
	public LimitRange Range {
		get => _range;
		set {
			_range = value;
			EmitChanged();
		}
	}

	private bool _x = true;
	[Export]
	public bool X {
		get => _x;
		set {
			if (_x == value) return;
			_x = value;
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
			EmitChanged();
		}
	}

	public override bool IsSameAs(GUIDEModifier other) {
		return other is GUIDEModifierPositiveNegative otherPN &&
			   Range == otherPN.Range &&
			   X == otherPN.X &&
			   Y == otherPN.Y &&
			   Z == otherPN.Z;
	}

	public override Vector3 _ModifyInput(Vector3 input, float delta, GUIDEAction.GUIDEActionValueType valueType) {
		if (!input.IsFinite()) return Vector3.Inf;

		switch (Range) {
			case LimitRange.Positive:
				return new Vector3(
					X ? Math.Max(0, input.X) : input.X,
					Y ? Math.Max(0, input.Y) : input.Y,
					Z ? Math.Max(0, input.Z) : input.Z
				);
			case LimitRange.Negative:
				return new Vector3(
					X ? Math.Min(0, input.X) : input.X,
					Y ? Math.Min(0, input.Y) : input.Y,
					Z ? Math.Min(0, input.Z) : input.Z
				);
			default:
				return input;
		}
	}

	public override string _EditorName() => "Positive/Negative";

	public override string _EditorDescription() => "Clamps the input to positive or negative values.";
}
