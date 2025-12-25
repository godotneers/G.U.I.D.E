using System;
using System.Threading.Tasks;
using Godot;

namespace Guide;

[Tool]
public partial class InputDisplay : RichTextLabel {
	[Signal] public delegate void ClickedEventHandler();

	private GUIDEInputFormatter _formatter = new GUIDEInputFormatter(64);

	public override void _Ready() {
		ProjectSettings.SettingsChanged += _Refresh;
	}

	private GUIDEInput _input;
	public GUIDEInput InputValue {
		get => _input;
		set {
			if (value == _input) return;
			if (IsInstanceValid(_input)) _input.Changed -= _Refresh;
			_input = value;
			if (IsInstanceValid(_input)) _input.Changed += _Refresh;
			_Refresh();
		}
	}

	private async void _Refresh() {
		_formatter.formatting_options.joy_rendering = GUIDEProjectSettings.EditorJoyRendering;
		_formatter.formatting_options.preferred_joy_type = GUIDEProjectSettings.EditorJoyType;

		if (!IsInstanceValid(InputValue)) {
			ParseBbcode("[center][i]<not bound>[/i][/center]");
			TooltipText = "";
			return;
		}

		string text = await _formatter.InputAsRichtextAsync(InputValue, false);
		ParseBbcode("[center]" + text + "[/center]");
		TooltipText = _formatter.InputAsText(InputValue);
	}

	public override void _GuiInput(InputEvent @event) {
		if (@event is InputEventMouseButton mouseButton && mouseButton.Pressed && mouseButton.ButtonIndex == MouseButton.Left) {
			EmitSignal(SignalName.Clicked);
		}
	}
}
