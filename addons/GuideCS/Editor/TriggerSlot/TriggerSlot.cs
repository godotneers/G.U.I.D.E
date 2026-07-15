using System;
using Godot;

namespace Guide;

[Tool]
public partial class TriggerSlot : ResourceSlot {
	public GUIDETrigger Trigger {
		get => _value as GUIDETrigger;
		set => Value = value;
	}

	protected override bool _AcceptsDropData(Resource data) => data is GUIDETrigger;
}
