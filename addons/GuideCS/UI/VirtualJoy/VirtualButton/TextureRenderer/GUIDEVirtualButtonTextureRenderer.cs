using System;
using Godot;

namespace Guide;

[Tool]
public partial class GUIDEVirtualButtonTextureRenderer : GUIDEVirtualButtonRenderer {
	private Texture2D _idleTexture = GD.Load<Texture2D>("res://addons/GuideCS/UI/VirtualJoy/VirtualButton/TextureRenderer/Idle.svg");
	[Export]
	public Texture2D IdleTexture {
		get => _idleTexture;
		set { _idleTexture = value; _Rebuild(); }
	}

	private Texture2D _actuatedTexture = GD.Load<Texture2D>("res://addons/GuideCS/UI/VirtualJoy/VirtualButton/TextureRenderer/Actuated.svg");
	[Export]
	public Texture2D ActuatedTexture {
		get => _actuatedTexture;
		set { _actuatedTexture = value; _Rebuild(); }
	}

	private Sprite2D _idleSprite;
	private Sprite2D _actuatedSprite;

	public override void _Ready() {
		_Rebuild();
	}

	protected override void _OnConfigurationChanged() {
		_Rebuild();
	}

	private void _Rebuild() {
		_idleSprite = _EnsureSprite(_idleSprite, IdleTexture);
		_actuatedSprite = _EnsureSprite(_actuatedSprite, ActuatedTexture);
		_Update(IsButtonActuated);
	}

	protected override void _Update(bool isActuated) {
		if (IsInstanceValid(_idleSprite)) _idleSprite.Visible = !isActuated;
		if (IsInstanceValid(_actuatedSprite)) _actuatedSprite.Visible = isActuated;
	}

	private Sprite2D _EnsureSprite(Sprite2D sprite, Texture2D texture) {
		if (!IsInstanceValid(sprite)) {
			sprite = new Sprite2D();
			sprite.Centered = true;
			AddChild(sprite);
		}

		sprite.Texture = texture;

		float diameter = ButtonRadius * 2.0f;
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
}
