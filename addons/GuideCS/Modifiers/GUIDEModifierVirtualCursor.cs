using System;
using Godot;

namespace Guide;

[Tool]
[GlobalClass]
public partial class GUIDEModifierVirtualCursor : GUIDEModifier {
	public enum ScreenScale {
		None = 0,
		LongerAxis = 1,
		ShorterAxis = 2
	}

	private Vector2 _initialPosition = new Vector2(0.5f, 0.5f);
	[Export]
	public Vector2 InitialPosition {
		get => _initialPosition;
		set {
			_initialPosition = value.Clamp(Vector2.Zero, Vector2.One);
		}
	}

	[Export] public bool InitializeFromMousePosition { get; set; } = false;
	[Export] public bool ApplyToMousePositionOnDeactivation { get; set; } = false;
	[Export] public Vector3 Speed { get; set; } = Vector3.One;
	[Export] public ScreenScale ScreenScaleValue { get; set; } = ScreenScale.LongerAxis;

	[Obsolete("Use Speed instead")]
	public Vector3 Scale {
		get => Speed;
		set => Speed = value;
	}

	[Export] public bool ApplyDeltaTime { get; set; } = true;

	private Vector3 _offset = Vector3.Zero;

	public override bool IsSameAs(GUIDEModifier other) {
		return other is GUIDEModifierVirtualCursor otherCursor &&
			   ScreenScaleValue == otherCursor.ScreenScaleValue &&
			   ApplyDeltaTime == otherCursor.ApplyDeltaTime &&
			   InitialPosition.IsEqualApprox(otherCursor.InitialPosition) &&
			   Speed.IsEqualApprox(otherCursor.Speed);
	}

	private Vector2 _GetScaledScreenSize() {
		if (Engine.GetMainLoop() is not SceneTree tree) return Vector2.Zero;
		var window = tree.Root;
		return window.GetScreenTransform().AffineInverse() * window.Size;
	}

	public override void _BeginUsage() {
		var windowSize = _GetScaledScreenSize();
		if (InitializeFromMousePosition) {
			if (Input.MouseMode == Input.MouseModeEnum.Captured) {
				GD.PushWarning("Mouse mode is captured. In this mode the mouse cursor is fixed to center of the screen. Use one of the other mouse modes instead.");
			}

			if (Engine.GetMainLoop() is SceneTree tree) {
				var mousePosition = tree.Root.GetMousePosition();
				_offset = new Vector3(mousePosition.X, mousePosition.Y, 0);
			}
		}
		else {
			_offset = new Vector3(windowSize.X * InitialPosition.X, windowSize.Y * InitialPosition.Y, 0);
		}
	}

	public override void _EndUsage() {
		if (ApplyToMousePositionOnDeactivation) {
			if (Input.MouseMode == Input.MouseModeEnum.Captured) {
				GD.PushWarning("Mouse mode is captured. In this mode the mouse cursor cannot be moved. Use one of the other mouse modes instead.");
				return;
			}

			if (Engine.GetMainLoop() is SceneTree tree) {
				var window = tree.Root;
				var mousePosition = window.GetMousePosition();
				var difference = new Vector2(_offset.X, _offset.Y) - mousePosition;
				window.WarpMouse(new Vector2(_offset.X, _offset.Y));

				var motionEvent = new InputEventMouseMotion();
				motionEvent.Relative = difference;
				GUIDE.Singleton?.InjectInput(motionEvent);
			}
		}
	}

	public override Vector3 _ModifyInput(Vector3 input, float delta, GUIDEAction.GUIDEActionValueType valueType) {
		if (!input.IsFinite()) return _offset;

		var windowSize = _GetScaledScreenSize();
		input *= Speed;

		if (ApplyDeltaTime) input *= delta;

		float screenScaleFactor = 1.0f;
		switch (ScreenScaleValue) {
			case ScreenScale.LongerAxis:
				screenScaleFactor = Math.Max(windowSize.X, windowSize.Y);
				break;
			case ScreenScale.ShorterAxis:
				screenScaleFactor = Math.Min(windowSize.X, windowSize.Y);
				break;
		}

		input *= screenScaleFactor;

		_offset = (_offset + input).Clamp(Vector3.Zero, new Vector3(windowSize.X, windowSize.Y, 0));

		return _offset;
	}

	public override string _EditorName() => "Virtual Cursor";

	public override string _EditorDescription() => "Stateful modifier which provides a virtual \"mouse\" cursor driven by input. The modifier\nreturns the current cursor position in pixels releative to the origin of the currently \nactive window.";

	public override Godot.Collections.Array<Godot.Collections.Dictionary> _GetPropertyList() {
		return new Godot.Collections.Array<Godot.Collections.Dictionary> {
			new Godot.Collections.Dictionary {
				{ "name", "Scale" },
				{ "type", (int)Variant.Type.Vector3 },
				{ "usage", (int)PropertyUsageFlags.NoEditor }
			}
		};
	}
}
