using System;
using Godot;

namespace Guide;

[Tool]
[GlobalClass, Icon("res://addons/GuideCS/Inputs/GUIDEInput.svg")]
public partial class GUIDEInput : Resource {
	[Flags]
	public enum DeviceType {
		None = 0,
		Keyboard = 1,
		Mouse = 2,
		Joy = 4,
		Touch = 8,
	}

	public DeviceType DeviceTypeValue => _DeviceType();

	public Vector3 _Value { get; internal set; } = Vector3.Zero;

	internal GUIDEInputState _State = null;

	public virtual bool _NeedsReset() => false;

	public virtual void _Reset() { _Value = Vector3.Zero; }

	public virtual bool IsSameAs(GUIDEInput other) => false;

	public virtual void _BeginUsage() { }

	public virtual void _EndUsage() { }

	public virtual string _EditorName() => "";

	public virtual string _EditorDescription() => "";

	public virtual GUIDEAction.GUIDEActionValueType _NativeValueType() => (GUIDEAction.GUIDEActionValueType)(-1);

	public virtual DeviceType _DeviceType() => DeviceType.None;
}
