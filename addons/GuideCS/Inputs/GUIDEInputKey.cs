using System;
using System.Collections.Generic;
using Godot;

namespace Guide;

[Tool]
[GlobalClass]
public partial class GUIDEInputKey : GUIDEInput {
	private Key _key;
	[Export]
	public Key Key {
		get => _key;
		set {
			if (_key == value) return;
			_key = value;
			EmitChanged();
		}
	}

	[ExportGroup("Modifiers")]
	private bool _shift = false;
	[Export]
	public bool Shift {
		get => _shift;
		set {
			if (_shift == value) return;
			_shift = value;
			EmitChanged();
		}
	}

	private bool _control = false;
	[Export]
	public bool Control {
		get => _control;
		set {
			if (_control == value) return;
			_control = value;
			EmitChanged();
		}
	}

	private bool _alt = false;
	[Export]
	public bool Alt {
		get => _alt;
		set {
			if (_alt == value) return;
			_alt = value;
			EmitChanged();
		}
	}

	private bool _meta = false;
	[Export]
	public bool Meta {
		get => _meta;
		set {
			if (_meta == value) return;
			_meta = value;
			EmitChanged();
		}
	}

	private bool _allowAdditionalModifiers = true;
	[Export]
	public bool AllowAdditionalModifiers {
		get => _allowAdditionalModifiers;
		set {
			if (_allowAdditionalModifiers == value) return;
			_allowAdditionalModifiers = value;
			EmitChanged();
		}
	}

	private List<Key> _mustBePressed = new();
	private List<Key> _mustNotBePressed = new();

	public override void _BeginUsage() {
		_mustBePressed = new List<Key> { Key };

		if (Shift) _mustBePressed.Add(Godot.Key.Shift);
		if (Control) _mustBePressed.Add(Godot.Key.Ctrl);
		if (Alt) _mustBePressed.Add(Godot.Key.Alt);
		if (Meta) _mustBePressed.Add(Godot.Key.Meta);

		_mustNotBePressed.Clear();
		if (!AllowAdditionalModifiers) {
			if (!Shift && Key != Godot.Key.Shift) _mustNotBePressed.Add(Godot.Key.Shift);
			if (!Control && Key != Godot.Key.Ctrl) _mustNotBePressed.Add(Godot.Key.Ctrl);
			if (!Alt && Key != Godot.Key.Alt) _mustNotBePressed.Add(Godot.Key.Alt);
			if (!Meta && Key != Godot.Key.Meta) _mustNotBePressed.Add(Godot.Key.Meta);
		}

		_State.KeyboardStateChanged += _Refresh;
		_Refresh();
	}

	public override void _EndUsage() {
		_State.KeyboardStateChanged -= _Refresh;
	}

	private void _Refresh() {
		bool isActuated = _State.AreAllKeysPressed(_mustBePressed) && !_State.IsAtLeastOneKeyPressed(_mustNotBePressed);
		_Value = new Vector3(isActuated ? 1.0f : 0.0f, 0, 0);
	}

	public override bool IsSameAs(GUIDEInput other) {
		return other is GUIDEInputKey keyInput &&
			   keyInput.Key == Key &&
			   keyInput.Shift == Shift &&
			   keyInput.Control == Control &&
			   keyInput.Alt == Alt &&
			   keyInput.Meta == Meta &&
			   keyInput.AllowAdditionalModifiers == AllowAdditionalModifiers;
	}

	public override string ToString() => $"(GUIDEInputKey: key={Key}, shift={Shift}, alt={Alt}, control={Control}, meta={Meta})";

	public override string _EditorName() => "Key";

	public override string _EditorDescription() => "A button press on the keyboard.";

	public override GUIDEAction.GUIDEActionValueType _NativeValueType() => GUIDEAction.GUIDEActionValueType.Bool;

	public override DeviceType _DeviceType() => DeviceType.Keyboard;
}
