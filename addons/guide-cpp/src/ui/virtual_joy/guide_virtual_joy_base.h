#ifndef GUIDE_VIRTUAL_JOY_BASE_H
#define GUIDE_VIRTUAL_JOY_BASE_H

#include <godot_cpp/classes/center_container.hpp>
#include <godot_cpp/classes/input_event_mouse.hpp>
#include <godot_cpp/core/class_db.hpp>
#include "../../guide.h"

using namespace godot;

class GUIDEVirtualJoyBase : public CenterContainer {
    GDCLASS(GUIDEVirtualJoyBase, CenterContainer)

public:
    enum InputMode {
        MODE_TOUCH,
        MODE_MOUSE,
        MODE_MOUSE_AND_TOUCH
    };

    GUIDEVirtualJoyBase() {}
    virtual ~GUIDEVirtualJoyBase() {}

    void _input(const Ref<InputEvent> &event) override {
        Ref<InputEventMouse> mouse_event = event;
        if (mouse_event.is_valid()) {
            if (input_mode == MODE_MOUSE || input_mode == MODE_MOUSE_AND_TOUCH) {
                _handle_mouse_input(mouse_event);
            }
        }

        if (event->is_class("InputEventScreenTouch") || event->is_class("InputEventScreenDrag")) {
            if (input_mode == MODE_TOUCH || input_mode == MODE_MOUSE_AND_TOUCH) {
                _handle_touch_input(event);
            }
        }
    }

    virtual void _handle_mouse_input(const Ref<InputEventMouse> &event) {}
    virtual void _handle_touch_input(const Ref<InputEvent> &event) {}

    Vector2 _screen_to_world(Vector2 input) const {
        return get_canvas_transform().affine_inverse().xform(input);
    }

    void _reconnect() {
        if (!is_node_ready()) return;
        if (_virtual_joy_id != 0) {
            GUIDECPP::get_singleton()->get_input_state()->disconnect_virtual_stick(_virtual_joy_id);
        }
        _virtual_joy_id = GUIDECPP::get_singleton()->get_input_state()->connect_virtual_stick(virtual_device);
    }

    int get_virtual_device() const { return virtual_device; }
    void set_virtual_device(int p_device) { virtual_device = p_device; _reconnect(); emit_signal("configuration_changed"); }

    InputMode get_input_mode() const { return input_mode; }
    void set_input_mode(InputMode p_mode) { input_mode = p_mode; emit_signal("configuration_changed"); }

    bool get_draw_debug() const { return draw_debug; }
    void set_draw_debug(bool p_draw) { draw_debug = p_draw; queue_redraw(); emit_signal("configuration_changed"); }

    bool _is_actuated = false;

protected:
    static void _bind_methods() {
        BIND_ENUM_CONSTANT(MODE_TOUCH);
        BIND_ENUM_CONSTANT(MODE_MOUSE);
        BIND_ENUM_CONSTANT(MODE_MOUSE_AND_TOUCH);

        ADD_SIGNAL(MethodInfo("changed"));
        ADD_SIGNAL(MethodInfo("configuration_changed"));
    }

    int virtual_device = 0;
    InputMode input_mode = MODE_TOUCH;
    bool draw_debug = false;
    int _virtual_joy_id = 0;
};

VARIANT_ENUM_CAST(GUIDEVirtualJoyBase::InputMode);

#endif // GUIDE_VIRTUAL_JOY_BASE_H
