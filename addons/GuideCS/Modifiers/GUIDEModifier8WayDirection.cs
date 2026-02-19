using Godot;

namespace Guide;

[Tool]
[GlobalClass]
public partial class GUIDEModifier8WayDirection : GUIDEModifier {
	public enum GuideDirection {
		East = 0,
		NorthEast = 1,
		North = 2,
		NorthWest = 3,
		West = 4,
		SouthWest = 5,
		South = 6,
		SouthEast = 7
	}

	[Export] public GuideDirection Direction { get; set; } = GuideDirection.East;

	public override bool IsSameAs(GUIDEModifier other) {
		return other is GUIDEModifier8WayDirection otherDir && Direction == otherDir.Direction;
	}

	public override Vector3 _ModifyInput(Vector3 input, float delta, GUIDEAction.GUIDEActionValueType valueType) {
		if (!input.IsFinite()) return Vector3.Inf;
		if (input.IsZeroApprox()) return Vector3.Zero;

		var angleRadians = Mathf.Atan2(-input.Y, input.X);
		var octant = Mathf.RoundToInt(8 * angleRadians / Mathf.Tau + 8) % 8;

		if (octant == (int)Direction) return Vector3.Right; // (1, 0, 0) indicating boolean true
		else return Vector3.Zero;
	}

	public override string _EditorName() => "8-way direction";

	public override string _EditorDescription() => "Converts a 2D input into a boolean that is true when the\ninput direction matches the selected direction. Note, that north is negative Y,\nbecause in Godot negative Y is up.";
}
