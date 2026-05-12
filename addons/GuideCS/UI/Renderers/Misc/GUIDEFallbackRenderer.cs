using System;
using Godot;

namespace Guide;

[Tool]
public partial class GUIDEFallbackRenderer : GUIDEIconRenderer {
	public GUIDEFallbackRenderer() {
		Priority = 100;
	}

	public override bool Supports(GUIDEInput input, GUIDEInputFormattingOptions options) => true;

	public override void Render(GUIDEInput input, GUIDEInputFormattingOptions options) { }

	public override string CacheKey(GUIDEInput input, GUIDEInputFormattingOptions options) {
		return "2e130e8b-d5b3-478c-af65-53415adfd6bb";
	}
}
