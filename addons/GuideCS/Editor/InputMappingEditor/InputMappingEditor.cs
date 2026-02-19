using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Linq;
using Godot;

namespace Guide;

[Tool]
public partial class InputMappingEditor : MarginContainer {
	[Export] public PackedScene ModifierSlotScene { get; set; }
	[Export] public PackedScene TriggerSlotScene { get; set; }
	[Export] public PackedScene BindingDialogScene { get; set; }

	private Button _editInputMappingButton;
	private InputDisplay _inputDisplay;
	private Button _editInputButton;
	private Button _clearInputButton;
	private ArrayEdit _modifiers;
	private PopupMenu _addModifierPopup;
	private ArrayEdit _triggers;
	private PopupMenu _addTriggerPopup;

	private EditorPlugin _plugin;
	private EditorUndoRedoManager _undoRedo;
	private GUIDEInputMapping _mapping;

	public override void _Ready() {
		_editInputMappingButton = GetNode<Button>("%EditInputMappingButton");
		_inputDisplay = GetNode<InputDisplay>("%InputDisplay");
		_editInputButton = GetNode<Button>("%EditInputButton");
		_clearInputButton = GetNode<Button>("%ClearInputButton");
		_modifiers = GetNode<ArrayEdit>("%Modifiers");
		_addModifierPopup = GetNode<PopupMenu>("%AddModifierPopup");
		_triggers = GetNode<ArrayEdit>("%Triggers");
		_addTriggerPopup = GetNode<PopupMenu>("%AddTriggerPopup");

		if (Engine.IsEditorHint()) {
			_editInputButton.Icon = GetThemeIcon("Edit", "EditorIcons");
			_clearInputButton.Icon = GetThemeIcon("Remove", "EditorIcons");
			_editInputMappingButton.Icon = GetThemeIcon("Tools", "EditorIcons");
		}

		_modifiers.AddRequested += _OnModifiersAddRequested;
		_modifiers.DeleteRequested += _OnModifierDeleteRequested;
		_modifiers.DuplicateRequested += _OnModifierDuplicateRequested;
		_modifiers.MoveRequested += _OnModifierMoveRequested;
		_modifiers.ClearRequested += _OnModifiersClearRequested;
		_modifiers.CollapseStateChanged += _OnModifiersCollapseStateChanged;

		_triggers.AddRequested += _OnTriggersAddRequested;
		_triggers.DeleteRequested += _OnTriggerDeleteRequested;
		_triggers.DuplicateRequested += _OnTriggerDuplicateRequested;
		_triggers.MoveRequested += _OnTriggerMoveRequested;
		_triggers.ClearRequested += _OnTriggersClearRequested;
		_triggers.CollapseStateChanged += _OnTriggersCollapseStateChanged;
	}

	public void Initialize(EditorPlugin plugin) {
		_plugin = plugin;
		_undoRedo = _plugin.GetUndoRedo();
		_inputDisplay.Clicked += _OnInputDisplayClicked;
	}

	public void Edit(GUIDEInputMapping mapping) {
		Debug.Assert(_mapping == null);
		_mapping = mapping;
		_mapping.Changed += _Update;
		_Update();
	}

	private void _Update() {
		_modifiers.Clear();
		_triggers.Clear();

		_inputDisplay.InputValue = _mapping.Input;

		for (int i = 0; i < _mapping.Modifiers.Count; i++) {
			var modifierSlot = ModifierSlotScene.Instantiate<ModifierSlot>();
			_modifiers.AddItem(modifierSlot);
			modifierSlot.Modifier = _mapping.Modifiers[i];
			int index = i;
			modifierSlot.Changed += () => _OnModifierChanged(index, modifierSlot);
		}

		for (int i = 0; i < _mapping.Triggers.Count; i++) {
			var triggerSlot = TriggerSlotScene.Instantiate<TriggerSlot>();
			_triggers.AddItem(triggerSlot);
			triggerSlot.Trigger = _mapping.Triggers[i];
			int index = i;
			triggerSlot.Changed += () => _OnTriggerChanged(index, triggerSlot);
		}

		_modifiers.Collapsed = (bool)_mapping.GetMeta("_guide_modifiers_collapsed", false);
		_triggers.Collapsed = (bool)_mapping.GetMeta("_guide_triggers_collapsed", false);
	}

	private void _OnModifiersAddRequested() {
		_FillPopup(_addModifierPopup, "GUIDEModifier");
		_addModifierPopup.Popup(new Rect2I((Vector2I)(GetScreenPosition() + GetLocalMousePosition()), Vector2I.Zero));
	}

	private void _OnTriggersAddRequested() {
		_FillPopup(_addTriggerPopup, "GUIDETrigger");
		_addTriggerPopup.Popup(new Rect2I((Vector2I)(GetScreenPosition() + GetLocalMousePosition()), Vector2I.Zero));
	}

	private void _FillPopup(PopupMenu popup, StringName baseClazz) {
		popup.Clear(true);
		var inheritors = ClassScanner.FindInheritors(baseClazz);
		foreach (var kvp in inheritors) {
			var dummy = kvp.Value.Call("new").As<Resource>();
			popup.AddItem((string)dummy.Call("_EditorName"));
			popup.SetItemTooltip(popup.ItemCount - 1, (string)dummy.Call("_EditorDescription"));
			popup.SetItemMetadata(popup.ItemCount - 1, kvp.Value);
		}
	}

	private void _OnInputDisplayClicked() {
		if (IsInstanceValid(_mapping.Input)) EditorInterface.Singleton.EditResource(_mapping.Input);
	}

	private void _OnInputChanged(GUIDEInput input) {
		_undoRedo.CreateAction("Change input");
		_undoRedo.AddDoProperty(_mapping, "Input", input);
		_undoRedo.AddUndoProperty(_mapping, "Input", _mapping.Input);
		_undoRedo.CommitAction();

		if (IsInstanceValid(input)) EditorInterface.Singleton.EditResource(_mapping.Input);
	}

	private void _OnEditInputButtonPressed() {
		var dialog = BindingDialogScene.Instantiate<BindingDialog>();
		EditorInterface.Singleton.PopupDialogCentered(dialog);
		dialog.Initialize();
		dialog.InputSelected += _OnInputChanged;
	}

	private void _OnClearInputButtonPressed() {
		_undoRedo.CreateAction("Delete bound input");
		_undoRedo.AddDoProperty(_mapping, "Input", default(Variant));
		_undoRedo.AddUndoProperty(_mapping, "Input", _mapping.Input);
		_undoRedo.CommitAction();
	}

	private void _OnAddModifierPopupIndexPressed(int index) {
		var script = _addModifierPopup.GetItemMetadata(index).As<Script>();
		var newModifier = script.Call("new").As<GUIDEModifier>();

		_undoRedo.CreateAction($"Add {newModifier._EditorName()} modifier");
		var modifiers = new Godot.Collections.Array<GUIDEModifier>(_mapping.Modifiers);
		modifiers.Add(newModifier);
		_undoRedo.AddDoProperty(_mapping, "Modifiers", modifiers);
		_undoRedo.AddUndoProperty(_mapping, "Modifiers", _mapping.Modifiers);
		_undoRedo.CommitAction();
	}

	private void _OnAddTriggerPopupIndexPressed(int index) {
		var script = _addTriggerPopup.GetItemMetadata(index).As<Script>();
		var newTrigger = script.Call("new").As<GUIDETrigger>();

		_undoRedo.CreateAction($"Add {newTrigger._EditorName()} trigger");
		var triggers = new Godot.Collections.Array<GUIDETrigger>(_mapping.Triggers);
		triggers.Add(newTrigger);
		_undoRedo.AddDoProperty(_mapping, "Triggers", triggers);
		_undoRedo.AddUndoProperty(_mapping, "Triggers", _mapping.Triggers);
		_undoRedo.CommitAction();
	}

	private void _OnModifierChanged(int index, Control slot) {
		var newModifier = slot.Get("modifier").As<GUIDEModifier>();
		_undoRedo.CreateAction("Replace modifier");
		var modifiers = new Godot.Collections.Array<GUIDEModifier>(_mapping.Modifiers);
		modifiers[index] = newModifier;
		_undoRedo.AddDoProperty(_mapping, "Modifiers", modifiers);
		_undoRedo.AddUndoProperty(_mapping, "Modifiers", _mapping.Modifiers);
		_undoRedo.CommitAction();
	}

	private void _OnTriggerChanged(int index, Control slot) {
		var newTrigger = slot.Get("trigger").As<GUIDETrigger>();
		_undoRedo.CreateAction("Replace trigger");
		var triggers = new Godot.Collections.Array<GUIDETrigger>(_mapping.Triggers);
		triggers[index] = newTrigger;
		_undoRedo.AddDoProperty(_mapping, "Triggers", triggers);
		_undoRedo.AddUndoProperty(_mapping, "Triggers", _mapping.Triggers);
		_undoRedo.CommitAction();
	}

	private void _OnModifierMoveRequested(int from, int to) {
		_undoRedo.CreateAction("Move modifier");
		var modifiers = new Godot.Collections.Array<GUIDEModifier>(_mapping.Modifiers);
		var modifier = modifiers[from];
		modifiers.RemoveAt(from);
		if (from < to) to--;
		modifiers.Insert(to, modifier);
		_undoRedo.AddDoProperty(_mapping, "Modifiers", modifiers);
		_undoRedo.AddUndoProperty(_mapping, "Modifiers", _mapping.Modifiers);
		_undoRedo.CommitAction();
	}

	private void _OnTriggerMoveRequested(int from, int to) {
		_undoRedo.CreateAction("Move trigger");
		var triggers = new Godot.Collections.Array<GUIDETrigger>(_mapping.Triggers);
		var trigger = triggers[from];
		triggers.RemoveAt(from);
		if (from < to) to--;
		triggers.Insert(to, trigger);
		_undoRedo.AddDoProperty(_mapping, "Triggers", triggers);
		_undoRedo.AddUndoProperty(_mapping, "Triggers", _mapping.Triggers);
		_undoRedo.CommitAction();
	}

	private void _OnModifierDuplicateRequested(int index) {
		_undoRedo.CreateAction("Duplicate modifier");
		var modifiers = new Godot.Collections.Array<GUIDEModifier>(_mapping.Modifiers);
		var copy = (GUIDEModifier)EditorUtils.DuplicateIfInline(modifiers[index]);
		modifiers.Insert(index + 1, copy);
		_undoRedo.AddDoProperty(_mapping, "Modifiers", modifiers);
		_undoRedo.AddUndoProperty(_mapping, "Modifiers", _mapping.Modifiers);
		_undoRedo.CommitAction();
	}

	private void _OnTriggerDuplicateRequested(int index) {
		_undoRedo.CreateAction("Duplicate trigger");
		var triggers = new Godot.Collections.Array<GUIDETrigger>(_mapping.Triggers);
		var copy = (GUIDETrigger)EditorUtils.DuplicateIfInline(triggers[index]);
		triggers.Insert(index + 1, copy);
		_undoRedo.AddDoProperty(_mapping, "Triggers", triggers);
		_undoRedo.AddUndoProperty(_mapping, "Triggers", _mapping.Triggers);
		_undoRedo.CommitAction();
	}

	private void _OnModifierDeleteRequested(int index) {
		_undoRedo.CreateAction("Delete modifier");
		var modifiers = new Godot.Collections.Array<GUIDEModifier>(_mapping.Modifiers);
		modifiers.RemoveAt(index);
		_undoRedo.AddDoProperty(_mapping, "Modifiers", modifiers);
		_undoRedo.AddUndoProperty(_mapping, "Modifiers", _mapping.Modifiers);
		_undoRedo.CommitAction();
	}

	private void _OnTriggerDeleteRequested(int index) {
		_undoRedo.CreateAction("Delete trigger");
		var triggers = new Godot.Collections.Array<GUIDETrigger>(_mapping.Triggers);
		triggers.RemoveAt(index);
		_undoRedo.AddDoProperty(_mapping, "Triggers", triggers);
		_undoRedo.AddUndoProperty(_mapping, "Triggers", _mapping.Triggers);
		_undoRedo.CommitAction();
	}

	private void _OnModifiersClearRequested() {
		_undoRedo.CreateAction("Clear modifiers");
		var value = new Godot.Collections.Array<GUIDEModifier>();
		_undoRedo.AddDoProperty(_mapping, "Modifiers", value);
		_undoRedo.AddUndoProperty(_mapping, "Modifiers", _mapping.Modifiers);
		_undoRedo.CommitAction();
	}

	private void _OnTriggersClearRequested() {
		_undoRedo.CreateAction("Clear triggers");
		var value = new Godot.Collections.Array<GUIDETrigger>();
		_undoRedo.AddDoProperty(_mapping, "Triggers", value);
		_undoRedo.AddUndoProperty(_mapping, "Triggers", _mapping.Triggers);
		_undoRedo.CommitAction();
	}

	private void _OnModifiersCollapseStateChanged(bool newState) => _mapping.SetMeta("_guide_modifiers_collapsed", newState);
	private void _OnTriggersCollapseStateChanged(bool newState) => _mapping.SetMeta("_guide_triggers_collapsed", newState);

	private void _OnEditInputMappingButtonPressed() => EditorInterface.Singleton.EditResource(_mapping);
}
