#ifndef GUIDE_VIRTUAL_STICK_TEXTURE_RENDERER_H
#define GUIDE_VIRTUAL_STICK_TEXTURE_RENDERER_H

#include "../guide_virtual_stick_renderer.h"
#include <godot_cpp/classes/sprite2d.hpp>
#include <godot_cpp/classes/texture2d.hpp>
#include <godot_cpp/core/math.hpp>

using namespace godot;

class GUIDEVirtualStickTextureRenderer : public GUIDEVirtualStickRenderer {
    GDCLASS(GUIDEVirtualStickTextureRenderer, GUIDEVirtualStickRenderer)

public:
    enum ShowMode { ALWAYS = 0, ON_ACTUATE = 1 };

    GUIDEVirtualStickTextureRenderer() {}
    virtual ~GUIDEVirtualStickTextureRenderer() {}

    void _ready() override {
        _rebuild();
    }

    virtual void _on_configuration_changed() override { _rebuild(); }
    
    virtual void _update(Vector2 joy_position, Vector2 joy_offset, bool is_actuated) override {
        if (_stick_sprite) _stick_sprite->set_position(joy_position);
        bool should_be_visible = is_actuated || show_stick == ALWAYS;
        if (_stick_sprite) _stick_sprite->set_visible(should_be_visible);
        if (_outline_sprite) _outline_sprite->set_visible(should_be_visible);
        if (_hidden_sprite) _hidden_sprite->set_visible(!should_be_visible);
    }

    void _rebuild() {
        _outline_sprite = _ensure_sprite(_outline_sprite, outline_texture);
        _stick_sprite = _ensure_sprite(_stick_sprite, stick_texture);
        _hidden_sprite = _ensure_sprite(_hidden_sprite, hidden_texture);
        _update(Vector2(0, 0), Vector2(0, 0), is_stick_actuated());
    }

    Sprite2D* _ensure_sprite(Sprite2D *sprite, const Ref<Texture2D> &texture) {
        if (!sprite) {
            sprite = memnew(Sprite2D);
            sprite->set_centered(true);
            add_child(sprite);
        }
        sprite->set_texture(texture);
        double diameter = get_stick_radius() * 2.0;
        if (diameter > 0.0 && texture.is_valid()) {
            Vector2 tex_size = texture->get_size();
            if (tex_size.x > 0.0 && tex_size.y > 0.0) {
                double factor = diameter / Math::min(tex_size.x, tex_size.y);
                sprite->set_scale(Vector2(factor, factor));
                sprite->set_position(Vector2(0, 0));
            }
        }
        return sprite;
    }

    int get_show_stick() const { return (int)show_stick; }
    void set_show_stick(int p_val) { show_stick = (ShowMode)p_val; _rebuild(); }

    Ref<Texture2D> get_outline_texture() const { return outline_texture; }
    void set_outline_texture(const Ref<Texture2D> &p_val) { outline_texture = p_val; _rebuild(); }

    Ref<Texture2D> get_stick_texture() const { return stick_texture; }
    void set_stick_texture(const Ref<Texture2D> &p_val) { stick_texture = p_val; _rebuild(); }

    Ref<Texture2D> get_hidden_texture() const { return hidden_texture; }
    void set_hidden_texture(const Ref<Texture2D> &p_val) { hidden_texture = p_val; _rebuild(); }

protected:
    static void _bind_methods() {
        BIND_ENUM_CONSTANT(ALWAYS);
        BIND_ENUM_CONSTANT(ON_ACTUATE);

        ClassDB::bind_method(D_METHOD("get_show_stick"), &GUIDEVirtualStickTextureRenderer::get_show_stick);
        ClassDB::bind_method(D_METHOD("set_show_stick", "val"), &GUIDEVirtualStickTextureRenderer::set_show_stick);
        ADD_PROPERTY(PropertyInfo(Variant::INT, "show_stick", PROPERTY_HINT_ENUM, "ALWAYS,ON_ACTUATE"), "set_show_stick", "get_show_stick");

        ClassDB::bind_method(D_METHOD("get_outline_texture"), &GUIDEVirtualStickTextureRenderer::get_outline_texture);
        ClassDB::bind_method(D_METHOD("set_outline_texture", "val"), &GUIDEVirtualStickTextureRenderer::set_outline_texture);
        ADD_PROPERTY(PropertyInfo(Variant::OBJECT, "outline_texture", PROPERTY_HINT_RESOURCE_TYPE, "Texture2D"), "set_outline_texture", "get_outline_texture");

        ClassDB::bind_method(D_METHOD("get_stick_texture"), &GUIDEVirtualStickTextureRenderer::get_stick_texture);
        ClassDB::bind_method(D_METHOD("set_stick_texture", "val"), &GUIDEVirtualStickTextureRenderer::set_stick_texture);
        ADD_PROPERTY(PropertyInfo(Variant::OBJECT, "stick_texture", PROPERTY_HINT_RESOURCE_TYPE, "Texture2D"), "set_stick_texture", "get_stick_texture");

        ClassDB::bind_method(D_METHOD("get_hidden_texture"), &GUIDEVirtualStickTextureRenderer::get_hidden_texture);
        ClassDB::bind_method(D_METHOD("set_hidden_texture", "val"), &GUIDEVirtualStickTextureRenderer::set_hidden_texture);
        ADD_PROPERTY(PropertyInfo(Variant::OBJECT, "hidden_texture", PROPERTY_HINT_RESOURCE_TYPE, "Texture2D"), "set_hidden_texture", "get_hidden_texture");
    }

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

#endif // GUIDE_VIRTUAL_STICK_TEXTURE_RENDERER_H
