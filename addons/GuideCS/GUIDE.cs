using System;
using System.Collections.Generic;
using System.Linq;
using Godot;

namespace Guide;

public partial class GUIDE : Node {
	public static GUIDE Singleton { get; private set; }

	[Signal]
	public delegate void InputMappingsChangedEventHandler();

	internal Dictionary<GUIDEMappingContext, int> _ActiveContexts = [];
	internal List<GUIDEActionMapping> _ActiveActionMappings = [];
	internal GUIDERemappingConfig _ActiveRemappingConfig;
	internal GUIDESet _ActiveInputs = new();
	internal GUIDESet _ActiveModifiers = new();
	internal Dictionary<GUIDEAction, List<GUIDEAction>> _ActionsSharingInput = new();
	internal GUIDEReset _ResetNode;
	internal GUIDEInputState _InputState;
	private bool _locked = false;

	public override void _Ready() {
		Singleton = this;
		ProcessMode = ProcessModeEnum.Always;
		_ResetNode = new GUIDEReset();
		_InputState = new GUIDEInputState();
		_InputState._Reset();
		AddChild(_ResetNode);

		Callable.From((Viewport vp) => GUIDEInputTracker._Instrument(vp)).CallDeferred(GetViewport());

		GetTree().NodeAdded += _OnNodeAdded;

		Input.JoyConnectionChanged += (device, connected) => EmitSignal(SignalName.InputMappingsChanged);
	}

	private void _OnNodeAdded(Node node) {
		if (node is Window window) {
			GUIDEInputTracker._Instrument(window);
		}
	}

	public void InjectInput(InputEvent @event) {
		if (@event is InputEventAction) return;
		_InputState._Input(@event);
	}

	public void SetRemappingConfig(GUIDERemappingConfig config) {
		_ActiveRemappingConfig = config;
		_UpdateCaches();
	}

	public void EnableMappingContext(GUIDEMappingContext context, bool disableOthers = false, int priority = 0) {
		if (!IsInstanceValid(context)) {
			GD.PushError("Null context given. Ignoring.");
			return;
		}

		if (disableOthers) {
			_ActiveContexts.Clear();
		}

		_ActiveContexts[context] = priority;
		_UpdateCaches();
		context.EmitSignal(GUIDEMappingContext.SignalName.Enabled);
	}

	public void DisableMappingContext(GUIDEMappingContext context) {
		if (!IsInstanceValid(context)) {
			GD.PushError("Null context given. Ignoring.");
			return;
		}

		_ActiveContexts.Remove(context);
		_UpdateCaches();
		context.EmitSignal(GUIDEMappingContext.SignalName.Disabled);
	}

	public bool IsMappingContextEnabled(GUIDEMappingContext context) {
		return _ActiveContexts.ContainsKey(context);
	}

	public GUIDEMappingContext[] GetEnabledMappingContexts() {
		return _ActiveContexts.Keys.ToArray();
	}

	public override void _PhysicsProcess(double delta) {
		foreach (var modifierObj in _ActiveModifiers.Values()) {
			if (modifierObj.As<GUIDEModifier>() is var modifier) {
				modifier._PhysicsProcess((float)delta);
			}
		}
	}

	public override void _Process(double delta) {
		var blockedActions = new GUIDESet();

		foreach (var actionMapping in _ActiveActionMappings) {
			var action = actionMapping.Action;
			Vector3 consolidatedValue = Vector3.Zero;
			GUIDETrigger.GUIDETriggerState consolidatedTriggerState = GUIDETrigger.GUIDETriggerState.None;

			foreach (var inputMapping in actionMapping.InputMappings) {
				inputMapping._UpdateState((float)delta, action.ActionValueType);
				consolidatedValue += inputMapping._value;
				consolidatedTriggerState = (GUIDETrigger.GUIDETriggerState)Math.Max((int)consolidatedTriggerState, (int)inputMapping._state);
			}

			if (blockedActions.Has(action)) {
				consolidatedTriggerState = GUIDETrigger.GUIDETriggerState.None;
			}

			if (action.BlockLowerPriorityActions &&
				consolidatedTriggerState == GUIDETrigger.GUIDETriggerState.Triggered &&
				_ActionsSharingInput.ContainsKey(action)) {
				foreach (var blockedAction in _ActionsSharingInput[action]) {
					blockedActions.Add(blockedAction);
				}
			}

			switch (action.LastState) {
				case GUIDEAction.GUIDEActionState.Triggered:
					switch (consolidatedTriggerState) {
						case GUIDETrigger.GUIDETriggerState.None:
							action._Completed(consolidatedValue);
							break;
						case GUIDETrigger.GUIDETriggerState.Ongoing:
							action._Ongoing(consolidatedValue, (float)delta);
							break;
						case GUIDETrigger.GUIDETriggerState.Triggered:
							action._Triggered(consolidatedValue, (float)delta);
							break;
					}
					break;

				case GUIDEAction.GUIDEActionState.Ongoing:
					switch (consolidatedTriggerState) {
						case GUIDETrigger.GUIDETriggerState.None:
							action._Cancelled(consolidatedValue);
							break;
						case GUIDETrigger.GUIDETriggerState.Ongoing:
							action._Ongoing(consolidatedValue, (float)delta);
							break;
						case GUIDETrigger.GUIDETriggerState.Triggered:
							action._Triggered(consolidatedValue, (float)delta);
							break;
					}
					break;

				case GUIDEAction.GUIDEActionState.Completed:
					switch (consolidatedTriggerState) {
						case GUIDETrigger.GUIDETriggerState.None:
							action._UpdateValue(consolidatedValue);
							break;
						case GUIDETrigger.GUIDETriggerState.Ongoing:
							action._Started(consolidatedValue);
							break;
						case GUIDETrigger.GUIDETriggerState.Triggered:
							action._Triggered(consolidatedValue, (float)delta);
							break;
					}
					break;
			}
		}
	}

	internal void _UpdateCaches() {
		if (_locked) {
			GD.PushError("Mapping context changed again while processing a change. Ignoring to avoid endless loop.");
			return;
		}

		_locked = true;

		var sortedContexts = _ActiveContexts.Keys.ToList();
		sortedContexts.Sort((a, b) => _ActiveContexts[a].CompareTo(_ActiveContexts[b]));

		var processedActions = new GUIDESet();
		var newInputs = new GUIDESet();
		var newActionMappings = new List<GUIDEActionMapping>();
		var newModifiers = new GUIDESet();

		foreach (var context in sortedContexts) {
			foreach (var actionMapping in context.Mappings) {
				foreach (var existingMapping in _ActiveActionMappings) {
					if (_IsSameActionMapping(existingMapping, actionMapping)) {
						foreach (var inputMapping in existingMapping.InputMappings) {
							if (inputMapping.Input != null) {
								newInputs.Add(inputMapping.Input);
							}

							foreach (var modifier in inputMapping.Modifiers) {
								newModifiers.Add(modifier);
							}
						}
					}
				}
			}
		}

		foreach (var context in sortedContexts) {
			int position = 0;
			foreach (var actionMapping in context.Mappings) {
				position++;
				var action = actionMapping.Action;

				if (action == null) {
					GD.PushWarning($"Mapping at position {position} in context {context.ResourcePath} has no action set. This mapping will be ignored.");
					continue;
				}

				if (processedActions.Has(action)) continue;

				processedActions.Add(action);

				bool foundExisting = false;
				foreach (var existingMapping in _ActiveActionMappings) {
					if (_IsSameActionMapping(existingMapping, actionMapping)) {
						newActionMappings.Add(existingMapping);
						foundExisting = true;
						break;
					}
				}

				if (foundExisting) continue;

				var effectiveMapping = new GUIDEActionMapping();
				effectiveMapping.Action = action;
				_CopyMeta(actionMapping, effectiveMapping);

				float triggerHoldThreshold = -1.0f;

				foreach (var inputMapping in actionMapping.InputMappings) {
					var boundInput = inputMapping.Input;

					if (_ActiveRemappingConfig != null &&
						_ActiveRemappingConfig._Has(context, action, actionMapping.InputMappings.IndexOf(inputMapping))) {
						boundInput = _ActiveRemappingConfig._GetBoundInputOrNull(context, action, actionMapping.InputMappings.IndexOf(inputMapping));
					}

					var newInputMapping = new GUIDEInputMapping();

					if (boundInput != null) {
						var existing = newInputs.FirstMatch(it => it.As<GUIDEInput>().IsSameAs(boundInput)).As<GUIDEInput>();
						if (existing == null) {
							existing = _ActiveInputs.FirstMatch(it => it.As<GUIDEInput>().IsSameAs(boundInput)).As<GUIDEInput>();
						}

						if (existing != null) {
							boundInput = existing;
						}

						if (!_IsUsed(boundInput)) {
							boundInput._State = _InputState;
							boundInput._BeginUsage();
							_MarkUsed(boundInput, true);
						}

						newInputs.Add(boundInput);
					}

					newInputMapping.Input = boundInput;
					newInputMapping.DisplayName = inputMapping.DisplayName;
					newInputMapping.DisplayCategory = inputMapping.DisplayCategory;
					newInputMapping.OverrideActionSettings = inputMapping.OverrideActionSettings;
					newInputMapping.IsRemappable = inputMapping.IsRemappable;
					_CopyMeta(inputMapping, newInputMapping);

					newInputMapping.Modifiers = inputMapping.Modifiers;
					foreach (var modifier in newInputMapping.Modifiers) {
						newModifiers.Add(modifier);
						if (!_IsUsed(modifier)) {
							modifier._BeginUsage();
							_MarkUsed(modifier, true);
						}
					}

					newInputMapping.Triggers = new Godot.Collections.Array<GUIDETrigger>(inputMapping.Triggers.Select(t => (GUIDETrigger)t.Duplicate()));

					newInputMapping._Initialize(action.ActionValueType);
					float mappingHoldThreshold = newInputMapping._triggerHoldThreshold;
					if (triggerHoldThreshold < 0 || (mappingHoldThreshold >= 0 && mappingHoldThreshold < triggerHoldThreshold)) {
						triggerHoldThreshold = mappingHoldThreshold;
					}

					effectiveMapping.InputMappings.Add(newInputMapping);
				}

				action._triggerHoldThreshold = triggerHoldThreshold;

				if (effectiveMapping.InputMappings.Count > 0) {
					newActionMappings.Add(effectiveMapping);
				}
			}
		}

		foreach (var inputObj in _ActiveInputs.Values()) {
			var input = inputObj.As<GUIDEInput>();
			if (newInputs.Has(input)) continue;

			input._Reset();
			input._EndUsage();
			input._State = null;
			_MarkUsed(input, false);
		}

		_ActiveInputs = newInputs;
		_ActiveModifiers = newModifiers.Filter(it => it.As<GUIDEModifier>()._NeedsPhysicsProcess());
		SetPhysicsProcess(_ActiveModifiers.Size() > 0);

		foreach (var mapping in _ActiveActionMappings) {
			if (newActionMappings.Contains(mapping)) continue;

			switch (mapping.Action.LastState) {
				case GUIDEAction.GUIDEActionState.Ongoing:
					mapping.Action._Cancelled(Vector3.Zero);
					break;
				case GUIDEAction.GUIDEActionState.Triggered:
					mapping.Action._Completed(Vector3.Zero);
					break;
			}

			foreach (var inputMapping in mapping.InputMappings) {
				foreach (var modifier in inputMapping.Modifiers) {
					if (!newModifiers.Has(modifier)) {
						modifier._EndUsage();
						_MarkUsed(modifier, false);
					}
				}
			}
		}

		_ActiveActionMappings = newActionMappings;

		_ActionsSharingInput.Clear();
		for (int i = 0; i < _ActiveActionMappings.Count; i++) {
			var mapping = _ActiveActionMappings[i];
			if (mapping.Action.BlockLowerPriorityActions) {
				var chordedActions = new GUIDESet();
				var inputs = new GUIDESet();
				var blockedActions = new GUIDESet();

				foreach (var inputMapping in mapping.InputMappings) {
					if (inputMapping.Input != null) inputs.Add(inputMapping.Input);
					foreach (var trigger in inputMapping.Triggers) {
						if (trigger is GUIDETriggerChordedAction chordedTrigger && chordedTrigger.Action != null) {
							chordedActions.Add(chordedTrigger.Action);
						}
					}
				}

				for (int j = i + 1; j < _ActiveActionMappings.Count; j++) {
					var innerMapping = _ActiveActionMappings[j];
					if (chordedActions.Has(innerMapping.Action)) {
						foreach (var inputMapping in innerMapping.InputMappings) {
							if (inputMapping.Input != null) inputs.Add(inputMapping.Input);
							foreach (var trigger in inputMapping.Triggers) {
								if (trigger is GUIDETriggerChordedAction chordedTrigger && chordedTrigger.Action != null) {
									chordedActions.Add(chordedTrigger.Action);
								}
							}
						}
					}
				}

				for (int j = i + 1; j < _ActiveActionMappings.Count; j++) {
					var innerMapping = _ActiveActionMappings[j];
					if (chordedActions.Has(innerMapping.Action)) continue;

					foreach (var inputMapping in innerMapping.InputMappings) {
						if (inputMapping.Input == null) continue;
						if (inputs.Has(inputMapping.Input)) {
							blockedActions.Add(innerMapping.Action);
							break;
						}
					}
				}

				if (!blockedActions.IsEmpty()) {
					_ActionsSharingInput[mapping.Action] = blockedActions.Values().Select(v => v.As<GUIDEAction>()).ToList();
				}
			}
		}

		_ResetNode._inputsToReset.Clear();
		foreach (var inputObj in _ActiveInputs.Values()) {
			var input = inputObj.As<GUIDEInput>();
			if (input._NeedsReset()) {
				_ResetNode._inputsToReset.Add(input);
			}
		}

		_Process(0.0);
		_locked = false;
		EmitSignal(SignalName.InputMappingsChanged);
	}

	internal static bool _IsSameActionMapping(GUIDEActionMapping a, GUIDEActionMapping b) {
		if (a == b) return true;
		if (a.Action != b.Action) return false;
		if (a.InputMappings.Count != b.InputMappings.Count) return false;

		for (int i = 0; i < a.InputMappings.Count; i++) {
			var inputMappingA = a.InputMappings[i];
			var inputMappingB = b.InputMappings[i];

			if (inputMappingA.Input != null && inputMappingB.Input != null) {
				if (!inputMappingA.Input.IsSameAs(inputMappingB.Input)) return false;
			}
			else if (inputMappingA.Input != inputMappingB.Input) {
				return false;
			}

			if (inputMappingA.Modifiers.Count != inputMappingB.Modifiers.Count) return false;
			for (int j = 0; j < inputMappingA.Modifiers.Count; j++) {
				var modifierA = inputMappingA.Modifiers[j];
				var modifierB = inputMappingB.Modifiers[j];
				if (modifierA != null && modifierB != null) {
					if (!modifierA.IsSameAs(modifierB)) return false;
				}
				else if (modifierA != modifierB) {
					return false;
				}
			}

			if (inputMappingA.Triggers.Count != inputMappingB.Triggers.Count) return false;
			for (int j = 0; j < inputMappingA.Triggers.Count; j++) {
				var triggerA = inputMappingA.Triggers[j];
				var triggerB = inputMappingB.Triggers[j];
				if (triggerA != null && triggerB != null) {
					if (!triggerA.IsSameAs(triggerB)) return false;
				}
				else if (triggerA != triggerB) {
					return false;
				}
			}
		}

		return true;
	}

	internal static void _MarkUsed(GodotObject @object, bool value) {
		if (value) {
			@object.SetMeta("__guide_in_use", value);
		}
		else {
			@object.RemoveMeta("__guide_in_use");
		}
	}

	internal static bool _IsUsed(GodotObject @object) {
		return @object.HasMeta("__guide_in_use");
	}

	internal static void _CopyMeta(GodotObject source, GodotObject target) {
		var keys = source.GetMetaList();
		foreach (var key in keys) {
			target.SetMeta(key, source.GetMeta(key));
		}
	}
}
