using Godot;

namespace Guide;

[Tool]
public partial class GUIDEIconRenderer : Control {
	[Export] public int Priority { get; set; } = 0;

	public virtual bool Supports(GUIDEInput input, GUIDEInputFormattingOptions options) => false;

	public virtual void Render(GUIDEInput input, GUIDEInputFormattingOptions options) { }

	public virtual string CacheKey(GUIDEInput input, GUIDEInputFormattingOptions options) {
		GD.PushError("Custom renderers must override the CacheKey function to ensure proper caching.");
		return "i-forgot-the-cache-key";
	}

	public override void _Ready() {
		// Do not mess with the process mode in edited scenes.
		if (EditorUtils.IsNodeInEditedScene(this)) return;
		ProcessMode = ProcessModeEnum.Always;
	}
}
