using System;
using Godot;

namespace Guide;

[Tool]
[Icon("res://addons/GuideCS/UI/VirtualJoy/VirtualButton/GuideVirtualButtonRenderer.svg")]
public partial class GUIDEVirtualButtonRenderer : Control {
	protected GUIDEVirtualButton _button = null;

	public bool IsButtonActuated => _button?._isActuated ?? false;
	public float ButtonRadius => _button?.ButtonRadius ?? 0.0f;

	public override void _Notification(int what) {
		if (what == NotificationEnterTree) {
			_button = GetParent() as GUIDEVirtualButton;
			if (_button == null) {
				GD.PushError("Button renderer must be a child of GUIDEVirtualButton. Button renderer will not work.");
				return;
			}
			_button.ConfigurationChanged += _OnConfigurationChanged;
			if (Engine.IsEditorHint()) return;
			_button.Changed += () => _Update(_button._isActuated);
		}
	}

	protected virtual void _OnConfigurationChanged() { }

	protected virtual void _Update(bool isActuated) { }

	public override string[] _GetConfigurationWarnings() {
		if (GetParent() is not GUIDEVirtualButton) {
			return new[] { "Button renderer must be a child of GUIDEVirtualButton" };
		}
		return Array.Empty<string>();
	}
}
