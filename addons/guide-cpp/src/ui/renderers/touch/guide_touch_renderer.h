#ifndef GUIDE_TOUCH_RENDERER_H
#define GUIDE_TOUCH_RENDERER_H

#include "ui/guide_icon_renderer.h"
#include "guide_touch_render_style.h"
#include "inputs/guide_input_touch_base.h"
#include "inputs/guide_input_touch_axis_1d.h"
#include "inputs/guide_input_touch_axis_2d.h"
#include "inputs/guide_input_touch_position.h"
#include "inputs/guide_input_touch_angle.h"
#include "inputs/guide_input_touch_distance.h"
#include <godot_cpp/classes/texture_rect.hpp>
#include <godot_cpp/classes/resource_loader.hpp>

using namespace godot;

class GUIDETouchRenderer : public GUIDEIconRenderer {
    GDCLASS(GUIDETouchRenderer, GUIDEIconRenderer)

public:
    GUIDETouchRenderer() {}
    virtual ~GUIDETouchRenderer() {}

    static void set_style(const Ref<GUIDETouchRenderStyle> &style) {
        if (style.is_null()) {
            UtilityFunctions::push_error("Touch style must not be null.");
            return;
        }
        _style = style;
    }

    virtual bool supports(const Ref<GUIDEInput> &input, const Ref<GUIDEInputFormattingOptions> &options) override {
        return Object::cast_to<GUIDEInputTouchAxis1D>(input.ptr()) != nullptr ||
               Object::cast_to<GUIDEInputTouchAxis2D>(input.ptr()) != nullptr ||
               Object::cast_to<GUIDEInputTouchPosition>(input.ptr()) != nullptr ||
               Object::cast_to<GUIDEInputTouchAngle>(input.ptr()) != nullptr ||
               Object::cast_to<GUIDEInputTouchDistance>(input.ptr()) != nullptr;
    }

    virtual void render(const Ref<GUIDEInput> &input, const Ref<GUIDEInputFormattingOptions> &options) override {
        if (_style.is_null()) return;

        if (_controls) {
            TypedArray<Node> children = _controls->get_children();
            for (int i = 0; i < children.size(); i++) Object::cast_to<Control>(children[i])->set_visible(false);
        }
        if (_directions) {
            TypedArray<Node> children = _directions->get_children();
            for (int i = 0; i < children.size(); i++) Object::cast_to<Control>(children[i])->set_visible(false);
            _directions->set_visible(false);
        }

        if (_1_finger) _1_finger->set_texture(_style->one_finger);
        if (_2_finger) _2_finger->set_texture(_style->two_fingers);
        if (_3_finger) _3_finger->set_texture(_style->three_fingers);
        if (_4_finger) _4_finger->set_texture(_style->four_fingers);
        if (_rotate) _rotate->set_texture(_style->rotate);
        if (_zoom) _zoom->set_texture(_style->zoom);
        if (_horizontal) _horizontal->set_texture(_style->horizontal);
        if (_vertical) _vertical->set_texture(_style->vertical);
        if (_axis2d) _axis2d->set_texture(_style->both);

        if (auto tb = Object::cast_to<GUIDEInputTouchBase>(input.ptr())) {
            switch (tb->get_finger_count()) {
                case 2: if (_2_finger) _2_finger->set_visible(true); break;
                case 3: if (_3_finger) _3_finger->set_visible(true); break;
                case 4: if (_4_finger) _4_finger->set_visible(true); break;
                default: if (_1_finger) _1_finger->set_visible(true); break;
            }
        }

        if (Object::cast_to<GUIDEInputTouchAxis2D>(input.ptr())) {
            if (_directions) _directions->set_visible(true);
            if (_axis2d) _axis2d->set_visible(true);
        }

        if (auto ta1 = Object::cast_to<GUIDEInputTouchAxis1D>(input.ptr())) {
            if (_directions) _directions->set_visible(true);
            if (ta1->get_axis() == GUIDEInputTouchAxis1D::AXIS_X) {
                if (_horizontal) _horizontal->set_visible(true);
            } else {
                if (_vertical) _vertical->set_visible(true);
            }
        }

        if (Object::cast_to<GUIDEInputTouchDistance>(input.ptr())) {
            if (_zoom) _zoom->set_visible(true);
        }

        if (Object::cast_to<GUIDEInputTouchAngle>(input.ptr())) {
            if (_rotate) _rotate->set_visible(true);
        }

        call_deferred("queue_sort");
    }

    virtual String cache_key(const Ref<GUIDEInput> &input, const Ref<GUIDEInputFormattingOptions> &options) override {
        return "1f4c5082-d419-465f-aba8-f889caaff335" + input->to_string() + (_style.is_valid() ? _style->get_path() : "");
    }

protected:
    static void _bind_methods() {
        ClassDB::bind_static_method("GUIDETouchRenderer", D_METHOD("set_style", "style"), &GUIDETouchRenderer::set_style);
    }

    void _notification(int p_what) {
        if (p_what == NOTIFICATION_POSTINITIALIZE) {
            if (_style.is_null()) {
                _style = ResourceLoader::get_singleton()->load("res://addons/guide/ui/renderers/touch/styles/default.tres");
            }
        }
        if (p_what == NOTIFICATION_READY) {
            _controls = Object::cast_to<Control>(get_node_or_null("%Controls"));
            _1_finger = Object::cast_to<TextureRect>(get_node_or_null("%T1Finger"));
            _2_finger = Object::cast_to<TextureRect>(get_node_or_null("%T2Fingers"));
            _3_finger = Object::cast_to<TextureRect>(get_node_or_null("%T3Fingers"));
            _4_finger = Object::cast_to<TextureRect>(get_node_or_null("%T4Fingers"));
            _rotate = Object::cast_to<TextureRect>(get_node_or_null("%Rotate"));
            _zoom = Object::cast_to<TextureRect>(get_node_or_null("%Zoom"));
            _directions = Object::cast_to<Control>(get_node_or_null("%Directions"));
            _horizontal = Object::cast_to<TextureRect>(get_node_or_null("%Horizontal"));
            _vertical = Object::cast_to<TextureRect>(get_node_or_null("%Vertical"));
            _axis2d = Object::cast_to<TextureRect>(get_node_or_null("%Axis2D"));
        }
    }

private:
    static inline Ref<GUIDETouchRenderStyle> _style;

    Control *_controls = nullptr;
    TextureRect *_1_finger = nullptr;
    TextureRect *_2_finger = nullptr;
    TextureRect *_3_finger = nullptr;
    TextureRect *_4_finger = nullptr;
    TextureRect *_rotate = nullptr;
    TextureRect *_zoom = nullptr;

    Control *_directions = nullptr;
    TextureRect *_horizontal = nullptr;
    TextureRect *_vertical = nullptr;
    TextureRect *_axis2d = nullptr;
};

#endif // GUIDE_TOUCH_RENDERER_H