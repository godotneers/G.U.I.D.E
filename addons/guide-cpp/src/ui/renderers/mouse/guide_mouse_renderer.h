#ifndef GUIDE_MOUSE_RENDERER_H
#define GUIDE_MOUSE_RENDERER_H

#include "ui/guide_icon_renderer.h"
#include "guide_mouse_render_style.h"
#include "inputs/guide_input_mouse_button.h"
#include "inputs/guide_input_mouse_axis_1d.h"
#include "inputs/guide_input_mouse_axis_2d.h"
#include "inputs/guide_input_mouse_position.h"
#include <godot_cpp/classes/texture_rect.hpp>
#include <godot_cpp/classes/resource_loader.hpp>

using namespace godot;

class GUIDEMouseRenderer : public GUIDEIconRenderer {
    GDCLASS(GUIDEMouseRenderer, GUIDEIconRenderer)

public:
    GUIDEMouseRenderer() {}
    virtual ~GUIDEMouseRenderer() {}

    static void set_style(const Ref<GUIDEMouseRenderStyle> &style) {
        if (style.is_null()) {
            UtilityFunctions::push_error("Mouse style must not be null.");
            return;
        }
        _style = style;
    }

    virtual bool supports(const Ref<GUIDEInput> &input, const Ref<GUIDEInputFormattingOptions> &options) override {
        return Object::cast_to<GUIDEInputMouseButton>(input.ptr()) != nullptr ||
               Object::cast_to<GUIDEInputMouseAxis1D>(input.ptr()) != nullptr ||
               Object::cast_to<GUIDEInputMouseAxis2D>(input.ptr()) != nullptr ||
               Object::cast_to<GUIDEInputMousePosition>(input.ptr()) != nullptr;
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

        if (_mouse_blank) _mouse_blank->set_texture(_style->mouse_blank);
        if (_mouse_left) _mouse_left->set_texture(_style->mouse_left);
        if (_mouse_right) _mouse_right->set_texture(_style->mouse_right);
        if (_mouse_middle) _mouse_middle->set_texture(_style->mouse_middle);
        if (_mouse_side_a) _mouse_side_a->set_texture(_style->mouse_side_a);
        if (_mouse_side_b) _mouse_side_b->set_texture(_style->mouse_side_b);
        if (_mouse_cursor) _mouse_cursor->set_texture(_style->mouse_cursor);

        if (_left) _left->set_texture(_style->left);
        if (_right) _right->set_texture(_style->right);
        if (_up) _up->set_texture(_style->up);
        if (_down) _down->set_texture(_style->down);
        if (_horizontal) _horizontal->set_texture(_style->horizontal);
        if (_vertical) _vertical->set_texture(_style->vertical);

        if (auto mb = Object::cast_to<GUIDEInputMouseButton>(input.ptr())) {
            switch (mb->get_button()) {
                case MOUSE_BUTTON_LEFT: if (_mouse_left) _mouse_left->set_visible(true); break;
                case MOUSE_BUTTON_RIGHT: if (_mouse_right) _mouse_right->set_visible(true); break;
                case MOUSE_BUTTON_MIDDLE: if (_mouse_middle) _mouse_middle->set_visible(true); break;
                case MOUSE_BUTTON_WHEEL_UP:
                    if (_directions) _directions->set_visible(true);
                    if (_up) _up->set_visible(true);
                    if (_mouse_middle) _mouse_middle->set_visible(true);
                    break;
                case MOUSE_BUTTON_WHEEL_DOWN:
                    if (_directions) _directions->set_visible(true);
                    if (_down) _down->set_visible(true);
                    if (_mouse_middle) _mouse_middle->set_visible(true);
                    break;
                case MOUSE_BUTTON_WHEEL_LEFT:
                    if (_directions) _directions->set_visible(true);
                    if (_left) _left->set_visible(true);
                    if (_mouse_middle) _mouse_middle->set_visible(true);
                    break;
                case MOUSE_BUTTON_WHEEL_RIGHT:
                    if (_directions) _directions->set_visible(true);
                    if (_right) _right->set_visible(true);
                    if (_mouse_middle) _mouse_middle->set_visible(true);
                    break;
                case MOUSE_BUTTON_XBUTTON1: if (_mouse_side_a) _mouse_side_a->set_visible(true); break;
                case MOUSE_BUTTON_XBUTTON2: if (_mouse_side_b) _mouse_side_b->set_visible(true); break;
            }
        }

        if (auto ma1 = Object::cast_to<GUIDEInputMouseAxis1D>(input.ptr())) {
            if (_mouse_blank) _mouse_blank->set_visible(true);
            if (_directions) _directions->set_visible(true);
            if (ma1->get_axis() == GUIDEInputMouseAxis1D::AXIS_X) {
                if (_horizontal) _horizontal->set_visible(true);
            } else {
                if (_vertical) _vertical->set_visible(true);
            }
        }

        if (Object::cast_to<GUIDEInputMouseAxis2D>(input.ptr())) {
            if (_mouse_blank) _mouse_blank->set_visible(true);
        }

        if (Object::cast_to<GUIDEInputMousePosition>(input.ptr())) {
            if (_mouse_cursor) _mouse_cursor->set_visible(true);
        }

        call_deferred("queue_sort");
    }

    virtual String cache_key(const Ref<GUIDEInput> &input, const Ref<GUIDEInputFormattingOptions> &options) override {
        return "7e27520a-b6d8-4451-858d-e94330c82e85" + input->to_string() + (_style.is_valid() ? _style->get_path() : "");
    }

protected:
    static void _bind_methods() {
        ClassDB::bind_static_method("GUIDEMouseRenderer", D_METHOD("set_style", "style"), &GUIDEMouseRenderer::set_style);
    }

    void _notification(int p_what) {
        if (p_what == NOTIFICATION_POSTINITIALIZE) {
            if (_style.is_null()) {
                _style = ResourceLoader::get_singleton()->load("res://addons/guide-cpp/plugin/ui/renderers/mouse/styles/default.tres");
            }
        }
        if (p_what == NOTIFICATION_READY) {
            _mouse_left = Object::cast_to<TextureRect>(get_node_or_null("%MouseLeft"));
            _mouse_right = Object::cast_to<TextureRect>(get_node_or_null("%MouseRight"));
            _mouse_middle = Object::cast_to<TextureRect>(get_node_or_null("%MouseMiddle"));
            _mouse_side_a = Object::cast_to<TextureRect>(get_node_or_null("%MouseSideA"));
            _mouse_side_b = Object::cast_to<TextureRect>(get_node_or_null("%MouseSideB"));
            _mouse_blank = Object::cast_to<TextureRect>(get_node_or_null("%MouseBlank"));
            _mouse_cursor = Object::cast_to<TextureRect>(get_node_or_null("%MouseCursor"));
            _controls = Object::cast_to<Control>(get_node_or_null("%Controls"));
            _directions = Object::cast_to<Control>(get_node_or_null("%Directions"));
            _left = Object::cast_to<TextureRect>(get_node_or_null("%Left"));
            _right = Object::cast_to<TextureRect>(get_node_or_null("%Right"));
            _up = Object::cast_to<TextureRect>(get_node_or_null("%Up"));
            _down = Object::cast_to<TextureRect>(get_node_or_null("%Down"));
            _horizontal = Object::cast_to<TextureRect>(get_node_or_null("%Horizontal"));
            _vertical = Object::cast_to<TextureRect>(get_node_or_null("%Vertical"));
        }
    }

private:
    static inline Ref<GUIDEMouseRenderStyle> _style;

    TextureRect *_mouse_left = nullptr;
    TextureRect *_mouse_right = nullptr;
    TextureRect *_mouse_middle = nullptr;
    TextureRect *_mouse_side_a = nullptr;
    TextureRect *_mouse_side_b = nullptr;
    TextureRect *_mouse_blank = nullptr;
    TextureRect *_mouse_cursor = nullptr;

    Control *_controls = nullptr;
    Control *_directions = nullptr;
    TextureRect *_left = nullptr;
    TextureRect *_right = nullptr;
    TextureRect *_up = nullptr;
    TextureRect *_down = nullptr;
    TextureRect *_horizontal = nullptr;
    TextureRect *_vertical = nullptr;
};

#endif // GUIDE_MOUSE_RENDERER_H