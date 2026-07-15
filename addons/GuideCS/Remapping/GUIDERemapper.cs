using System;
using System.Collections.Generic;
using System.Linq;
using Godot;

namespace Guide;

public partial class GUIDERemapper : RefCounted {
	[Signal] public delegate void ItemChangedEventHandler(ConfigItem item, GUIDEInput input);

	private GUIDERemappingConfig _remappingConfig = new();
	private List<GUIDEMappingContext> _mappingContexts = new();

	public void Initialize(IEnumerable<GUIDEMappingContext> mappingContexts, GUIDERemappingConfig remappingConfig) {
		_remappingConfig = (GUIDERemappingConfig)remappingConfig?.Duplicate() ?? new GUIDERemappingConfig();
		_mappingContexts.Clear();

		foreach (var mappingContext in mappingContexts) {
			if (!IsInstanceValid(mappingContext)) {
				GD.PushError("Cannot add null mapping context. Ignoring.");
				continue;
			}
			_mappingContexts.Add(mappingContext);
		}
	}

	public GUIDERemappingConfig GetMappingConfig() => (GUIDERemappingConfig)_remappingConfig.Duplicate();

	public void SetCustomData(Variant key, Variant value) => _remappingConfig.custom_data[key] = value;

	public Variant GetCustomData(Variant key, Variant defaultValue = default) => _remappingConfig.custom_data.TryGetValue(key, out var val) ? val : defaultValue;

	public void RemoveCustomData(Variant key) => _remappingConfig.custom_data.Remove(key);

	public ConfigItem[] GetRemappableItems(GUIDEMappingContext context = null, string displayCategory = "", GUIDEAction action = null) {
		if (action != null && !action.IsRemappable) {
			GD.PushWarning("Action filter was set but filtered action is not remappable.");
			return Array.Empty<ConfigItem>();
		}

		var result = new List<ConfigItem>();
		foreach (var aContext in _mappingContexts) {
			if (context != null && context != aContext) continue;
			foreach (var actionMapping in aContext.Mappings) {
				var mappedAction = actionMapping.Action;
				if (!mappedAction.IsRemappable) continue;
				if (action != null && action != mappedAction) continue;

				for (int index = 0; index < actionMapping.InputMappings.Count; index++) {
					var inputMapping = actionMapping.InputMappings[index];
					if (inputMapping.OverrideActionSettings && !inputMapping.IsRemappable) continue;

					var effectiveDisplayCategory = GetEffectiveDisplayCategory(mappedAction, inputMapping);
					if (!string.IsNullOrEmpty(displayCategory) && effectiveDisplayCategory != displayCategory) continue;

					var item = new ConfigItem(aContext, actionMapping.Action, index, inputMapping);
					ItemChanged += item._ItemChanged;
					result.Add(item);
				}
			}
		}
		return result.ToArray();
	}

	public static string GetEffectiveDisplayCategory(GUIDEAction action, GUIDEInputMapping inputMapping) {
		string result = inputMapping.OverrideActionSettings ? inputMapping.DisplayCategory : "";
		if (string.IsNullOrEmpty(result)) result = action.DisplayCategory;
		return result;
	}

	public static string GetEffectiveDisplayName(GUIDEAction action, GUIDEInputMapping inputMapping) {
		string result = inputMapping.OverrideActionSettings ? inputMapping.DisplayName : "";
		if (string.IsNullOrEmpty(result)) result = action.DisplayName;
		return result;
	}

	public static bool IsEffectivelyRemappable(GUIDEAction action, GUIDEInputMapping inputMapping) {
		return action.IsRemappable && (!inputMapping.OverrideActionSettings || inputMapping.IsRemappable);
	}

	public static GUIDEAction.GUIDEActionValueType GetEffectiveValueType(GUIDEAction action, GUIDEInputMapping inputMapping) {
		if (inputMapping.OverrideActionSettings && inputMapping.Input != null) {
			return inputMapping.Input._NativeValueType();
		}
		return action.ActionValueType;
	}

	public ConfigItem[] GetInputCollisions(ConfigItem item, GUIDEInput input) {
		if (!_CheckItem(item)) return Array.Empty<ConfigItem>();
		if (input == null) return Array.Empty<ConfigItem>();

		var result = new List<ConfigItem>();
		foreach (var context in _mappingContexts) {
			foreach (var actionMapping in context.Mappings) {
				for (int index = 0; index < actionMapping.InputMappings.Count; index++) {
					var action = actionMapping.Action;
					if (context == item.Context && action == item.Action && index == item.Index) continue;

					var inputMapping = actionMapping.InputMappings[index];
					var boundInput = inputMapping.Input;
					if (_remappingConfig._Has(context, action, index)) {
						boundInput = _remappingConfig._GetBoundInputOrNull(context, action, index);
					}

					if (boundInput != null && boundInput.IsSameAs(input)) {
						var collisionItem = new ConfigItem(context, action, index, inputMapping);
						ItemChanged += collisionItem._ItemChanged;
						result.Add(collisionItem);
					}
				}
			}
		}
		return result.ToArray();
	}

	public GUIDEInput GetBoundInputOrNull(ConfigItem item) {
		if (!_CheckItem(item)) return null;

		if (_remappingConfig._Has(item.Context, item.Action, item.Index)) {
			return _remappingConfig._GetBoundInputOrNull(item.Context, item.Action, item.Index);
		}

		foreach (var actionMapping in item.Context.Mappings) {
			if (actionMapping.Action == item.Action) {
				if (actionMapping.InputMappings.Count > item.Index) {
					return actionMapping.InputMappings[item.Index].Input;
				}
				else {
					GD.PushError($"Action mapping does not have an index of {item.Index}.");
				}
			}
		}
		return null;
	}

	public void SetBoundInput(ConfigItem item, GUIDEInput input) {
		if (!_CheckItem(item)) return;

		_remappingConfig._Clear(item.Context, item.Action, item.Index);
		var boundInput = GetBoundInputOrNull(item);

		if (boundInput == null && input == null) {
			EmitSignal(SignalName.ItemChanged, item, input);
			return;
		}

		if (boundInput == null) {
			_remappingConfig._Bind(item.Context, item.Action, input, item.Index);
			EmitSignal(SignalName.ItemChanged, item, input);
			return;
		}

		if (input != null && boundInput.IsSameAs(input)) {
			EmitSignal(SignalName.ItemChanged, item, input);
			return;
		}

		_remappingConfig._Bind(item.Context, item.Action, input, item.Index);
		EmitSignal(SignalName.ItemChanged, item, input);
	}

	public GUIDEInput GetDefaultInput(ConfigItem item) {
		if (!_CheckItem(item)) return null;
		foreach (var mapping in item.Context.Mappings) {
			if (mapping.Action == item.Action) return mapping.InputMappings[item.Index].Input;
		}
		return null;
	}

	public void RestoreDefaultFor(ConfigItem item) {
		if (!_CheckItem(item)) return;
		_remappingConfig._Clear(item.Context, item.Action, item.Index);
		EmitSignal(SignalName.ItemChanged, item, GetBoundInputOrNull(item));
	}

	private bool _CheckItem(ConfigItem item) {
		if (!_mappingContexts.Contains(item.Context)) {
			GD.PushError("Given context is not known to this mapper. Did you call initialize()?");
			return false;
		}

		bool actionFound = false;
		bool sizeOk = false;
		foreach (var mapping in item.Context.Mappings) {
			if (mapping.Action == item.Action) {
				actionFound = true;
				if (item.Index >= 0 && mapping.InputMappings.Count > item.Index) sizeOk = true;
				break;
			}
		}

		if (!actionFound) {
			GD.PushError("Given action does not belong to the given context.");
			return false;
		}

		if (!sizeOk) {
			GD.PushError($"Given index {item.Index} does not exist for the given action's input binding.");
			return false;
		}

		if (!item.Action.IsRemappable) {
			GD.PushError("Given action is not remappable.");
			return false;
		}

		return true;
	}

	public partial class ConfigItem : RefCounted {
		[Signal] public delegate void ChangedEventHandler(GUIDEInput input);

		private GUIDEInputMapping _inputMapping;

		public string DisplayCategory => GUIDERemapper.GetEffectiveDisplayCategory(Action, _inputMapping);
		public string DisplayName => GUIDERemapper.GetEffectiveDisplayName(Action, _inputMapping);
		public bool IsRemappable => GUIDERemapper.IsEffectivelyRemappable(Action, _inputMapping);
		public GUIDEAction.GUIDEActionValueType ValueType => GUIDERemapper.GetEffectiveValueType(Action, _inputMapping);

		public GUIDEMappingContext Context { get; private set; }
		public GUIDEAction Action { get; private set; }
		public int Index { get; private set; }

		public ConfigItem(GUIDEMappingContext context, GUIDEAction action, int index, GUIDEInputMapping inputMapping) {
			Context = context;
			Action = action;
			Index = index;
			_inputMapping = inputMapping;
		}

		public bool IsSameAs(ConfigItem other) => Context == other.Context && Action == other.Action && Index == other.Index;

		internal void _ItemChanged(ConfigItem item, GUIDEInput input) {
			if (IsSameAs(item)) EmitSignal(SignalName.Changed, input);
		}
	}
}
