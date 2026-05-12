using System;
using System.Collections.Generic;
using System.Linq;
using Godot;

namespace Guide;

[Tool]
public partial class MappingContextEditor : MarginContainer {
	[Export] public PackedScene ActionMappingEditorScene { get; set; }

	private ArrayEdit _actionMappings;
	private Control _editingView;
	private Control _emptyView;
	private OptionButton _mappingContextSwitcher;

	private EditorPlugin _plugin;
	private GUIDEMappingContext _currentContext;
	private EditorUndoRedoManager _undoRedo;
	private bool _listDirty = true;

	public override void _Ready() {
		if (EditorUtils.IsNodeInEditedScene(this)) return;

		_actionMappings = GetNode<ArrayEdit>("%ActionMappings");
		_editingView = GetNode<Control>("%EditingView");
		_emptyView = GetNode<Control>("%EmptyView");
		_mappingContextSwitcher = GetNode<OptionButton>("%MappingContextSwitcher");

		_editingView.Visible = false;
		_emptyView.Visible = true;

		_actionMappings.AddRequested += _OnActionMappingsAddRequested;
		_actionMappings.MoveRequested += _OnActionMappingsMoveRequested;
		_actionMappings.DeleteRequested += _OnActionMappingDeleteRequested;
		_actionMappings.ClearRequested += _OnActionMappingsClearRequested;
		_actionMappings.DuplicateRequested += _OnActionMappingDuplicateRequested;
		_actionMappings.CollapseStateChanged += _OnActionMappingsCollapseStateChanged;

		_mappingContextSwitcher.ItemSelected += _OnMappingContextSwitchRequested;

		VisibilityChanged += () => { if (Visible) _UpdateList(); };
	}

	public void Initialize(EditorPlugin plugin) {
		_plugin = plugin;
		_undoRedo = _plugin.GetUndoRedo();
		var filesystem = EditorInterface.Singleton.GetResourceFilesystem();
		filesystem.FilesystemChanged += () => _listDirty = true;
	}

	public void Edit(GUIDEMappingContext context) {
		if (IsInstanceValid(_currentContext)) _currentContext.Changed -= _Refresh;
		_currentContext = context;
		if (IsInstanceValid(_currentContext)) _currentContext.Changed += _Refresh;
		_Refresh();
	}

	private void _UpdateList() {
		if (!_listDirty) return;

		var contextPaths = ResourceScanner.FindResourcesOfType("GUIDEMappingContext");
		var shortened = _BuildShortenedPathMap(contextPaths);
		_mappingContextSwitcher.Clear();

		_mappingContextSwitcher.AddItem("Select mapping context...");
		_mappingContextSwitcher.SetItemMetadata(0, default);

		var keys = shortened.Keys.ToList();
		keys.Sort();

		for (int i = 0; i < keys.Count; i++) {
			var key = keys[i];
			var fullPath = shortened[key];
			int renderIndex = i + 1;
			_mappingContextSwitcher.AddItem(key);
			_mappingContextSwitcher.SetItemMetadata(renderIndex, fullPath);
			_mappingContextSwitcher.SetItemTooltip(renderIndex, fullPath);
		}

		_listDirty = false;
	}

	private void _Refresh() {
		_UpdateList();

		_editingView.Visible = IsInstanceValid(_currentContext);
		_emptyView.Visible = !IsInstanceValid(_currentContext);

		if (!IsInstanceValid(_currentContext)) return;

		_mappingContextSwitcher.TooltipText = _currentContext.ResourcePath;
		int selectedIndex = 0;
		for (int i = 0; i < _mappingContextSwitcher.ItemCount; i++) {
			if (_mappingContextSwitcher.GetItemMetadata(i).AsString() == _currentContext.ResourcePath) {
				selectedIndex = i;
				break;
			}
		}
		_mappingContextSwitcher.Select(selectedIndex);

		_actionMappings.Clear();

		for (int i = 0; i < _currentContext.Mappings.Count; i++) {
			var mapping = _currentContext.Mappings[i];
			var mappingEditor = ActionMappingEditorScene.Instantiate<ActionMappingEditor>();
			mappingEditor.Initialize(_plugin);
			_actionMappings.AddItem(mappingEditor);
			mappingEditor.Edit(mapping);
		}

		_actionMappings.Collapsed = (bool)_currentContext.GetMeta("_guide_action_mappings_collapsed", false);
	}

	private Dictionary<string, string> _BuildShortenedPathMap(string[] paths) {
		var partsPerPath = new List<List<string>>();
		foreach (var p in paths) {
			var withoutScheme = p.StartsWith("res://") ? p.Substring(6) : p;
			var comps = withoutScheme.Split('/', StringSplitOptions.RemoveEmptyEntries).ToList();
			comps.Reverse();
			partsPerPath.Add(comps);
		}

		var usedCounts = new int[paths.Length];
		for (int i = 0; i < usedCounts.Length; i++) usedCounts[i] = 1;

		string GetCurrentLabel(int idx) {
			var parts = partsPerPath[idx];
			int count = Math.Min(usedCounts[idx], parts.Count);
			var slice = parts.GetRange(0, count);
			slice.Reverse();
			return string.Join("/", slice);
		}

		while (true) {
			var labelToIndices = new Dictionary<string, List<int>>();
			for (int i = 0; i < paths.Length; i++) {
				var label = GetCurrentLabel(i);
				if (!labelToIndices.ContainsKey(label)) labelToIndices[label] = new List<int>();
				labelToIndices[label].Add(i);
			}

			bool hadCollision = false;
			foreach (var indices in labelToIndices.Values) {
				if (indices.Count > 1) {
					hadCollision = true;
					foreach (var idx in indices) {
						if (usedCounts[idx] < partsPerPath[idx].Count) usedCounts[idx]++;
					}
				}
			}

			if (!hadCollision) break;
		}

		var result = new Dictionary<string, string>();
		for (int i = 0; i < paths.Length; i++) {
			result[GetCurrentLabel(i)] = paths[i];
		}
		return result;
	}

	private void _OnMappingContextSwitchRequested(long index) {
		var mc = _mappingContextSwitcher.GetItemMetadata((int)index).AsString();
		if (!string.IsNullOrEmpty(mc)) {
			var context = GD.Load<GUIDEMappingContext>(mc);
			if (context != null && context != _currentContext) Edit(context);
		}
	}

	private void _OnActionMappingsAddRequested() {
		var mappings = new Godot.Collections.Array<GUIDEActionMapping>(_currentContext.Mappings);
		mappings.Add(new GUIDEActionMapping());
		_undoRedo.CreateAction("Add action mapping");
		_undoRedo.AddDoProperty(_currentContext, "Mappings", mappings);
		_undoRedo.AddUndoProperty(_currentContext, "Mappings", _currentContext.Mappings);
		_undoRedo.CommitAction();
	}

	private void _OnActionMappingsMoveRequested(int from, int to) {
		var mappings = new Godot.Collections.Array<GUIDEActionMapping>(_currentContext.Mappings);
		var mapping = mappings[from];
		mappings.RemoveAt(from);
		if (from < to) to--;
		mappings.Insert(to, mapping);
		_undoRedo.CreateAction("Move action mapping");
		_undoRedo.AddDoProperty(_currentContext, "Mappings", mappings);
		_undoRedo.AddUndoProperty(_currentContext, "Mappings", _currentContext.Mappings);
		_undoRedo.CommitAction();
	}

	private void _OnActionMappingDeleteRequested(int index) {
		var mappings = new Godot.Collections.Array<GUIDEActionMapping>(_currentContext.Mappings);
		mappings.RemoveAt(index);
		_undoRedo.CreateAction("Delete action mapping");
		_undoRedo.AddDoProperty(_currentContext, "Mappings", mappings);
		_undoRedo.AddUndoProperty(_currentContext, "Mappings", _currentContext.Mappings);
		_undoRedo.CommitAction();
	}

	private void _OnActionMappingsClearRequested() {
		_undoRedo.CreateAction("Clear action mappings");
		_undoRedo.AddDoProperty(_currentContext, "Mappings", new Godot.Collections.Array<GUIDEActionMapping>());
		_undoRedo.AddUndoProperty(_currentContext, "Mappings", _currentContext.Mappings);
		_undoRedo.CommitAction();
	}

	private void _OnActionMappingDuplicateRequested(int index) {
		var mappings = new Godot.Collections.Array<GUIDEActionMapping>(_currentContext.Mappings);
		var toDuplicate = mappings[index];
		var copy = new GUIDEActionMapping();
		foreach (var inputMapping in toDuplicate.InputMappings) {
			var copiedInputMapping = new GUIDEInputMapping();
			copiedInputMapping.Input = (GUIDEInput)EditorUtils.DuplicateIfInline(inputMapping.Input);
			foreach (var modifier in inputMapping.Modifiers) copiedInputMapping.Modifiers.Add((GUIDEModifier)EditorUtils.DuplicateIfInline(modifier));
			foreach (var trigger in inputMapping.Triggers) copiedInputMapping.Triggers.Add((GUIDETrigger)EditorUtils.DuplicateIfInline(trigger));
			copy.InputMappings.Add(copiedInputMapping);
		}
		mappings.Insert(index + 1, copy);
		_undoRedo.CreateAction("Duplicate action mapping");
		_undoRedo.AddDoProperty(_currentContext, "Mappings", mappings);
		_undoRedo.AddUndoProperty(_currentContext, "Mappings", _currentContext.Mappings);
		_undoRedo.CommitAction();
	}

	private void _OnActionMappingsCollapseStateChanged(bool newState) => _currentContext.SetMeta("_guide_action_mappings_collapsed", newState);
}
