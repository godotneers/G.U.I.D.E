using System;
using Godot;

namespace Guide;

[Tool]
public partial class GUIDEActionRenderer : GUIDEIconRenderer {
	public override bool Supports(GUIDEInput input, GUIDEInputFormattingOptions options) {
		return input is GUIDEInputAction;
	}

	public override void Render(GUIDEInput input, GUIDEInputFormattingOptions options) { }

	public override string CacheKey(GUIDEInput input, GUIDEInputFormattingOptions options) {
		return "0ecd6608-ba3c-4fc2-83f7-ad61736f1106";
	}
}
