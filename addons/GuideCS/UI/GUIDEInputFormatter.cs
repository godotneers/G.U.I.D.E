using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Godot;

namespace Guide;

[Tool]
public partial class GUIDEInputFormatter : RefCounted {
	private static IconMaker _iconMaker;
	private static List<GUIDEIconRenderer> _iconRenderers = new();
	private static List<GUIDETextProvider> _textProviders = new();
	private static bool _isReady = false;

	public static string MixedInputSeparator = ", ";
	public static string ChordedInputSeparator = " + ";
	public static string ComboInputSeparator = " > ";

	private Callable _actionResolver;
	private int _iconSize;

	public GUIDEInputFormattingOptions formatting_options = new();

	public static void _EnsureReadiness() {
		if (_isReady) return;

		if (Engine.GetMainLoop() is not SceneTree tree) return;
		var root = tree.Root;

		foreach (Node child in root.GetChildren()) {
			if (child is IconMaker maker) {
				_iconMaker = maker;
				break;
			}
		}

		if (_iconMaker == null) {
			var scene = GD.Load<PackedScene>("res://addons/GuideCS/UI/IconMaker/IconMaker.tscn");
			_iconMaker = scene.Instantiate<IconMaker>();
			root.CallDeferred(Node.MethodName.AddChild, _iconMaker);
		}

		AddIconRenderer(GD.Load<PackedScene>("res://addons/GuideCS/UI/Renderers/Keyboard/GUIDEKeyRenderer.tscn").Instantiate<GUIDEIconRenderer>());
		AddIconRenderer(GD.Load<PackedScene>("res://addons/GuideCS/UI/Renderers/Mouse/GUIDEMouseRenderer.tscn").Instantiate<GUIDEIconRenderer>());
		AddIconRenderer(GD.Load<PackedScene>("res://addons/GuideCS/UI/Renderers/Touch/GUIDETouchRenderer.tscn").Instantiate<GUIDEIconRenderer>());
		AddIconRenderer(GD.Load<PackedScene>("res://addons/GuideCS/UI/Renderers/Misc/GUIDEActionRenderer.tscn").Instantiate<GUIDEIconRenderer>());
		AddIconRenderer(GD.Load<PackedScene>("res://addons/GuideCS/UI/Renderers/Joy/GUIDEJoyRenderer.tscn").Instantiate<GUIDEIconRenderer>());
		AddIconRenderer(GD.Load<PackedScene>("res://addons/GuideCS/UI/Renderers/Controllers/GUIDEControllerRenderer.tscn").Instantiate<GUIDEIconRenderer>());
		AddIconRenderer(GD.Load<PackedScene>("res://addons/GuideCS/UI/Renderers/Misc/GUIDEFallbackRenderer.tscn").Instantiate<GUIDEIconRenderer>());

		AddTextProvider(new DefaultTextProvider());
		AddTextProvider(new GUIDEControllerTextProvider());

		_isReady = true;
	}

	public static void Cleanup() {
		_isReady = false;
		foreach (var renderer in _iconRenderers) renderer.QueueFree();
		_iconRenderers.Clear();
		_textProviders.Clear();
		if (IsInstanceValid(_iconMaker)) _iconMaker.QueueFree();
	}

	public GUIDEInputFormatter(int iconSize = 32, Callable? resolver = null) {
		_iconSize = iconSize;
		_actionResolver = resolver ?? Callable.From((GUIDEAction a) => (GUIDEActionMapping)null);
	}

	public static void AddIconRenderer(GUIDEIconRenderer renderer) {
		_iconRenderers.Add(renderer);
		_iconRenderers.Sort((r1, r2) => r1.Priority.CompareTo(r2.Priority));
	}

	public static void RemoveIconRenderer(GUIDEIconRenderer renderer) => _iconRenderers.Remove(renderer);

	public static void AddTextProvider(GUIDETextProvider provider) {
		_textProviders.Add(provider);
		_textProviders.Sort((p1, p2) => p1.Priority.CompareTo(p2.Priority));
	}

	public static void RemoveTextProvider(GUIDETextProvider provider) => _textProviders.Remove(provider);

	public static GUIDEInputFormatter ForActiveContexts(int iconSize = 32) {
		var resolver = Callable.From((GUIDEAction action) => {
			return GUIDE.Singleton?._ActiveActionMappings.FirstOrDefault(m => m.Action == action);
		});
		return new GUIDEInputFormatter(iconSize, resolver);
	}

	public static GUIDEInputFormatter ForContext(GUIDEMappingContext context, int iconSize = 32) {
		var resolver = Callable.From((GUIDEAction action) => {
			return context.Mappings.FirstOrDefault(m => m.Action == action);
		});
		return new GUIDEInputFormatter(iconSize, resolver);
	}

	public async Task<string> ActionAsRichtextAsync(GUIDEAction action) => await _MaterializedAsRichtextAsync(_MaterializeActionInput(action));

	public string ActionAsText(GUIDEAction action) => _MaterializedAsText(_MaterializeActionInput(action));

	public async Task<string> InputAsRichtextAsync(GUIDEInput input, bool materializeActions = true) {
		return await _MaterializedAsRichtextAsync(_MaterializeInput(FormattingContext.ForInput(input), materializeActions));
	}

	public string InputAsText(GUIDEInput input, bool materializeActions = true) {
		return _MaterializedAsText(_MaterializeInput(FormattingContext.ForInput(input), materializeActions));
	}

	private string _MaterializedAsText(MaterializedInput input) {
		_EnsureReadiness();
		if (input is MaterializedSimpleInput simple) {
			foreach (var provider in _textProviders) {
				if (provider.Supports(simple.Input, formatting_options)) {
					return provider.GetText(simple.Input, formatting_options);
				}
			}
			return "";
		}

		var separator = _SeparatorForInput(input);
		if (string.IsNullOrEmpty(separator) || input.Parts.Count == 0) return "";

		var parts = input.Parts.Select(p => _MaterializedAsText(p)).Where(s => !string.IsNullOrEmpty(s));
		return string.Join(separator, parts);
	}

	private async Task<string> _MaterializedAsRichtextAsync(MaterializedInput input) {
		_EnsureReadiness();
		if (input is MaterializedSimpleInput simple) {
			Texture2D icon = null;
			foreach (var renderer in _iconRenderers) {
				if (renderer.Supports(simple.Input, formatting_options)) {
					icon = await _iconMaker.MakeIcon(simple.Input, renderer, _iconSize, formatting_options);
					break;
				}
			}

			if (icon == null) {
				GD.PushWarning($"No renderer found for input {simple.Input}");
				return "";
			}

			return $"[img]{icon.ResourcePath}[/img]";
		}

		var separator = _SeparatorForInput(input);
		if (string.IsNullOrEmpty(separator) || input.Parts.Count == 0) return "";

		var parts = new List<string>();
		foreach (var part in input.Parts) {
			var res = await _MaterializedAsRichtextAsync(part);
			if (!string.IsNullOrEmpty(res)) parts.Add(res);
		}

		return string.Join(separator, parts);
	}

	private string _SeparatorForInput(MaterializedInput input) {
		return input switch {
			MaterializedMixedInput => MixedInputSeparator,
			MaterializedComboInput => ComboInputSeparator,
			MaterializedChordedInput => ChordedInputSeparator,
			_ => throw new Exception("Unknown materialized input type")
		};
	}

	private MaterializedInput _MaterializeActionInput(GUIDEAction action) {
		var result = new MaterializedMixedInput();
		if (action == null) {
			GD.PushWarning("Trying to get inputs for a null action.");
			return result;
		}

		var mapping = _actionResolver.Call(action).As<GUIDEActionMapping>();
		if (mapping == null) return result;

		foreach (var inputMapping in mapping.InputMappings) {
			var chordedActions = new List<MaterializedInput>();
			var combos = new List<MaterializedInput>();

			foreach (var trigger in inputMapping.Triggers) {
				if (trigger is GUIDETriggerCombo comboTrigger) {
					var combo = new MaterializedComboInput();
					foreach (var step in comboTrigger.Steps) {
						combo.Parts.Add(_MaterializeActionInput(step.Action));
					}
					combos.Add(combo);
				}

				if (trigger is GUIDETriggerChordedAction chordedTrigger) {
					chordedActions.Add(_MaterializeActionInput(chordedTrigger.Action));
				}
			}

			if (chordedActions.Count > 0) {
				var chord = new MaterializedChordedInput();
				foreach (var chordedAction in chordedActions) chord.Parts.Add(chordedAction);
				foreach (var combo in combos) chord.Parts.Add(combo);
				if (combos.Count == 0 && inputMapping.Input != null) {
					chord.Parts.Add(_MaterializeInput(FormattingContext.ForAction(inputMapping.Input, inputMapping, action)));
				}
				result.Parts.Add(chord);
			}
			else {
				foreach (var combo in combos) result.Parts.Add(combo);
				if (combos.Count == 0 && inputMapping.Input != null) {
					result.Parts.Add(_MaterializeInput(FormattingContext.ForAction(inputMapping.Input, inputMapping, action)));
				}
			}
		}
		return result;
	}

	private MaterializedInput _MaterializeInput(FormattingContext context, bool materializeActions = true) {
		if (context.Input == null) {
			GD.PushWarning("Trying to materialize a null input.");
			return new MaterializedMixedInput();
		}

		if (!formatting_options.input_filter(context)) {
			return new MaterializedMixedInput();
		}

		if (context.Input is GUIDEInputAction actionInput) {
			if (materializeActions) return _MaterializeActionInput(actionInput.Action);
			return new MaterializedSimpleInput(context.Input);
		}

		if (context.Input is GUIDEInputKey keyInput) {
			var chord = new MaterializedChordedInput();
			if (keyInput.Control) chord.Parts.Add(new MaterializedSimpleInput(new GUIDEInputKey { Key = Key.Ctrl }));
			if (keyInput.Alt) chord.Parts.Add(new MaterializedSimpleInput(new GUIDEInputKey { Key = Key.Alt }));
			if (keyInput.Shift) chord.Parts.Add(new MaterializedSimpleInput(new GUIDEInputKey { Key = Key.Shift }));
			if (keyInput.Meta) chord.Parts.Add(new MaterializedSimpleInput(new GUIDEInputKey { Key = Key.Meta }));

			if (chord.Parts.Count == 0) return new MaterializedSimpleInput(context.Input);

			chord.Parts.Add(new MaterializedSimpleInput(context.Input));
			return chord;
		}

		return new MaterializedSimpleInput(context.Input);
	}

	public abstract class MaterializedInput {
		public List<MaterializedInput> Parts { get; } = new();
	}

	public class MaterializedSimpleInput : MaterializedInput {
		public GUIDEInput Input { get; }
		public MaterializedSimpleInput(GUIDEInput input) => Input = input;
	}

	public class MaterializedMixedInput : MaterializedInput { }
	public class MaterializedChordedInput : MaterializedInput { }
	public class MaterializedComboInput : MaterializedInput { }

	public partial class FormattingContext : RefCounted {
		public GUIDEInput Input { get; set; }
		public GUIDEInputMapping InputMapping { get; set; }
		public GUIDEAction Action { get; set; }

		public static FormattingContext ForInput(GUIDEInput input) => new() { Input = input };
		public static FormattingContext ForAction(GUIDEInput input, GUIDEInputMapping inputMapping, GUIDEAction action) =>
			new() { Input = input, InputMapping = inputMapping, Action = action };
	}
}
