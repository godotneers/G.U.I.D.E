using Godot;

namespace Guide;

[Tool]
public partial class ArrayEdit : MarginContainer {
    [Export] public PackedScene ItemScene { get; set; }

    private string _title = "";
    [Export]
    public string Title {
        get => _title;
        set { _title = value; _Refresh(); }
    }

    private string _addTooltip;
    [Export]
    public string AddTooltip {
        get => _addTooltip;
        set { _addTooltip = value; _Refresh(); }
    }

    private string _clearTooltip;
    [Export]
    public string ClearTooltip {
        get => _clearTooltip;
        set { _clearTooltip = value; _Refresh(); }
    }

    private int _itemSeparation = 8;
    [Export]
    public int ItemSeparation {
        get => _itemSeparation;
        set { _itemSeparation = value; _Refresh(); }
    }

    private bool _collapsed = false;
    [Export]
    public bool Collapsed {
        get => _collapsed;
        set { _collapsed = value; _Refresh(); }
    }

    [Signal] public delegate void AddRequestedEventHandler();
    [Signal] public delegate void DeleteRequestedEventHandler(int index);
    [Signal] public delegate void MoveRequestedEventHandler(int from, int to);
    [Signal] public delegate void InsertRequestedEventHandler(int index);
    [Signal] public delegate void DuplicateRequestedEventHandler(int index);
    [Signal] public delegate void ClearRequestedEventHandler();
    [Signal] public delegate void CollapseStateChangedEventHandler(bool collapsed);

    private Button _addButton;
    private Button _clearButton;
    private Container _contents;
    private Label _titleLabel;
    private Button _collapseButton;
    private Button _expandButton;
    private Label _countLabel;

    public override void _Ready() {
        _addButton = GetNode<Button>("%AddButton");
        _clearButton = GetNode<Button>("%ClearButton");
        _contents = GetNode<Container>("%Contents");
        _titleLabel = GetNode<Label>("%TitleLabel");
        _collapseButton = GetNode<Button>("%CollapseButton");
        _expandButton = GetNode<Button>("%ExpandButton");
        _countLabel = GetNode<Label>("%CountLabel");

        if (Engine.IsEditorHint()) {
            _addButton.Icon = GetThemeIcon("Add", "EditorIcons");
            _clearButton.Icon = GetThemeIcon("Clear", "EditorIcons");
            _collapseButton.Icon = GetThemeIcon("Collapse", "EditorIcons");
            _expandButton.Icon = GetThemeIcon("Forward", "EditorIcons");
        }

        _addButton.Pressed += () => EmitSignal(SignalName.AddRequested);
        _clearButton.Pressed += () => EmitSignal(SignalName.ClearRequested);
        _collapseButton.Pressed += _OnCollapsePressed;
        _expandButton.Pressed += _OnExpandPressed;

        _Refresh();
    }

    private void _Refresh() {
        if (_addButton != null) _addButton.TooltipText = AddTooltip;
        if (_clearButton != null && _contents != null) {
            _clearButton.TooltipText = ClearTooltip;
            _clearButton.Visible = _contents.GetChildCount() > 0;
        }

        if (_contents != null) {
            _contents.AddThemeConstantOverride("separation", ItemSeparation);
            _contents.Visible = !Collapsed;
        }

        if (_collapseButton != null) _collapseButton.Visible = !Collapsed;
        if (_expandButton != null) _expandButton.Visible = Collapsed;
        if (_titleLabel != null) _titleLabel.Text = Title;
        if (_countLabel != null && _contents != null) _countLabel.Text = $"({_contents.GetChildCount()})";
    }

    public void Clear() {
        EditorUtils.Clear(_contents);
        _Refresh();
    }

    public void AddItem(Control newItem) {
        var itemWrapper = ItemScene.Instantiate<ArrayEditItem>();
        _contents.AddChild(itemWrapper);
        itemWrapper.Initialize(newItem);
        itemWrapper.MoveRequested += (from, to) => EmitSignal(SignalName.MoveRequested, from, to);
        itemWrapper.DeleteRequested += (idx) => EmitSignal(SignalName.DeleteRequested, idx);
        itemWrapper.DuplicateRequested += (idx) => EmitSignal(SignalName.DuplicateRequested, idx);
        _Refresh();
    }

    private void _OnCollapsePressed() {
        Collapsed = true;
        EmitSignal(SignalName.CollapseStateChanged, true);
    }

    private void _OnExpandPressed() {
        Collapsed = false;
        EmitSignal(SignalName.CollapseStateChanged, false);
    }
}
