#if TOOLS
using System;
using Godot;

namespace Guide;

[Tool]
public partial class GUIDEPlugin : EditorPlugin {
	private static readonly PackedScene MainPanelScene = GD.Load<PackedScene>("res://addons/GuideCS/Editor/MappingContextEditor/MappingContextEditor.tscn");
	private MappingContextEditor _mainPanel;

	public override void _EnablePlugin() {
		AddAutoloadSingleton("GUIDE", "res://addons/GuideCS/GUIDE.cs");
	}

	public override void _EnterTree() {
		_mainPanel = MainPanelScene.Instantiate<MappingContextEditor>();
		_mainPanel.Initialize(this);
		EditorInterface.Singleton.GetEditorMainScreen().AddChild(_mainPanel);
		GUIDEProjectSettings.Initialize();
		_MakeVisible(false);
	}

	public override void _ExitTree() {
		if (IsInstanceValid(_mainPanel)) {
			_mainPanel.QueueFree();
		}
		GUIDEInputFormatter.Cleanup();
	}

	public override void _DisablePlugin() {
		RemoveAutoloadSingleton("GUIDE");
	}

	public override void _Edit(GodotObject @object) {
		if (@object is GUIDEMappingContext context) {
			_mainPanel.Edit(context);
		}
	}

	public override string _GetPluginName() => "G.U.I.D.E";

	public override Texture2D _GetPluginIcon() => GD.Load<Texture2D>("res://addons/GuideCS/Editor/LogoEditorSmall.svg");

	public override bool _HasMainScreen() => true;

	public override bool _Handles(GodotObject @object) => @object is GUIDEMappingContext;

	public override void _MakeVisible(bool visible) {
		if (IsInstanceValid(_mainPanel)) {
			_mainPanel.Visible = visible;
		}
	}
}
#endif
