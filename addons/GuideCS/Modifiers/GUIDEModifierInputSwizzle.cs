using System;
using Godot;

namespace Guide;

[Tool]
[GlobalClass]
public partial class GUIDEModifierInputSwizzle : GUIDEModifier {
	public enum GUIDEInputSwizzleOperation {
		YXZ,
		ZYX,
		XZY,
		YZX,
		ZXY
	}

	[Export] public GUIDEInputSwizzleOperation Order { get; set; } = GUIDEInputSwizzleOperation.YXZ;

	public override bool IsSameAs(GUIDEModifier other) {
		return other is GUIDEModifierInputSwizzle otherSwizzle && Order == otherSwizzle.Order;
	}

	public override Vector3 _ModifyInput(Vector3 input, float delta, GUIDEAction.GUIDEActionValueType valueType) {
		switch (Order) {
			case GUIDEInputSwizzleOperation.YXZ:
				return new Vector3(input.Y, input.X, input.Z);
			case GUIDEInputSwizzleOperation.ZYX:
				return new Vector3(input.Z, input.Y, input.X);
			case GUIDEInputSwizzleOperation.XZY:
				return new Vector3(input.X, input.Z, input.Y);
			case GUIDEInputSwizzleOperation.YZX:
				return new Vector3(input.Y, input.Z, input.X);
			case GUIDEInputSwizzleOperation.ZXY:
				return new Vector3(input.Z, input.X, input.Y);
			default:
				GD.PushError($"Unknown order {Order} this is most likely a bug, please report it.");
				return input;
		}
	}

	public override string _EditorName() => "Input Swizzle";

	public override string _EditorDescription() => "Swizzle the input vector components. Useful to map 1D input to 2D or vice versa.";
}
