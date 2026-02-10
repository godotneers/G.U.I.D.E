using System;
using Godot;

namespace Guide;

[Tool]
[GlobalClass, Icon("res://addons/GuideCS/Modifiers/GUIDEModifier.svg")]
public partial class GUIDEModifier : Resource, IEditorDescription {
	public virtual bool IsSameAs(GUIDEModifier other) => this == other;

	public virtual void _BeginUsage() { }

	public virtual void _EndUsage() { }

	public virtual Vector3 _ModifyInput(Vector3 input, float delta, GUIDEAction.GUIDEActionValueType valueType) => input;

	public virtual string _EditorName() => "";

	public virtual string _EditorDescription() => "";

	public virtual bool _NeedsPhysicsProcess() => false;

	public virtual void _PhysicsProcess(float delta) { }
}
