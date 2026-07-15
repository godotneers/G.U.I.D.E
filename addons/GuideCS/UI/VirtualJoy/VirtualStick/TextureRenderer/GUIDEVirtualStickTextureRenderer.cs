using System;
using Godot;

namespace Guide;

[Tool]
public partial class GUIDEVirtualStickTextureRenderer : GUIDEVirtualStickRenderer {
	public enum ShowMode {
		Always = 0,
		OnActuate = 1
	}

	private ShowMode _showStick = ShowMode.OnActuate;
	[Export]
	public ShowMode ShowStick {
		get => _showStick;
		set { _showStick = value; _Rebuild(); }
	}

	private Texture2D _outlineTexture = GD.Load<Texture2D>("res://addons/GuideCS/UI/VirtualJoy/VirtualStick/TextureRenderer/StickOutline.svg");
	[Export]
	public Texture2D OutlineTexture {
		get => _outlineTexture;
		set { _outlineTexture = value; _Rebuild(); }
	}

	private Texture2D _stickTexture = GD.Load<Texture2D>("res://addons/GuideCS/UI/VirtualJoy/VirtualStick/TextureRenderer/Stick.svg");
	[Export]
	public Texture2D StickTexture {
		get => _stickTexture;
		set { _stickTexture = value; _Rebuild(); }
	}

	private Texture2D _hiddenTexture = GD.Load<Texture2D>("res://addons/GuideCS/UI/VirtualJoy/VirtualStick/TextureRenderer/StickHidden.svg");
	[Export]
	public Texture2D HiddenTexture {
		get => _hiddenTexture;
		set { _hiddenTexture = value; _Rebuild(); }
	}

	private Sprite2D _outlineSprite;
	private Sprite2D _stickSprite;
	private Sprite2D _hiddenSprite;

	public override void _Ready() {
		_Rebuild();
	}

	protected override void _OnConfigurationChanged() {
		_Rebuild();
	}

	private void _Rebuild() {
		_outlineSprite = _EnsureSprite(_outlineSprite, OutlineTexture);
		_stickSprite = _EnsureSprite(_stickSprite, StickTexture);
		_hiddenSprite = _EnsureSprite(_hiddenSprite, HiddenTexture);
		_Update(Vector2.Zero, Vector2.Zero, IsStickActuated);
	}

	private Sprite2D _EnsureSprite(Sprite2D sprite, Texture2D texture) {
		if (!IsInstanceValid(sprite)) {
			sprite = new Sprite2D();
			sprite.Centered = true;
			AddChild(sprite);
		}

		sprite.Texture = texture;

		float diameter = StickRadius * 2.0f;
		if (diameter > 0.0f) {
			var tex = sprite.Texture;
			if (IsInstanceValid(tex)) {
				var texSize = tex.GetSize();
				if (texSize.X > 0.0f && texSize.Y > 0.0f) {
					float shortest = Math.Min(texSize.X, texSize.Y);
					float factor = diameter / shortest;
					sprite.Scale = new Vector2(factor, factor);
					sprite.Position = Vector2.Zero;
				}
			}
		}
		return sprite;
	}

	protected override void _Update(Vector2 joyPosition, Vector2 joyOffset, bool isActuated) {
		if (IsInstanceValid(_stickSprite)) _stickSprite.Position = joyPosition;

		bool shouldBeVisible = isActuated || ShowStick == ShowMode.Always;

		if (IsInstanceValid(_stickSprite)) _stickSprite.Visible = shouldBeVisible;
		if (IsInstanceValid(_outlineSprite)) _outlineSprite.Visible = shouldBeVisible;
		if (IsInstanceValid(_hiddenSprite)) _hiddenSprite.Visible = !shouldBeVisible;
	}
}
