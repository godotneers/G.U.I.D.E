#ifndef GUIDE_CONTROLLER_RENDERER_H
#define GUIDE_CONTROLLER_RENDERER_H

#include "ui/guide_icon_renderer.h"
#include "guide_controller_render_style.h"
#include "ui/guide_formatting_utils.h"
#include "inputs/guide_input_joy_axis_1d.h"
#include "inputs/guide_input_joy_axis_2d.h"
#include "inputs/guide_input_joy_button.h"
#include <godot_cpp/classes/texture_rect.hpp>
#include <godot_cpp/classes/margin_container.hpp>
#include <godot_cpp/classes/resource_loader.hpp>

using namespace godot;

class GUIDEControllerRenderer : public GUIDEIconRenderer {
    GDCLASS(GUIDEControllerRenderer, GUIDEIconRenderer)

public:
    GUIDEControllerRenderer() {
        priority = -10;
    }
    virtual ~GUIDEControllerRenderer() {}

    static void set_style(GUIDEFormattingUtils::ControllerType type, const Ref<GUIDEControllerRenderStyle> &style) {
        if (style.is_null()) {
            UtilityFunctions::push_error("Icon set must not be null.");
            return;
        }
        if (type == GUIDEFormattingUtils::CONTROLLER_UNKNOWN) {
            UtilityFunctions::push_error("Cannot set icon set for the unknown controller. Use GUIDEInputFormattingOptions to set up how unknown controllers are rendered.");
            return;
        }
        _controller_styles[type] = style;
    }

    virtual bool supports(const Ref<GUIDEInput> &input, const Ref<GUIDEInputFormattingOptions> &options) override {
        return GUIDEFormattingUtils::effective_controller_type(input, options) != GUIDEFormattingUtils::CONTROLLER_UNKNOWN;
    }

    virtual void render(const Ref<GUIDEInput> &input, const Ref<GUIDEInputFormattingOptions> &options) override {
        GUIDEFormattingUtils::ControllerType type = GUIDEFormattingUtils::effective_controller_type(input, options);
        _setup_textures(type);

        if (_controls) {
            TypedArray<Node> children = _controls->get_children();
            for (int i = 0; i < children.size(); i++) {
                Object::cast_to<Control>(children[i])->set_visible(false);
            }
        }
        if (_directions) {
            TypedArray<Node> children = _directions->get_children();
            for (int i = 0; i < children.size(); i++) {
                Object::cast_to<Control>(children[i])->set_visible(false);
            }
            _directions->set_visible(false);
        }

        if (auto ja1 = Object::cast_to<GUIDEInputJoyAxis1D>(input.ptr())) {
            switch (ja1->get_axis()) {
                case JOY_AXIS_LEFT_X: if (_left_stick) _left_stick->set_visible(true); _show_left_right(); break;
                case JOY_AXIS_LEFT_Y: if (_left_stick) _left_stick->set_visible(true); _show_up_down(); break;
                case JOY_AXIS_RIGHT_X: if (_right_stick) _right_stick->set_visible(true); _show_left_right(); break;
                case JOY_AXIS_RIGHT_Y: if (_right_stick) _right_stick->set_visible(true); _show_up_down(); break;
                case JOY_AXIS_TRIGGER_LEFT: if (_left_trigger) _left_trigger->set_visible(true); break;
                case JOY_AXIS_TRIGGER_RIGHT: if (_right_trigger) _right_trigger->set_visible(true); break;
            }
        }

        if (auto ja2 = Object::cast_to<GUIDEInputJoyAxis2D>(input.ptr())) {
            switch (ja2->get_x_axis()) {
                case JOY_AXIS_LEFT_X: case JOY_AXIS_LEFT_Y: if (_left_stick) _left_stick->set_visible(true); break;
                case JOY_AXIS_RIGHT_X: case JOY_AXIS_RIGHT_Y: if (_right_stick) _right_stick->set_visible(true); break;
                default: break;
            }
        }

        if (auto jb = Object::cast_to<GUIDEInputJoyButton>(input.ptr())) {
            switch (jb->get_button()) {
                case JOY_BUTTON_A: if (_a_button) _a_button->set_visible(true); break;
                case JOY_BUTTON_B: if (_b_button) _b_button->set_visible(true); break;
                case JOY_BUTTON_X: if (_x_button) _x_button->set_visible(true); break;
                case JOY_BUTTON_Y: if (_y_button) _y_button->set_visible(true); break;
                case JOY_BUTTON_DPAD_LEFT: if (_dpad_left) _dpad_left->set_visible(true); break;
                case JOY_BUTTON_DPAD_RIGHT: if (_dpad_right) _dpad_right->set_visible(true); break;
                case JOY_BUTTON_DPAD_UP: if (_dpad_up) _dpad_up->set_visible(true); break;
                case JOY_BUTTON_DPAD_DOWN: if (_dpad_down) _dpad_down->set_visible(true); break;
                case JOY_BUTTON_LEFT_SHOULDER: if (_left_bumper) _left_bumper->set_visible(true); break;
                case JOY_BUTTON_RIGHT_SHOULDER: if (_right_bumper) _right_bumper->set_visible(true); break;
                case JOY_BUTTON_LEFT_STICK: if (_left_stick_click) _left_stick_click->set_visible(true); break;
                case JOY_BUTTON_RIGHT_STICK: if (_right_stick_click) _right_stick_click->set_visible(true); break;
                case JOY_BUTTON_START: if (_start) _start->set_visible(true); break;
                case JOY_BUTTON_BACK: if (_back) _back->set_visible(true); break;
                case JOY_BUTTON_MISC1: if (_misc1) _misc1->set_visible(true); break;
                case JOY_BUTTON_TOUCHPAD: if (_touch_pad) _touch_pad->set_visible(true); break;
            }
        }

        call_deferred("queue_sort");
    }

    virtual String cache_key(const Ref<GUIDEInput> &input, const Ref<GUIDEInputFormattingOptions> &options) override {
        GUIDEFormattingUtils::ControllerType type = GUIDEFormattingUtils::effective_controller_type(input, options);
        Ref<GUIDEControllerRenderStyle> style = _controller_styles[type];
        return "7581f483-bc68-411f-98ad-dc246fd2593a" + input->to_string() + (style.is_valid() ? style->get_path() : "");
    }

protected:
    static void _bind_methods() {
        ClassDB::bind_static_method("GUIDEControllerRenderer", D_METHOD("set_style", "type", "style"), &GUIDEControllerRenderer::set_style);
    }

    void _notification(int p_what) {
        if (p_what == NOTIFICATION_POSTINITIALIZE) {
            if (_controller_styles.is_empty()) {
                _controller_styles[GUIDEFormattingUtils::CONTROLLER_MICROSOFT] = 
                    ResourceLoader::get_singleton()->load("res://addons/guide/ui/renderers/controllers/styles/microsoft/microsoft.tres");
                _controller_styles[GUIDEFormattingUtils::CONTROLLER_NINTENDO] = 
                    ResourceLoader::get_singleton()->load("res://addons/guide/ui/renderers/controllers/styles/nintendo/nintendo.tres");
                _controller_styles[GUIDEFormattingUtils::CONTROLLER_SONY] = 
                    ResourceLoader::get_singleton()->load("res://addons/guide/ui/renderers/controllers/styles/sony/sony.tres");
            }
        }

        if (p_what == NOTIFICATION_READY) {
            _a_button = Object::cast_to<TextureRect>(get_node_or_null("%AButton"));
            _b_button = Object::cast_to<TextureRect>(get_node_or_null("%BButton"));
            _x_button = Object::cast_to<TextureRect>(get_node_or_null("%XButton"));
            _y_button = Object::cast_to<TextureRect>(get_node_or_null("%YButton"));
            _left_stick = Object::cast_to<TextureRect>(get_node_or_null("%LeftStick"));
            _left_stick_click = Object::cast_to<TextureRect>(get_node_or_null("%LeftStickClick"));
            _right_stick = Object::cast_to<TextureRect>(get_node_or_null("%RightStick"));
            _right_stick_click = Object::cast_to<TextureRect>(get_node_or_null("%RightStickClick"));
            _left_bumper = Object::cast_to<Control>(get_node_or_null("%LeftBumper"));
            _right_bumper = Object::cast_to<Control>(get_node_or_null("%RightBumper"));
            _left_trigger = Object::cast_to<Control>(get_node_or_null("%LeftTrigger"));
            _right_trigger = Object::cast_to<TextureRect>(get_node_or_null("%RightTrigger"));
            _dpad_up = Object::cast_to<TextureRect>(get_node_or_null("%DpadUp"));
            _dpad_left = Object::cast_to<TextureRect>(get_node_or_null("%DpadLeft"));
            _dpad_right = Object::cast_to<TextureRect>(get_node_or_null("%DpadRight"));
            _dpad_down = Object::cast_to<TextureRect>(get_node_or_null("%DpadDown"));
            _start = Object::cast_to<TextureRect>(get_node_or_null("%Start"));
            _misc1 = Object::cast_to<TextureRect>(get_node_or_null("%Misc1"));
            _back = Object::cast_to<TextureRect>(get_node_or_null("%Back"));
            _left_right = Object::cast_to<TextureRect>(get_node_or_null("%LeftRight"));
            _up_down = Object::cast_to<TextureRect>(get_node_or_null("%UpDown"));
            _controls = Object::cast_to<TextureRect>(get_node_or_null("%Controls"));
            _directions = Object::cast_to<TextureRect>(get_node_or_null("%Directions"));
            _touch_pad = Object::cast_to<TextureRect>(get_node_or_null("%TouchPad"));
        }
    }

private:
    static inline Dictionary _controller_styles;

    TextureRect *_a_button = nullptr;
    TextureRect *_b_button = nullptr;
    TextureRect *_x_button = nullptr;
    TextureRect *_y_button = nullptr;
    TextureRect *_left_stick = nullptr;
    TextureRect *_left_stick_click = nullptr;
    TextureRect *_right_stick = nullptr;
    TextureRect *_right_stick_click = nullptr;
    Control *_left_bumper = nullptr;
    Control *_right_bumper = nullptr;
    Control *_left_trigger = nullptr;
    TextureRect *_right_trigger = nullptr;
    TextureRect *_dpad_up = nullptr;
    TextureRect *_dpad_left = nullptr;
    TextureRect *_dpad_right = nullptr;
    TextureRect *_dpad_down = nullptr;
    TextureRect *_start = nullptr;
    TextureRect *_misc1 = nullptr;
    TextureRect *_back = nullptr;
    TextureRect *_left_right = nullptr;
    TextureRect *_up_down = nullptr;
    Control *_controls = nullptr;
    Control *_directions = nullptr;
    TextureRect *_touch_pad = nullptr;

    void _setup_textures(GUIDEFormattingUtils::ControllerType type) {
        if (type == GUIDEFormattingUtils::CONTROLLER_UNKNOWN) return;
        Ref<GUIDEControllerRenderStyle> style = _controller_styles[type];
        if (style.is_null()) return;

        if (_a_button) _a_button->set_texture(style->a_button);
        if (_b_button) _b_button->set_texture(style->b_button);
        if (_x_button) _x_button->set_texture(style->x_button);
        if (_y_button) _y_button->set_texture(style->y_button);
        if (_left_stick) _left_stick->set_texture(style->left_stick);
        if (_left_stick_click) _left_stick_click->set_texture(style->left_stick_click);
        if (_right_stick) _right_stick->set_texture(style->right_stick);
        if (_right_stick_click) _right_stick_click->set_texture(style->right_stick_click);
        if (auto tr = Object::cast_to<TextureRect>(_left_bumper)) tr->set_texture(style->left_bumper);
        if (auto tr = Object::cast_to<TextureRect>(_right_bumper)) tr->set_texture(style->right_bumper);
        if (auto tr = Object::cast_to<TextureRect>(_left_trigger)) tr->set_texture(style->left_trigger);
        if (_right_trigger) _right_trigger->set_texture(style->right_trigger);
        if (_dpad_up) _dpad_up->set_texture(style->dpad_up);
        if (_dpad_left) _dpad_left->set_texture(style->dpad_left);
        if (_dpad_right) _dpad_right->set_texture(style->dpad_right);
        if (_dpad_down) _dpad_down->set_texture(style->dpad_down);
        if (_start) _start->set_texture(style->start);
        if (_misc1) _misc1->set_texture(style->misc1);
        if (_back) _back->set_texture(style->back);
        if (_touch_pad) _touch_pad->set_texture(style->touch_pad);
        if (_left_right) _left_right->set_texture(style->horizontal);
        if (_up_down) _up_down->set_texture(style->vertical);
    }

    void _show_left_right() {
        if (_directions) _directions->set_visible(true);
        if (_left_right) _left_right->set_visible(true);
    }

    void _show_up_down() {
        if (_directions) _directions->set_visible(true);
        if (_up_down) _up_down->set_visible(true);
    }
};

#endif // GUIDE_CONTROLLER_RENDERER_H