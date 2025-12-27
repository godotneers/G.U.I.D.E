#ifndef GUIDE_VIRTUAL_JOY_TEXTURE_RENDERERS_H
#define GUIDE_VIRTUAL_JOY_TEXTURE_RENDERERS_H

#include "guide_virtual_joy_renderers.h"

using namespace godot;

class GUIDEVirtualButtonTextureRenderer : public GUIDEVirtualButtonRenderer {
    GDCLASS(GUIDEVirtualButtonTextureRenderer, GUIDEVirtualButtonRenderer)

public:
    GUIDEVirtualButtonTextureRenderer();
    virtual ~GUIDEVirtualButtonTextureRenderer() {}

    void _ready() override;
    virtual void _on_configuration_changed() override { _rebuild(); }
    virtual void _update(bool is_actuated) override;

    void _rebuild();
    Sprite2D* _ensure_sprite(Sprite2D *sprite, const Ref<Texture2D> &texture);

    Ref<Texture2D> get_idle_texture() const { return idle_texture; }
    void set_idle_texture(const Ref<Texture2D> &p_val) { idle_texture = p_val; _rebuild(); }

    Ref<Texture2D> get_actuated_texture() const { return actuated_texture; }
    void set_actuated_texture(const Ref<Texture2D> &p_val) { actuated_texture = p_val; _rebuild(); }

protected:
    static void _bind_methods();

private:
    Ref<Texture2D> idle_texture;
    Ref<Texture2D> actuated_texture;
    Sprite2D *_idle_sprite = nullptr;
    Sprite2D *_actuated_sprite = nullptr;
};

class GUIDEVirtualStickTextureRenderer : public GUIDEVirtualStickRenderer {
    GDCLASS(GUIDEVirtualStickTextureRenderer, GUIDEVirtualStickRenderer)

public:
    enum ShowMode { ALWAYS = 0, ON_ACTUATE = 1 };

    GUIDEVirtualStickTextureRenderer();
    virtual ~GUIDEVirtualStickTextureRenderer() {}

    void _ready() override;
    virtual void _on_configuration_changed() override { _rebuild(); }
    virtual void _update(Vector2 joy_position, Vector2 joy_offset, bool is_actuated) override;

    void _rebuild();
    Sprite2D* _ensure_sprite(Sprite2D *sprite, const Ref<Texture2D> &texture);

    int get_show_stick() const { return (int)show_stick; }
    void set_show_stick(int p_val) { show_stick = (ShowMode)p_val; _rebuild(); }

    Ref<Texture2D> get_outline_texture() const { return outline_texture; }
    void set_outline_texture(const Ref<Texture2D> &p_val) { outline_texture = p_val; _rebuild(); }

    Ref<Texture2D> get_stick_texture() const { return stick_texture; }
    void set_stick_texture(const Ref<Texture2D> &p_val) { stick_texture = p_val; _rebuild(); }

    Ref<Texture2D> get_hidden_texture() const { return hidden_texture; }
    void set_hidden_texture(const Ref<Texture2D> &p_val) { hidden_texture = p_val; _rebuild(); }

protected:
    static void _bind_methods();

private:
    ShowMode show_stick = ON_ACTUATE;
    Ref<Texture2D> outline_texture;
    Ref<Texture2D> stick_texture;
    Ref<Texture2D> hidden_texture;

    Sprite2D *_outline_sprite = nullptr;
    Sprite2D *_stick_sprite = nullptr;
    Sprite2D *_hidden_sprite = nullptr;
};

VARIANT_ENUM_CAST(GUIDEVirtualStickTextureRenderer::ShowMode);

#endif // GUIDE_VIRTUAL_JOY_TEXTURE_RENDERERS_H