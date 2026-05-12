using Godot;
using System;

namespace Guide;

[Tool]
public partial class ResourceSlot : LineEdit {
    [Signal] public delegate void ChangedEventHandler();

    public override void _Ready() {
        Editable = false;
        ContextMenuEnabled = false;
        VirtualKeyboardEnabled = false;
        ShortcutKeysEnabled = false;
        SelectingEnabled = false;
        DragAndDropSelectionEnabled = false;
        MiddleMousePasteEnabled = false;
    }

    protected Resource _value = null;
    public Resource Value {
        get => _value;
        set {
            if (_value == value) return;
            if (IsInstanceValid(_value)) _value.Changed -= _UpdateFromValue;
            _value = value;
            if (IsInstanceValid(_value)) _value.Changed += _UpdateFromValue;
            _UpdateFromValue();
            EmitSignal(SignalName.Changed);
        }
    }

    private void _UpdateFromValue() {
        if (!IsInstanceValid(_value)) {
            Text = "<none>";
            TooltipText = "";
            RemoveThemeColorOverride("font_uneditable_color");
        }
        else {
            var nval = (IEditorDescription)_value;
            Text = nval._EditorName();
            TooltipText = _value.ResourcePath;
            if (!EditorUtils.IsInline(_value)) {
                if (Engine.IsEditorHint()) AddThemeColorOverride("font_uneditable_color", GetThemeColor("accent_color", "Editor"));
                QueueRedraw();
            }
            else {
                RemoveThemeColorOverride("font_uneditable_color");
            }
        }
    }

    protected virtual void _DoDropData(Resource data) => Value = data;

    protected virtual bool _AcceptsDropData(Resource data) => false;

    public override bool _CanDropData(Vector2 atPosition, Variant data) {
        if (data.As<Resource>() is Resource res) return _AcceptsDropData(res);
        if (data.VariantType != Variant.Type.Dictionary) return false;
        var dict = data.AsGodotDictionary();
        if (dict.ContainsKey("files")) {
            foreach (var file in dict["files"].AsStringArray()) {
                if (_AcceptsDropData(ResourceLoader.Load(file))) return true;
            }
        }
        return false;
    }

    public override void _DropData(Vector2 atPosition, Variant data) {
        if (data.As<Resource>() is Resource res) { _DoDropData(res); return; }
        var dict = data.AsGodotDictionary();
        foreach (var file in dict["files"].AsStringArray()) {
            var item = ResourceLoader.Load(file);
            if (_AcceptsDropData(item)) { _DoDropData(item); break; }
        }
    }

    public override Variant _GetDragData(Vector2 atPosition) {
        if (IsInstanceValid(_value)) {
            var preview = new TextureRect();
            if (Engine.IsEditorHint()) preview.Texture = GetThemeIcon("File", "EditorIcons");
            SetDragPreview(preview);
            if (!EditorUtils.IsInline(_value)) return new Godot.Collections.Dictionary { { "files", new string[] { _value.ResourcePath } } };
            return _value.Duplicate();
        }
        return default;
    }

    public override void _GuiInput(InputEvent @event) {
        if (@event is InputEventMouseButton mouseButton && mouseButton.Pressed && mouseButton.ButtonIndex == MouseButton.Left) {
            if (IsInstanceValid(_value)) EditorInterface.Singleton.EditResource(_value);
        }
    }
}
