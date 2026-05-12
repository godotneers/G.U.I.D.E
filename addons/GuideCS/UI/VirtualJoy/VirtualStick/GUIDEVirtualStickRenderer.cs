using System;
using Godot;

namespace Guide;

[Tool]
[Icon("res://addons/GuideCS/UI/VirtualJoy/VirtualStick/GuideVirtualStickRenderer.svg")]
public partial class GUIDEVirtualStickRenderer : Control {
	protected GUIDEVirtualStick _stick;
	protected bool _wasActuated = false;

	public float StickRadius => _stick?.StickRadius ?? 0.0f;
	public float MaxActuationRadius => _stick?.MaxActuationRadius ?? 0.0f;
	public float InteractionZoneRadius => _stick?.InteractionZoneRadius ?? 0.0f;
	public Vector2 StickPosition => _stick?.StickRelativePosition ?? Vector2.Zero;
	public Vector2 StickStartPosition => _stick?._startPos ?? Vector2.Zero;
	public bool IsStickActuated => _stick?._isActuated ?? false;

	public override void _Notification(int what) {
		if (what == NotificationEnterTree) {
			_stick = GetParent() as GUIDEVirtualStick;
			if (_stick == null) {
				GD.PushError("Stick renderer must be a child of GuideVirtualStick. Stick renderer will not work.");
				return;
			}
			_stick.ConfigurationChanged += _OnConfigurationChanged;

			if (Engine.IsEditorHint()) return;
			_stick.Changed += _OnStickChanged;
		}
	}

	protected virtual void _OnConfigurationChanged() { }

	private void _OnStickChanged() {
		var direction = Vector2.Zero;
		if (!_stick._startPos.IsEqualApprox(_stick._currentPos)) {
			direction = _stick._startPos.DirectionTo(_stick._currentPos);
		}

		float distance = _stick._startPos.DistanceTo(_stick._currentPos);
		var offset = direction * (distance / _stick.MaxActuationRadius);

		if (_stick._isActuated && !_wasActuated) _wasActuated = true;
		if (!_stick._isActuated && _wasActuated) _wasActuated = false;

		_Update(_stick._currentPos - GlobalPosition, offset, _stick._isActuated);
	}

	protected virtual void _Update(Vector2 joyPosition, Vector2 joyOffset, bool isActuated) { }

	public override string[] _GetConfigurationWarnings() {
		if (GetParent() is not GUIDEVirtualStick) {
			return new[] { "Stick renderer must be a child of GUIDEVirtualStick" };
		}
		return Array.Empty<string>();
	}
}
