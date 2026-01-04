using System;
using Godot;

namespace Guide;

[Tool]
[GlobalClass]
public partial class GUIDEInputAction : GUIDEInput {
	private GUIDEAction _action;
	[Export]
	public GUIDEAction Action {
		get => _action;
		set {
			if (_action == value) return;
			_action = value;
			EmitChanged();
		}
	}

	public override void _BeginUsage() {
		if (IsInstanceValid(Action)) {
			Action.Triggered += _On;
			Action.Completed += _Off;
			Action.Ongoing += _Off;
			if (Action.IsTriggered()) {
				_On();
				return;
			}
		}
		_Off();
	}

	public override void _EndUsage() {
		if (IsInstanceValid(Action)) {
			Action.Triggered -= _On;
			Action.Completed -= _Off;
			Action.Ongoing -= _Off;
		}
	}

	private void _On() { _Value = Action.Value; }

	private void _Off() { _Value = Vector3.Zero; }

	public override bool IsSameAs(GUIDEInput other) {
		return other is GUIDEInputAction actionInput && actionInput.Action == Action;
	}

	public override string ToString() => $"(GuideInputAction: {Action})";

	public override string _EditorName() => "Action";

	public override string _EditorDescription() => "An input that mirrors the action's value while the action is triggered.";

	public override GUIDEAction.GUIDEActionValueType _NativeValueType() => GUIDEAction.GUIDEActionValueType.Axis3D;
}
