#include "guide_virtual_joy_texture_renderers.h"
#include <godot_cpp/core/math.hpp>
#include <algorithm>

using namespace godot;

// --- Button Texture Renderer ---

void GUIDEVirtualButtonTextureRenderer::_bind_methods() {
    ClassDB::bind_method(D_METHOD("get_idle_texture"), &GUIDEVirtualButtonTextureRenderer::get_idle_texture);
    ClassDB::bind_method(D_METHOD("set_idle_texture", "val"), &GUIDEVirtualButtonTextureRenderer::set_idle_texture);
    ADD_PROPERTY(PropertyInfo(Variant::OBJECT, "idle_texture", PROPERTY_HINT_RESOURCE_TYPE, "Texture2D"), "set_idle_texture", "get_idle_texture");

    ClassDB::bind_method(D_METHOD("get_actuated_texture"), &GUIDEVirtualButtonTextureRenderer::get_actuated_texture);
    ClassDB::bind_method(D_METHOD("set_actuated_texture", "val"), &GUIDEVirtualButtonTextureRenderer::set_actuated_texture);
    ADD_PROPERTY(PropertyInfo(Variant::OBJECT, "actuated_texture", PROPERTY_HINT_RESOURCE_TYPE, "Texture2D"), "set_actuated_texture", "get_actuated_texture");
}

GUIDEVirtualButtonTextureRenderer::GUIDEVirtualButtonTextureRenderer() {}

void GUIDEVirtualButtonTextureRenderer::_ready() {
    _rebuild();
}

void GUIDEVirtualButtonTextureRenderer::_rebuild() {
    _idle_sprite = _ensure_sprite(_idle_sprite, idle_texture);
    _actuated_sprite = _ensure_sprite(_actuated_sprite, actuated_texture);
    _update(is_button_actuated());
}

void GUIDEVirtualButtonTextureRenderer::_update(bool is_actuated) {
    if (_idle_sprite) _idle_sprite->set_visible(!is_actuated);
    if (_actuated_sprite) _actuated_sprite->set_visible(is_actuated);
}

Sprite2D* GUIDEVirtualButtonTextureRenderer::_ensure_sprite(Sprite2D *sprite, const Ref<Texture2D> &texture) {
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

// --- Stick Texture Renderer ---

void GUIDEVirtualStickTextureRenderer::_bind_methods() {
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

GUIDEVirtualStickTextureRenderer::GUIDEVirtualStickTextureRenderer() {}

void GUIDEVirtualStickTextureRenderer::_ready() {
    _rebuild();
}

void GUIDEVirtualStickTextureRenderer::_rebuild() {
    _outline_sprite = _ensure_sprite(_outline_sprite, outline_texture);
    _stick_sprite = _ensure_sprite(_stick_sprite, stick_texture);
    _hidden_sprite = _ensure_sprite(_hidden_sprite, hidden_texture);
    _update(Vector2(0, 0), Vector2(0, 0), is_stick_actuated());
}

void GUIDEVirtualStickTextureRenderer::_update(Vector2 joy_position, Vector2 joy_offset, bool is_actuated) {
    if (_stick_sprite) _stick_sprite->set_position(joy_position);
    bool should_be_visible = is_actuated || show_stick == ALWAYS;
    if (_stick_sprite) _stick_sprite->set_visible(should_be_visible);
    if (_outline_sprite) _outline_sprite->set_visible(should_be_visible);
    if (_hidden_sprite) _hidden_sprite->set_visible(!should_be_visible);
}

Sprite2D* GUIDEVirtualStickTextureRenderer::_ensure_sprite(Sprite2D *sprite, const Ref<Texture2D> &texture) {
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
