using System;
using Godot;

namespace Guide;

[Tool]
public partial class ArrayEditItem : Container {
	[Signal] public delegate void MoveRequestedEventHandler(int from, int to);
	[Signal] public delegate void DeleteRequestedEventHandler(int index);
	[Signal] public delegate void DuplicateRequestedEventHandler(int index);

	private Dragger _dragger;
	private Container _content;
	private ColorRect _beforeIndicator;
	private ColorRect _afterIndicator;
	private PopupMenu _popupMenu;

	private const int IdDelete = 2;
	private const int IdDuplicate = 3;

	public override void _Ready() {
		_dragger = GetNode<Dragger>("%Dragger");
		_content = GetNode<Container>("%Content");
		_beforeIndicator = GetNode<ColorRect>("%BeforeIndicator");
		_afterIndicator = GetNode<ColorRect>("%AfterIndicator");
		_popupMenu = GetNode<PopupMenu>("%PopupMenu");

		if (Engine.IsEditorHint()) {
			_dragger.Icon = GetThemeIcon("GuiSpinboxUpdown", "EditorIcons");
			_beforeIndicator.Color = GetThemeColor("box_selection_stroke_color", "Editor");
			_afterIndicator.Color = GetThemeColor("box_selection_stroke_color", "Editor");
		}

		_beforeIndicator.Visible = false;
		_afterIndicator.Visible = false;
		_dragger._ParentArray = GetParent();
		_dragger._Index = GetIndex();
		_dragger.Pressed += _ShowPopupMenu;

		_popupMenu.Clear();
		if (Engine.IsEditorHint()) {
			_popupMenu.AddIconItem(GetThemeIcon("Duplicate", "EditorIcons"), "Duplicate", IdDuplicate);
			_popupMenu.AddIconItem(GetThemeIcon("Remove", "EditorIcons"), "Delete", IdDelete);
		}
		_popupMenu.IdPressed += _OnPopupMenuIdPressed;
	}

	public void Initialize(Control content) {
		EditorUtils.Clear(_content);
		_content.AddChild(content);
	}

	public override bool _CanDropData(Vector2 atPosition, Variant data) {
		if (data.VariantType == Variant.Type.Dictionary) {
			var dict = data.AsGodotDictionary();
			if (dict.ContainsKey("parent_array") && dict["parent_array"].As<GodotObject>() == GetParent() &&
				dict["index"].AsInt32() != GetIndex()) {
				float height = Size.Y;
				bool isBefore = !_IsLastChild() || (atPosition.Y < height / 2.0f);
				if (isBefore && dict["index"].AsInt32() == GetIndex() - 1) return false;

				_beforeIndicator.Visible = isBefore;
				_afterIndicator.Visible = !isBefore;
				return true;
			}
		}
		return false;
	}

	public override void _DropData(Vector2 atPosition, Variant data) {
		float height = Size.Y;
		bool isBefore = !_IsLastChild() || (atPosition.Y < height / 2.0f);
		int to = isBefore ? GetIndex() : GetIndex() + 1;
		var dict = data.AsGodotDictionary();
		EmitSignal(SignalName.MoveRequested, dict["index"].AsInt32(), to);
		_beforeIndicator.Visible = false;
		_afterIndicator.Visible = false;
	}

	private bool _IsLastChild() => GetIndex() == GetParent().GetChildCount() - 1;

	private void _OnMouseExited() {
		_beforeIndicator.Visible = false;
		_afterIndicator.Visible = false;
	}

	private void _ShowPopupMenu() {
		_popupMenu.Popup(new Rect2I((Vector2I)(GetScreenPosition() + GetLocalMousePosition()), Vector2I.Zero));
	}

	private void _OnPopupMenuIdPressed(long id) {
		switch ((int)id) {
			case IdDelete:
				EmitSignal(SignalName.DeleteRequested, GetIndex());
				break;
			case IdDuplicate:
				EmitSignal(SignalName.DuplicateRequested, GetIndex());
				break;
		}
	}
}
