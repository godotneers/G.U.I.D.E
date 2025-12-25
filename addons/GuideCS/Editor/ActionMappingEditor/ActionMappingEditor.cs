using System.Diagnostics;
using Godot;

namespace Guide;

[Tool]
public partial class ActionMappingEditor : MarginContainer {
	[Signal] public delegate void DeleteRequestedEventHandler();
	[Signal] public delegate void DuplicateRequestedEventHandler();

	[Export] public PackedScene InputMappingEditorScene { get; set; }

	private ActionSlot _actionSlot;
	private ArrayEdit _inputMappings;

	private EditorPlugin _plugin;
	private EditorUndoRedoManager _undoRedo;
	private GUIDEActionMapping _mapping;

	public override void _Ready() {
		_actionSlot = GetNode<ActionSlot>("%ActionSlot");
		_inputMappings = GetNode<ArrayEdit>("%InputMappings");

		_actionSlot.ActionChanged += _OnActionChanged;
		_inputMappings.DeleteRequested += _OnInputMappingDeleteRequested;
		_inputMappings.AddRequested += _OnInputMappingsAddRequested;
		_inputMappings.MoveRequested += _OnInputMappingsMoveRequested;
		_inputMappings.ClearRequested += _OnInputMappingsClearRequested;
		_inputMappings.DuplicateRequested += _OnInputMappingsDuplicateRequested;
		_inputMappings.CollapseStateChanged += _OnInputMappingsCollapseStateChanged;
	}

	public void Initialize(EditorPlugin plugin) {
		_plugin = plugin;
		_undoRedo = _plugin.GetUndoRedo();
	}

	public void Edit(GUIDEActionMapping mapping) {
		Debug.Assert(_mapping == null);
		_mapping = mapping;
		_mapping.Changed += _Update;
		_Update();
	}

	private void _Update() {
		_inputMappings.Clear();
		_actionSlot.Action = _mapping.Action;

		for (int i = 0; i < _mapping.InputMappings.Count; i++) {
			var inputMapping = _mapping.InputMappings[i];
			var inputMappingEditor = InputMappingEditorScene.Instantiate<InputMappingEditor>();
			_inputMappings.AddItem(inputMappingEditor);

			inputMappingEditor.Initialize(_plugin);
			inputMappingEditor.Edit(inputMapping);
		}

		_inputMappings.Collapsed = (bool)_mapping.GetMeta("_guide_input_mappings_collapsed", false);
	}

	private void _OnActionChanged() {
		_undoRedo.CreateAction("Change action");
		_undoRedo.AddDoProperty(_mapping, "Action", _actionSlot.Action);
		_undoRedo.AddUndoProperty(_mapping, "Action", _mapping.Action);
		_undoRedo.CommitAction();
	}

	private void _OnInputMappingsAddRequested() {
		var values = _mapping.InputMappings.Duplicate();
		var newMapping = new GUIDEInputMapping();
		values.Add(newMapping);

		_undoRedo.CreateAction("Add input mapping");
		_undoRedo.AddDoProperty(_mapping, "InputMappings", values);
		_undoRedo.AddUndoProperty(_mapping, "InputMappings", _mapping.InputMappings);
		_undoRedo.CommitAction();
	}

	private void _OnInputMappingDeleteRequested(int index) {
		var values = _mapping.InputMappings.Duplicate();
		values.RemoveAt(index);

		_undoRedo.CreateAction("Delete input mapping");
		_undoRedo.AddDoProperty(_mapping, "InputMappings", values);
		_undoRedo.AddUndoProperty(_mapping, "InputMappings", _mapping.InputMappings);
		_undoRedo.CommitAction();
	}

	private void _OnInputMappingsMoveRequested(int from, int to) {
		var values = _mapping.InputMappings.Duplicate();
		var mapping = values[from];
		values.RemoveAt(from);
		if (from < to) to--;
		values.Insert(to, mapping);

		_undoRedo.CreateAction("Move input mapping");
		_undoRedo.AddDoProperty(_mapping, "InputMappings", values);
		_undoRedo.AddUndoProperty(_mapping, "InputMappings", _mapping.InputMappings);
		_undoRedo.CommitAction();
	}

	private void _OnInputMappingsClearRequested() {
		var values = new Godot.Collections.Array<GUIDEInputMapping>();
		_undoRedo.CreateAction("Clear input mappings");
		_undoRedo.AddDoProperty(_mapping, "InputMappings", values);
		_undoRedo.AddUndoProperty(_mapping, "InputMappings", _mapping.InputMappings);
		_undoRedo.CommitAction();
	}

	private void _OnInputMappingsDuplicateRequested(int index) {
		var values = _mapping.InputMappings.Duplicate();
		var copy = (GUIDEInputMapping)values[index].Duplicate();
		copy.Input = (GUIDEInput)EditorUtils.DuplicateIfInline(copy.Input);

		for (int i = 0; i < copy.Modifiers.Count; i++) {
			copy.Modifiers[i] = (GUIDEModifier)EditorUtils.DuplicateIfInline(copy.Modifiers[i]);
		}

		for (int i = 0; i < copy.Triggers.Count; i++) {
			copy.Triggers[i] = (GUIDETrigger)EditorUtils.DuplicateIfInline(copy.Triggers[i]);
		}

		values.Insert(index + 1, copy);

		_undoRedo.CreateAction("Duplicate input mapping");
		_undoRedo.AddDoProperty(_mapping, "InputMappings", values);
		_undoRedo.AddUndoProperty(_mapping, "InputMappings", _mapping.InputMappings);
		_undoRedo.CommitAction();
	}

	private void _OnInputMappingsCollapseStateChanged(bool newState) => _mapping.SetMeta("_guide_input_mappings_collapsed", newState);
}
