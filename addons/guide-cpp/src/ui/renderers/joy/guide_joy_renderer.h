#ifndef GUIDE_JOY_RENDERER_H
#define GUIDE_JOY_RENDERER_H

#include "ui/guide_icon_renderer.h"
#include "guide_joy_render_style.h"
#include "inputs/guide_input_joy_base.h"
#include "inputs/guide_input_joy_axis_1d.h"
#include "inputs/guide_input_joy_axis_2d.h"
#include "inputs/guide_input_joy_button.h"
#include <godot_cpp/classes/texture_rect.hpp>
#include <godot_cpp/classes/label.hpp>
#include <godot_cpp/classes/resource_loader.hpp>

using namespace godot;

class GUIDEJoyRenderer : public GUIDEIconRenderer {
    GDCLASS(GUIDEJoyRenderer, GUIDEIconRenderer)

public:
    GUIDEJoyRenderer() {}
    virtual ~GUIDEJoyRenderer() {}

    static void set_style(const Ref<GUIDEJoyRenderStyle> &style) {
        if (style.is_null()) {
            UtilityFunctions::push_error("Joy style must not be null.");
            return;
        }
        _style = style;
    }

    virtual bool supports(const Ref<GUIDEInput> &input, const Ref<GUIDEInputFormattingOptions> &options) override {
        return Object::cast_to<GUIDEInputJoyBase>(input.ptr()) != nullptr;
    }

    virtual void render(const Ref<GUIDEInput> &input, const Ref<GUIDEInputFormattingOptions> &options) override {
        if (_style.is_null()) return;

        if (_stick) { _stick->set_texture(_style->stick); _stick->set_visible(false); }
        if (_button) { _button->set_texture(_style->button); _button->set_visible(false); }
        if (_directions) _directions->set_visible(false);
        if (_horizontal) { _horizontal->set_texture(_style->horizontal); _horizontal->set_visible(false); }
        if (_vertical) { _vertical->set_texture(_style->vertical); _vertical->set_visible(false); }

        if (_text) {
            _text->set_text("");
            _text->add_theme_color_override("font_color", _style->font_color);
            _text->add_theme_font_override("font", _style->font);
            _text->add_theme_font_size_override("font_size", _style->font_size);
        }

        if (auto ja1 = Object::cast_to<GUIDEInputJoyAxis1D>(input.ptr())) {
            if (_stick) _stick->set_visible(true);
            switch (ja1->get_axis()) {
                case JOY_AXIS_LEFT_X:
                    if (_directions) _directions->set_visible(true);
                    if (_text) _text->set_text("1");
                    if (_horizontal) _horizontal->set_visible(true);
                    break;
                case JOY_AXIS_RIGHT_X:
                    if (_directions) _directions->set_visible(true);
                    if (_text) _text->set_text("2");
                    if (_horizontal) _horizontal->set_visible(true);
                    break;
                case JOY_AXIS_LEFT_Y:
                    if (_directions) _directions->set_visible(true);
                    if (_text) _text->set_text("1");
                    if (_vertical) _vertical->set_visible(true);
                    break;
                case JOY_AXIS_RIGHT_Y:
                    if (_directions) _directions->set_visible(true);
                    if (_text) _text->set_text("2");
                    if (_vertical) _vertical->set_visible(true);
                    break;
                case JOY_AXIS_TRIGGER_LEFT:
                    if (_text) _text->set_text("3");
                    break;
                case JOY_AXIS_TRIGGER_RIGHT:
                    if (_text) _text->set_text("4");
                    break;
            }
        }

        if (auto ja2 = Object::cast_to<GUIDEInputJoyAxis2D>(input.ptr())) {
            if (_stick) _stick->set_visible(true);
            switch (ja2->get_x_axis()) {
                case JOY_AXIS_LEFT_X: case JOY_AXIS_LEFT_Y: if (_text) _text->set_text("1"); break;
                case JOY_AXIS_RIGHT_X: case JOY_AXIS_RIGHT_Y: if (_text) _text->set_text("2"); break;
                default: if (_text) _text->set_text(String::num(ja2->get_x_axis() + ja2->get_y_axis())); break;
            }
        }

        if (auto jb = Object::cast_to<GUIDEInputJoyButton>(input.ptr())) {
            if (_button) _button->set_visible(true);
            if (_text) _text->set_text(String::num(jb->get_button()));
        }

        call_deferred("queue_sort");
    }

    virtual String cache_key(const Ref<GUIDEInput> &input, const Ref<GUIDEInputFormattingOptions> &options) override {
        return "a9ced629-de65-4c31-9de0-8e4cbf88a2e0" + input->to_string() + (_style.is_valid() ? _style->get_path() : "");
    }

protected:
    static void _bind_methods() {
        ClassDB::bind_static_method("GUIDEJoyRenderer", D_METHOD("set_style", "style"), &GUIDEJoyRenderer::set_style);
    }

    void _notification(int p_what) {
        if (p_what == NOTIFICATION_POSTINITIALIZE) {
            if (_style.is_null()) {
                _style = ResourceLoader::get_singleton()->load("res://addons/guide/ui/renderers/joy/styles/default.tres");
            }
        }
        if (p_what == NOTIFICATION_READY) {
            _stick = Object::cast_to<TextureRect>(get_node_or_null("%Stick"));
            _button = Object::cast_to<TextureRect>(get_node_or_null("%Button"));
            _text = Object::cast_to<Label>(get_node_or_null("%Text"));
            _directions = Object::cast_to<Control>(get_node_or_null("%Directions"));
            _horizontal = Object::cast_to<TextureRect>(get_node_or_null("%Horizontal"));
            _vertical = Object::cast_to<TextureRect>(get_node_or_null("%Vertical"));
        }
    }

private:
    static inline Ref<GUIDEJoyRenderStyle> _style;

    TextureRect *_stick = nullptr;
    TextureRect *_button = nullptr;
    Label *_text = nullptr;
    Control *_directions = nullptr;
    TextureRect *_horizontal = nullptr;
    TextureRect *_vertical = nullptr;
};

#endif // GUIDE_JOY_RENDERER_H