using Godot;

namespace Guide;

[Tool]
public partial class ActionSlot : HBoxContainer {
	[Signal] public delegate void ActionChangedEventHandler();

	private LineEdit _lineEdit;
	private TextureRect _typeIcon;

	private GUIDEAction _action;
	public GUIDEAction Action {
		get => _action;
		set {
			if (IsInstanceValid(_action)) _action.Changed -= _Refresh;
			_action = value;
			if (IsInstanceValid(_action)) _action.Changed += _Refresh;
			_Refresh();
		}
	}

	public override void _Ready() {
		_lineEdit = GetNode<LineEdit>("%LineEdit");
		_typeIcon = GetNode<TextureRect>("%TypeIcon");
		_Refresh();
	}

	private void _Refresh() {
		if (_lineEdit == null || _typeIcon == null) return;

		if (!IsInstanceValid(Action)) {
			_lineEdit.Text = "<none>";
			_lineEdit.TooltipText = "";
			_typeIcon.Texture = GD.Load<Texture2D>("res://addons/GuideCS/Editor/ActionSlot/MissingAction.svg");
			_typeIcon.TooltipText = "Missing action";
		}
		else {
			_lineEdit.Text = Action.EditorName();
			_lineEdit.TooltipText = Action.ResourcePath;
			switch (Action.ActionValueType) {
				case GUIDEAction.GUIDEActionValueType.Axis1D:
					_typeIcon.Texture = GD.Load<Texture2D>("res://addons/GuideCS/Editor/ActionSlot/ActionValueTypeAxis1D.svg");
					_typeIcon.TooltipText = "Axis1D";
					break;
				case GUIDEAction.GUIDEActionValueType.Axis2D:
					_typeIcon.Texture = GD.Load<Texture2D>("res://addons/GuideCS/Editor/ActionSlot/ActionValueTypeAxis2D.svg");
					_typeIcon.TooltipText = "Axis2D";
					break;
				case GUIDEAction.GUIDEActionValueType.Axis3D:
					_typeIcon.Texture = GD.Load<Texture2D>("res://addons/GuideCS/Editor/ActionSlot/ActionValueTypeAxis3D.svg");
					_typeIcon.TooltipText = "Axis3D";
					break;
				default:
					_typeIcon.Texture = GD.Load<Texture2D>("res://addons/GuideCS/Editor/ActionSlot/ActionValueTypeBool.svg");
					_typeIcon.TooltipText = "Boolean";
					break;
			}
		}
	}

	public override void _GuiInput(InputEvent @event) {
		if (@event is InputEventMouseButton mouseButton && mouseButton.Pressed && mouseButton.ButtonIndex == MouseButton.Left) {
			if (IsInstanceValid(Action)) EditorInterface.Singleton.EditResource(Action);
		}
	}

	private void _OnLineEditActionDropped(GUIDEAction newAction) {
		GD.Print("ActionSlot: Action dropped");
		Action = newAction;
		EmitSignal(SignalName.ActionChanged);
	}

	private void _OnLineEditFocusEntered() {
		if (IsInstanceValid(Action)) EditorInterface.Singleton.EditResource(Action);
	}
}
