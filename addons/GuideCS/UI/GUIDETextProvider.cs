using Godot;

namespace Guide;

[Tool]
public partial class GUIDETextProvider : RefCounted {
	[Export] public int Priority { get; set; } = 0;

	public virtual bool Supports(GUIDEInput input, GUIDEInputFormattingOptions options) => false;	

	public virtual string GetText(GUIDEInput input, GUIDEInputFormattingOptions options) => "not implemented";
}
