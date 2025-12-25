using System;
using System.Collections.Generic;
using System.Linq;
using Godot;

namespace Guide;

[Tool]
public partial class BindingDialog : Window {
	[Signal] public delegate void InputSelectedEventHandler(GUIDEInput input);

	private InputDisplay _inputDisplay;
	private Container _availableTypes;
	private Control _noneAvailable;
	private Control _someAvailable;
	private Button _selectBoolButton;
	private Button _select1DButton;
	private Button _select2DButton;
	private Button _select3DButton;
	private Label _instructionsLabel;
	private Button _acceptDetectionButton;
	private GUIDEInputDetector _inputDetector;
	private Button _detectBoolButton;
	private Button _detect1DButton;
	private Button _detect2DButton;
	private Button _detect3DButton;

	private GUIDEInput _lastDetectedInput;

	public void Initialize() {
		_SetupDialog();
	}

	private void _SetupDialog() {
		_inputDisplay = GetNode<InputDisplay>("%InputDisplay");
		_availableTypes = GetNode<Container>("%AvailableTypes");
		_noneAvailable = GetNode<Control>("%NoneAvailable");
		_someAvailable = GetNode<Control>("%SomeAvailable");
		_selectBoolButton = GetNode<Button>("%SelectBoolButton");
		_select1DButton = GetNode<Button>("%Select1DButton");
		_select2DButton = GetNode<Button>("%Select2DButton");
		_select3DButton = GetNode<Button>("%Select3DButton");
		_instructionsLabel = GetNode<Label>("%InstructionsLabel");
		_acceptDetectionButton = GetNode<Button>("%AcceptDetectionButton");
		_inputDetector = GetNode<GUIDEInputDetector>("%InputDetector");
		_detectBoolButton = GetNode<Button>("%DetectBoolButton");
		_detect1DButton = GetNode<Button>("%Detect1DButton");
		_detect2DButton = GetNode<Button>("%Detect2DButton");
		_detect3DButton = GetNode<Button>("%Detect3DButton");

		FocusExited += _OnCloseRequested;
		_ShowInputsOfValueType(GUIDEAction.GUIDEActionValueType.Bool);
		_instructionsLabel.Text = Tr("Press one of the buttons above to detect an input.");
		_acceptDetectionButton.Visible = false;
	}

	private void _OnCloseRequested() {
		Hide();
		QueueFree();
	}

	private void _ShowInputsOfValueType(GUIDEAction.GUIDEActionValueType type) {
		var items = new List<GUIDEInput>();

		_selectBoolButton.SetPressedNoSignal(type == GUIDEAction.GUIDEActionValueType.Bool);
		_select1DButton.SetPressedNoSignal(type == GUIDEAction.GUIDEActionValueType.Axis1D);
		_select2DButton.SetPressedNoSignal(type == GUIDEAction.GUIDEActionValueType.Axis2D);
		_select3DButton.SetPressedNoSignal(type == GUIDEAction.GUIDEActionValueType.Axis3D);

		var allInputs = ClassScanner.FindInheritors("GUIDEInput");
		foreach (var script in allInputs.Values) {
			var dummy = script.Call("new").As<GUIDEInput>();
			if (dummy._NativeValueType() == type) {
				items.Add(dummy);
			}
		}

		_someAvailable.Visible = items.Count > 0;
		_noneAvailable.Visible = items.Count == 0;

		if (items.Count == 0) return;

		items.Sort((a, b) => string.Compare(a._EditorName(), b._EditorName(), StringComparison.OrdinalIgnoreCase));
		EditorUtils.Clear(_availableTypes);

		foreach (var item in items) {
			var button = new Button();
			button.Text = item._EditorName();
			button.TooltipText = item._EditorDescription();
			button.Pressed += () => _Deliver(item);
			button.SizeFlagsHorizontal = Control.SizeFlags.ExpandFill;
			_availableTypes.AddChild(button);
		}
	}

	private void _Deliver(GUIDEInput input) {
		EmitSignal(SignalName.InputSelected, input);
		Hide();
		QueueFree();
	}

	private void _OnSelectBoolButtonPressed() => _ShowInputsOfValueType(GUIDEAction.GUIDEActionValueType.Bool);
	private void _OnSelect1DButtonPressed() => _ShowInputsOfValueType(GUIDEAction.GUIDEActionValueType.Axis1D);
	private void _OnSelect2DButtonPressed() => _ShowInputsOfValueType(GUIDEAction.GUIDEActionValueType.Axis2D);
	private void _OnSelect3DButtonPressed() => _ShowInputsOfValueType(GUIDEAction.GUIDEActionValueType.Axis3D);

	private void _OnInputDetectorDetectionStarted() {
		_instructionsLabel.Text = Tr("Actuate the input now...");
	}

	private void _OnInputDetectorInputDetected(GUIDEInput input) {
		_instructionsLabel.Visible = false;
		_inputDisplay.Visible = true;
		_inputDisplay.InputValue = input; // Assuming InputDisplay is ported
		_acceptDetectionButton.Visible = true;
		_lastDetectedInput = input;
	}

	private void _BeginDetectInput(GUIDEAction.GUIDEActionValueType type) {
		_lastDetectedInput = null;
		_instructionsLabel.Visible = true;
		_instructionsLabel.Text = Tr("Get ready...");
		_acceptDetectionButton.Visible = false;
		_inputDisplay.Visible = false;
		_inputDetector.Detect(type);
	}

	private void _OnDetectBoolButtonPressed() {
		_detectBoolButton.ReleaseFocus();
		_BeginDetectInput(GUIDEAction.GUIDEActionValueType.Bool);
	}

	private void _OnDetect1DButtonPressed() {
		_detect1DButton.ReleaseFocus();
		_BeginDetectInput(GUIDEAction.GUIDEActionValueType.Axis1D);
	}

	private void _OnDetect2DButtonPressed() {
		_detect2DButton.ReleaseFocus();
		_BeginDetectInput(GUIDEAction.GUIDEActionValueType.Axis2D);
	}

	private void _OnDetect3DButtonPressed() {
		_detect3DButton.ReleaseFocus();
		_BeginDetectInput(GUIDEAction.GUIDEActionValueType.Axis3D);
	}

	private void _OnAcceptDetectionButtonPressed() {
		EmitSignal(SignalName.InputSelected, _lastDetectedInput);
		Hide();
		QueueFree();
	}
}
