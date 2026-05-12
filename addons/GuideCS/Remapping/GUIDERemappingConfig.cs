using Godot;
using Godot.Collections;

namespace Guide;

[GlobalClass, Icon("res://addons/GuideCS/GUIDEInternal.svg")]
public partial class GUIDERemappingConfig : Resource {
	[Export]
	public Dictionary remapped_inputs = new();

	[Export]
	public Dictionary custom_data = new();

	internal void _Bind(GUIDEMappingContext mappingContext, GUIDEAction action, GUIDEInput input, int index = 0) {
		if (!remapped_inputs.ContainsKey(mappingContext)) {
			remapped_inputs[mappingContext] = new Dictionary();
		}

		var contextDict = (Dictionary)remapped_inputs[mappingContext];
		if (!contextDict.ContainsKey(action)) {
			contextDict[action] = new Dictionary();
		}

		var actionDict = (Dictionary)contextDict[action];
		actionDict[index] = input;
	}

	internal void _Unbind(GUIDEMappingContext mappingContext, GUIDEAction action, int index = 0) {
		_Bind(mappingContext, action, null, index);
	}

	internal void _Clear(GUIDEMappingContext mappingContext, GUIDEAction action, int index = 0) {
		if (!remapped_inputs.ContainsKey(mappingContext)) return;

		var contextDict = (Dictionary)remapped_inputs[mappingContext];
		if (!contextDict.ContainsKey(action)) return;

		var actionDict = (Dictionary)contextDict[action];
		actionDict.Remove(index);

		if (actionDict.Count == 0) {
			contextDict.Remove(action);
		}

		if (contextDict.Count == 0) {
			remapped_inputs.Remove(mappingContext);
		}
	}

	internal GUIDEInput _GetBoundInputOrNull(GUIDEMappingContext mappingContext, GUIDEAction action, int index = 0) {
		if (!remapped_inputs.ContainsKey(mappingContext)) return null;

		var contextDict = (Dictionary)remapped_inputs[mappingContext];
		if (!contextDict.ContainsKey(action)) return null;

		var actionDict = (Dictionary)contextDict[action];
		return actionDict.ContainsKey(index) ? actionDict[index].As<GUIDEInput>() : null;
	}

	internal bool _Has(GUIDEMappingContext mappingContext, GUIDEAction action, int index = 0) {
		if (!remapped_inputs.ContainsKey(mappingContext)) return false;

		var contextDict = (Dictionary)remapped_inputs[mappingContext];
		if (!contextDict.ContainsKey(action)) return false;

		var actionDict = (Dictionary)contextDict[action];
		return actionDict.ContainsKey(index);
	}
}
