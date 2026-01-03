#ifndef GUIDE_VIRTUAL_BUTTON_TEXTURE_RENDERER_H
#define GUIDE_VIRTUAL_BUTTON_TEXTURE_RENDERER_H

#include "../guide_virtual_button_renderer.h"
#include <godot_cpp/classes/sprite2d.hpp>
#include <godot_cpp/classes/texture2d.hpp>
#include <godot_cpp/core/math.hpp>

using namespace godot;

class GUIDEVirtualButtonTextureRenderer : public GUIDEVirtualButtonRenderer {
    GDCLASS(GUIDEVirtualButtonTextureRenderer, GUIDEVirtualButtonRenderer)

public:
    GUIDEVirtualButtonTextureRenderer() {}
    virtual ~GUIDEVirtualButtonTextureRenderer() {}

    void _ready() override {
        _rebuild();
    }

    virtual void _on_configuration_changed() override { _rebuild(); }
    
    virtual void _update(bool is_actuated) override {
        if (_idle_sprite) _idle_sprite->set_visible(!is_actuated);
        if (_actuated_sprite) _actuated_sprite->set_visible(is_actuated);
    }

    void _rebuild() {
        _idle_sprite = _ensure_sprite(_idle_sprite, idle_texture);
        _actuated_sprite = _ensure_sprite(_actuated_sprite, actuated_texture);
        _update(is_button_actuated());
    }

    Sprite2D* _ensure_sprite(Sprite2D *sprite, const Ref<Texture2D> &texture) {
        if (!sprite) {
            sprite = memnew(Sprite2D);
            sprite->set_centered(true);
            add_child(sprite);
        }
        sprite->set_texture(texture);
        double diameter = get_button_radius() * 2.0;
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

    Ref<Texture2D> get_idle_texture() const { return idle_texture; }
    void set_idle_texture(const Ref<Texture2D> &p_val) { idle_texture = p_val; _rebuild(); }

    Ref<Texture2D> get_actuated_texture() const { return actuated_texture; }
    void set_actuated_texture(const Ref<Texture2D> &p_val) { actuated_texture = p_val; _rebuild(); }

protected:
    static void _bind_methods() {
        ClassDB::bind_method(D_METHOD("get_idle_texture"), &GUIDEVirtualButtonTextureRenderer::get_idle_texture);
        ClassDB::bind_method(D_METHOD("set_idle_texture", "val"), &GUIDEVirtualButtonTextureRenderer::set_idle_texture);
        ADD_PROPERTY(PropertyInfo(Variant::OBJECT, "idle_texture", PROPERTY_HINT_RESOURCE_TYPE, "Texture2D"), "set_idle_texture", "get_idle_texture");

        ClassDB::bind_method(D_METHOD("get_actuated_texture"), &GUIDEVirtualButtonTextureRenderer::get_actuated_texture);
        ClassDB::bind_method(D_METHOD("set_actuated_texture", "val"), &GUIDEVirtualButtonTextureRenderer::set_actuated_texture);
        ADD_PROPERTY(PropertyInfo(Variant::OBJECT, "actuated_texture", PROPERTY_HINT_RESOURCE_TYPE, "Texture2D"), "set_actuated_texture", "get_actuated_texture");
    }

private:
    Ref<Texture2D> idle_texture;
    Ref<Texture2D> actuated_texture;
    Sprite2D *_idle_sprite = nullptr;
    Sprite2D *_actuated_sprite = nullptr;
};

#endif // GUIDE_VIRTUAL_BUTTON_TEXTURE_RENDERER_H
