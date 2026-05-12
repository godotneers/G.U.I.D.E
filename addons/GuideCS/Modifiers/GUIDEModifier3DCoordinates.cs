using System;
using Godot;

namespace Guide;

[Tool]
[GlobalClass]
public partial class GUIDEModifier3DCoordinates : GUIDEModifier {
	[Export] public float MaxDepth { get; set; } = 1000.0f;
	[Export] public bool CollideWithAreas { get; set; } = false;
	[Export(PropertyHint.Layers3DPhysics)] public uint CollisionMask { get; set; }

	private Vector3 _input = Vector3.Zero;
	private Vector3 _latestUpdateInput = Vector3.Zero;

	public override bool IsSameAs(GUIDEModifier other) {
		return other is GUIDEModifier3DCoordinates otherCoords &&
			   CollideWithAreas == otherCoords.CollideWithAreas &&
			   CollisionMask == otherCoords.CollisionMask &&
			   Mathf.IsEqualApprox(MaxDepth, otherCoords.MaxDepth);
	}

	public override bool _NeedsPhysicsProcess() => true;

	public override void _PhysicsProcess(float delta) {
		_latestUpdateInput = _UpdateInput(_input);
	}

	public override Vector3 _ModifyInput(Vector3 input, float delta, GUIDEAction.GUIDEActionValueType valueType) {
		_input = input;
		return _latestUpdateInput;
	}

	private Vector3 _UpdateInput(Vector3 input) {
		if (CollisionMask == 0) return Vector3.Inf;
		if (!input.IsFinite()) return Vector3.Inf;

		if (Engine.GetMainLoop() is not SceneTree tree) return Vector3.Inf;
		var viewport = tree.Root;
		var camera = viewport.GetCamera3D();
		if (camera == null) return Vector3.Inf;

		var inputPosition = new Vector2(input.X, input.Y);
		var from = camera.ProjectRayOrigin(inputPosition);
		var to = from + camera.ProjectRayNormal(inputPosition) * MaxDepth;
		var query = PhysicsRayQueryParameters3D.Create(from, to, CollisionMask);
		query.CollideWithAreas = CollideWithAreas;

		var result = viewport.World3D.DirectSpaceState.IntersectRay(query);
		if (result.TryGetValue("position", out var pos)) return (Vector3)pos;

		return Vector3.Inf;
	}

	public override string _EditorName() => "3D coordinates";

	public override string _EditorDescription() => "Converts a position input in viewport coordinates (e.g. from the mouse position input)\ninto 3D coordinates (e.g. 3D world coordinates). Useful to get a 3D 'world' position.";
}
