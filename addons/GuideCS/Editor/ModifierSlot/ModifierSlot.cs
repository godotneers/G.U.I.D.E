using System;
using Godot;

namespace Guide;

[Tool]
public partial class ModifierSlot : ResourceSlot {
	public GUIDEModifier Modifier {
		get => _value as GUIDEModifier;
		set => Value = value;
	}

	protected override bool _AcceptsDropData(Resource data) => data is GUIDEModifier;
}
