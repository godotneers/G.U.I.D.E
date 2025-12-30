#ifndef GUIDE_KEY_RENDERER_H
#define GUIDE_KEY_RENDERER_H

#include "ui/guide_icon_renderer.h"
#include "guide_key_render_style.h"
#include "inputs/guide_input_key.h"
#include <godot_cpp/classes/label.hpp>
#include <godot_cpp/classes/nine_patch_rect.hpp>
#include <godot_cpp/classes/resource_loader.hpp>
#include <godot_cpp/classes/display_server.hpp>
#include <godot_cpp/classes/os.hpp>

using namespace godot;

class GUIDEKeyRenderer : public GUIDEIconRenderer {
    GDCLASS(GUIDEKeyRenderer, GUIDEIconRenderer)

public:
    GUIDEKeyRenderer() {}
    virtual ~GUIDEKeyRenderer() {}

    static void set_style(const Ref<GUIDEKeyRenderStyle> &style) {
        if (style.is_null()) {
            UtilityFunctions::push_error("Key style must not be null.");
            return;
        }
        _style = style;
    }

    virtual bool supports(const Ref<GUIDEInput> &input, const Ref<GUIDEInputFormattingOptions> &options) override {
        return Object::cast_to<GUIDEInputKey>(input.ptr()) != nullptr;
    }

    virtual void render(const Ref<GUIDEInput> &input, const Ref<GUIDEInputFormattingOptions> &options) override {
        auto ik = Object::cast_to<GUIDEInputKey>(input.ptr());
        if (ik == nullptr || _style.is_null()) return;

        if (_nine_patch_rect) {
            _nine_patch_rect->set_texture(_style->keycaps);
            _nine_patch_rect->set_region_rect(_style->region_rect);
            _nine_patch_rect->set_patch_margin(SIDE_LEFT, _style->patch_margin_left);
            _nine_patch_rect->set_patch_margin(SIDE_TOP, _style->patch_margin_top);
            _nine_patch_rect->set_patch_margin(SIDE_RIGHT, _style->patch_margin_right);
            _nine_patch_rect->set_patch_margin(SIDE_BOTTOM, _style->patch_margin_bottom);
        }

        if (_label) {
            Key label_key = DisplayServer::get_singleton()->keyboard_get_label_from_physical(ik->get_key());
            _label->set_text(OS::get_singleton()->get_keycode_string(label_key).strip_edges());
            _label->add_theme_color_override("font_color", _style->font_color);
            _label->add_theme_font_override("font", _style->font);
            _label->add_theme_font_size_override("font_size", _style->font_size);
        }

        set_size(Vector2(0, 0));
        call_deferred("queue_sort");
    }

    virtual String cache_key(const Ref<GUIDEInput> &input, const Ref<GUIDEInputFormattingOptions> &options) override {
        return "ed6923d5-4115-44bd-b35e-2c4102ffc83e" + input->to_string() + (_style.is_valid() ? _style->get_path() : "");
    }

protected:
    static void _bind_methods() {
        ClassDB::bind_static_method("GUIDEKeyRenderer", D_METHOD("set_style", "style"), &GUIDEKeyRenderer::set_style);
    }

    void _notification(int p_what) {
        if (p_what == NOTIFICATION_POSTINITIALIZE) {
            if (_style.is_null()) {
                _style = ResourceLoader::get_singleton()->load("res://addons/guide/ui/renderers/keyboard/styles/default.tres");
            }
        }
        if (p_what == NOTIFICATION_READY) {
            _label = Object::cast_to<Label>(get_node_or_null("%Label"));
            _nine_patch_rect = Object::cast_to<NinePatchRect>(get_node_or_null("%NinePatchRect"));
        }
    }

private:
    static inline Ref<GUIDEKeyRenderStyle> _style;

    Label *_label = nullptr;
    NinePatchRect *_nine_patch_rect = nullptr;
};

#endif // GUIDE_KEY_RENDERER_H