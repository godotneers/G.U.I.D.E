using System;
using System.Collections.Generic;
using Godot;

namespace Guide;

[Tool]
[GlobalClass]
public partial class GUIDEInputAny : GUIDEInput {
	// Deprecated properties
	[Obsolete("Deprecated, use mouse_buttons instead")]
	public bool Mouse { get => MouseButtons; set => MouseButtons = value; }
	[Obsolete("Deprecated, use joy_buttons instead")]
	public bool Joy { get => JoyButtons; set => JoyButtons = value; }

	[Export] public bool MouseButtons { get; set; } = false;
	[Export] public bool MouseMovement { get; set; } = false;
	[Export] public float MinimumMouseMovementDistance { get; set; } = 1.0f;
	[Export] public bool JoyButtons { get; set; } = false;
	[Export] public bool JoyAxes { get; set; } = false;
	[Export] public float MinimumJoyAxisActuationStrength { get; set; } = 0.2f;
	[Export] public bool Keyboard { get; set; } = false;
	[Export] public bool Touch { get; set; } = false;

	public override bool _NeedsReset() => true;

	public override void _BeginUsage() {
		if (MouseMovement) _State.MousePositionChanged += _Refresh;
		if (MouseButtons) _State.MouseButtonStateChanged += _Refresh;
		if (Keyboard) _State.KeyboardStateChanged += _Refresh;
		if (JoyButtons) _State.JoyButtonStateChanged += _Refresh;
		if (JoyAxes) _State.JoyAxisStateChanged += _Refresh;
		if (Touch) _State.TouchStateChanged += _Refresh;

		_Refresh();
	}

	public override void _EndUsage() {
		if (MouseMovement) _State.MousePositionChanged -= _Refresh;
		if (MouseButtons) _State.MouseButtonStateChanged -= _Refresh;
		if (Keyboard) _State.KeyboardStateChanged -= _Refresh;
		if (JoyButtons) _State.JoyButtonStateChanged -= _Refresh;
		if (JoyAxes) _State.JoyAxisStateChanged -= _Refresh;
		if (Touch) _State.TouchStateChanged -= _Refresh;
	}

	private void _Refresh() {
		if (!_Value.IsZeroApprox()) return;

		if (Keyboard && _State.IsAnyKeyPressed()) {
			_Value = Vector3.Right;
			return;
		}

		if (MouseButtons && _State.IsAnyMouseButtonPressed()) {
			_Value = Vector3.Right;
			return;
		}

		if (MouseMovement && _State.GetMouseDeltaSinceLastFrame().Length() >= MinimumMouseMovementDistance) {
			_Value = Vector3.Right;
			return;
		}

		if (JoyButtons && _State.IsAnyJoyButtonPressed()) {
			_Value = Vector3.Right;
			return;
		}

		if (JoyAxes && _State.IsAnyJoyAxisActuated(MinimumJoyAxisActuationStrength)) {
			_Value = Vector3.Right;
			return;
		}

		if (Touch && _State.IsAnyFingerDown()) {
			_Value = Vector3.Right;
			return;
		}

		_Value = Vector3.Zero;
	}

	public override bool IsSameAs(GUIDEInput other) {
		return other is GUIDEInputAny any &&
			   MouseButtons == any.MouseButtons &&
			   MouseMovement == any.MouseMovement &&
			   JoyButtons == any.JoyButtons &&
			   JoyAxes == any.JoyAxes &&
			   Keyboard == any.Keyboard &&
			   Touch == any.Touch &&
			   Mathf.IsEqualApprox(MinimumMouseMovementDistance, any.MinimumMouseMovementDistance) &&
			   Mathf.IsEqualApprox(MinimumJoyAxisActuationStrength, any.MinimumJoyAxisActuationStrength);
	}

	public override string _EditorName() => "Any Input";

	public override string _EditorDescription() => "Input that triggers if any input from the given device class is given.";

	public override GUIDEAction.GUIDEActionValueType _NativeValueType() => GUIDEAction.GUIDEActionValueType.Bool;

	public override Godot.Collections.Array<Godot.Collections.Dictionary> _GetPropertyList() {
		return new Godot.Collections.Array<Godot.Collections.Dictionary> {
			new Godot.Collections.Dictionary
			{
				{ "name", "Mouse" },
				{ "type", (int)Variant.Type.Bool },
				{ "usage", (int)PropertyUsageFlags.NoEditor }
			},
			new Godot.Collections.Dictionary {
			   { "name", "Joy" },
			   { "type", (int)Variant.Type.Bool },
			   { "usage", (int)PropertyUsageFlags.NoEditor }
		   }
		};
	}

	public override DeviceType _DeviceType() {
		DeviceType result = DeviceType.None;
		if (JoyAxes || JoyButtons) result |= DeviceType.Joy;
		if (MouseButtons || MouseMovement) result |= DeviceType.Mouse;
		if (Keyboard) result |= DeviceType.Keyboard;
		if (Touch) result |= DeviceType.Touch;
		return result;
	}
}
