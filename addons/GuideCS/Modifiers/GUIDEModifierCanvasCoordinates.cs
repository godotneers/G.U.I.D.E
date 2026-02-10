using Godot;

namespace Guide;

[Tool]
[GlobalClass]
public partial class GUIDEModifierCanvasCoordinates : GUIDEModifier {
	private bool _relativeInput;
	[Export]
	public bool RelativeInput {
		get => _relativeInput;
		set {
			_relativeInput = value;
			EmitChanged();
		}
	}

	public override bool IsSameAs(GUIDEModifier other) {
		return other is GUIDEModifierCanvasCoordinates otherCanvas &&
			   RelativeInput == otherCanvas.RelativeInput;
	}

	public override Vector3 _ModifyInput(Vector3 input, float delta, GUIDEAction.GUIDEActionValueType valueType) {
		if (!input.IsFinite()) return Vector3.Inf;

		if (Engine.GetMainLoop() is not SceneTree tree) return Vector3.Inf;
		var viewport = tree.Root;
		var transform = viewport.CanvasTransform.AffineInverse();
		var coordinates = transform * new Vector2(input.X, input.Y);

		if (RelativeInput) {
			var origin = transform * Vector2.Zero;
			coordinates -= origin;
		}

		return new Vector3(coordinates.X, coordinates.Y, input.Z);
	}

	public override string _EditorName() => "Canvas coordinates";

	public override string _EditorDescription() => "Converts a position input in viewport coordinates (e.g. from the mouse position input)\ninto canvas coordinates (e.g. 2D world coordinates). Useful to get a 2D 'world' position.";
}
