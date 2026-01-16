using System;
using System.Collections.Generic;
using System.Linq;
using Godot;

namespace Guide;

public partial class GUIDEDebugger : MarginContainer {
	private Container _actions;
	private Container _inputs;
	private Container _priorities;
	private GUIDEInputFormatter _formatter;

	public override void _Ready() {
		ProcessMode = ProcessModeEnum.Always;
		_actions = GetNode<Container>("%Actions");
		_inputs = GetNode<Container>("%Inputs");
		_priorities = GetNode<Container>("%Priorities");
		_formatter = GUIDEInputFormatter.ForActiveContexts();

		if (GUIDE.Singleton != null) {
			GUIDE.Singleton.InputMappingsChanged += _UpdatePriorities;
		}
		_UpdatePriorities();
	}

	public override void _Process(double delta) {
		if (!IsVisibleInTree()) return;

		int index = 0;
		if (GUIDE.Singleton != null) {
			foreach (var mapping in GUIDE.Singleton._ActiveActionMappings) {
				var action = mapping.Action;
				string actionName = action.Name;
				if (string.IsNullOrEmpty(actionName)) actionName = action.EditorName();

				string actionState = action.LastState switch {
					GUIDEAction.GUIDEActionState.Completed => "Completed",
					GUIDEAction.GUIDEActionState.Ongoing => "Ongoing",
					GUIDEAction.GUIDEActionState.Triggered => "Triggered",
					_ => ""
				};

				string actionValue = action.ActionValueType switch {
					GUIDEAction.GUIDEActionValueType.Bool => action.ValueBool.ToString(),
					GUIDEAction.GUIDEActionValueType.Axis1D => action.ValueAxis1D.ToString(),
					GUIDEAction.GUIDEActionValueType.Axis2D => action.ValueAxis2D.ToString(),
					GUIDEAction.GUIDEActionValueType.Axis3D => action.Value.ToString(),
					_ => ""
				};

				var label = _GetLabel(_actions, index);
				label.Text = $"[{actionName}] {actionState} - {actionValue}";
				index++;
			}
		}
		_Cleanup(_actions, index);

		index = 0;
		if (GUIDE.Singleton != null) {
			foreach (var inputObj in GUIDE.Singleton._ActiveInputs.Values()) {
				var input = inputObj.As<GUIDEInput>();
				var inputLabel = _formatter.InputAsText(input, false);
				var inputValue = input._Value.ToString();

				var label = _GetLabel(_inputs, index);
				label.Text = $"{inputLabel} - {inputValue}";
				index++;
			}
		}
		_Cleanup(_inputs, index);
	}

	private Label _GetLabel(Container container, int index) {
		if (container.GetChildCount() > index) {
			return container.GetChild<Label>(index);
		}
		var label = new Label();
		label.MouseFilter = MouseFilterEnum.Ignore;
		container.AddChild(label);
		return label;
	}

	private void _Cleanup(Container container, int index) {
		while (container.GetChildCount() > index) {
			var toFree = container.GetChild(index);
			container.RemoveChild(toFree);
			toFree.QueueFree();
		}
	}

	private void _UpdatePriorities() {
		_Cleanup(_priorities, 0);

		if (GUIDE.Singleton != null) {
			foreach (var mapping in GUIDE.Singleton._ActiveActionMappings) {
				var action = mapping.Action;
				if (GUIDE.Singleton._ActionsSharingInput.TryGetValue(action, out var sharing)) {
					var label = new Label();
					var names = string.Join(", ", sharing.Select(it => it.EditorName()));
					label.Text = $"[{action.EditorName()}] > [{names}]";
					_priorities.AddChild(label);
				}
			}
		}

		if (_priorities.GetChildCount() == 0) {
			var label = new Label();
			label.Text = "<no overlapping input>";
			_priorities.AddChild(label);
		}
	}
}
