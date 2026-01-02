#ifndef GUIDE_VIRTUAL_BUTTON_H
#define GUIDE_VIRTUAL_BUTTON_H

#include "../guide_virtual_joy_base.h"
#include <godot_cpp/classes/engine.hpp>
#include <godot_cpp/classes/input.hpp>
#include <godot_cpp/classes/input_event_joypad_button.hpp>
#include <godot_cpp/classes/input_event_screen_touch.hpp>
#include <godot_cpp/classes/input_event_screen_drag.hpp>
#include <godot_cpp/classes/viewport.hpp>
#include <godot_cpp/classes/input_event_mouse_motion.hpp>
#include <godot_cpp/classes/input_event_mouse_button.hpp>
#include "../../../guide.h"

using namespace godot;

class GUIDEVirtualButton : public GUIDEVirtualJoyBase {
    GDCLASS(GUIDEVirtualButton, GUIDEVirtualJoyBase)

public:
    GUIDEVirtualButton() {}
    virtual ~GUIDEVirtualButton() {}

    void _ready() override {
        set_use_top_left(true);
        set_mouse_filter(MOUSE_FILTER_IGNORE);
        set_size(Vector2(0, 0));
        
        if (Engine::get_singleton()->is_editor_hint()) { 
            set_deferred("size", Vector2(0, 0)); 
        }

        emit_signal("configuration_changed");
        emit_signal("changed");

        if (Engine::get_singleton()->is_editor_hint()) return;

        _reconnect();
        _report_input();
    }

    void _draw() override {
        if (!draw_debug) return;
        Color color = _is_actuated ? Color(0.9, 0.9, 0.9, 0.8) : Color(0.5, 0.5, 0.5, 0.5);
        draw_circle(Vector2(0, 0), button_radius, color);
    }

    virtual void _handle_mouse_input(const Ref<InputEventMouse> &event) override {
        Vector2 pos = _screen_to_world(event->get_position());
        if (!_is_actuated) {
            Ref<InputEventMouseMotion> mm = event;
            if (mm.is_valid()) {
                if (Input::get_singleton()->is_mouse_button_pressed(MOUSE_BUTTON_LEFT)) {
                    _try_actuate(pos);
                    if (_is_over_button(pos)) {
                        get_viewport()->set_input_as_handled();
                    }
                }
                return;
            }

            Ref<InputEventMouseButton> mb = event;
            if (mb.is_valid() && mb->is_pressed() && mb->get_button_index() == MOUSE_BUTTON_LEFT) {
                _try_actuate(pos);
                if (_is_over_button(pos)) {
                    _mouse_down_consumed = true;
                    get_viewport()->set_input_as_handled();
                }
            }
            return;
        }

        Ref<InputEventMouseMotion> mm = event;
        if (mm.is_valid()) {
            if (!_is_over_button(pos)) {
                _release();
            }
            get_viewport()->set_input_as_handled();
            return;
        }

        Ref<InputEventMouseButton> mb = event;
        if (mb.is_valid() && !mb->is_pressed() && mb->get_button_index() == MOUSE_BUTTON_LEFT) {
            _release();
            get_viewport()->set_input_as_handled();
        }
    }

    virtual void _handle_touch_input(const Ref<InputEvent> &event) override {
        Ref<InputEventScreenTouch> st = event;
        if (st.is_valid()) {
            if (st->is_pressed()) {
                _finger_positions[st->get_index()] = st->get_position();
            } else {
                _finger_positions.erase(st->get_index());
            }
        } else {
            Ref<InputEventScreenDrag> sd = event;
            if (sd.is_valid()) {
                _finger_positions[sd->get_index()] = sd->get_position();
            }
        }

        Vector2 event_pos = Vector2(0, 0);
        if (st.is_valid()) event_pos = st->get_position();
        else if (Ref<InputEventScreenDrag>(event).is_valid()) event_pos = Ref<InputEventScreenDrag>(event)->get_position();

        if (_is_over_button(event_pos)) {
            get_viewport()->set_input_as_handled();
        }

        if (!_is_actuated) {
            Array positions = _finger_positions.values();
            for (int i = 0; i < positions.size(); i++) {
                _try_actuate(_screen_to_world(positions[i]));
            }
            return;
        }

        Array positions = _finger_positions.values();
        for (int i = 0; i < positions.size(); i++) {
            if (_is_over_button(_screen_to_world(positions[i]))) return;
        }
        _release();
    }

    bool _is_over_button(Vector2 world_position) const {
        return get_global_position().distance_squared_to(world_position) <= button_radius * button_radius;
    }

    void _try_actuate(Vector2 world_position) {
        if (!_is_actuated && _is_over_button(world_position)) {
            _is_actuated = true;
            _report_input();
        }
    }

    void _release() {
        if (_is_actuated) {
            _is_actuated = false;
            _report_input();
        }
    }

    void _report_input() {
        Ref<InputEventJoypadButton> event;
        event.instantiate();
        event->set_button_index(button_index);
        event->set_pressed(_is_actuated);
        event->set_device(_virtual_joy_id);
        GUIDECpp::get_singleton()->inject_input(event);
        if (draw_debug) queue_redraw();
        emit_signal("changed");
    }

    double get_button_radius() const { return button_radius; }
    void set_button_radius(double p_radius) { button_radius = p_radius; queue_redraw(); emit_signal("configuration_changed"); }

    int get_button_index() const { return (int)button_index; }
    void set_button_index(int p_index) { button_index = (JoyButton)p_index; emit_signal("configuration_changed"); }

protected:
    static void _bind_methods() {
        ClassDB::bind_method(D_METHOD("get_button_radius"), &GUIDEVirtualButton::get_button_radius);
        ClassDB::bind_method(D_METHOD("set_button_radius", "radius"), &GUIDEVirtualButton::set_button_radius);
        ADD_PROPERTY(PropertyInfo(Variant::FLOAT, "button_radius"), "set_button_radius", "get_button_radius");

        ClassDB::bind_method(D_METHOD("get_button_index"), &GUIDEVirtualButton::get_button_index);
        ClassDB::bind_method(D_METHOD("set_button_index", "index"), &GUIDEVirtualButton::set_button_index);
        ADD_PROPERTY(PropertyInfo(Variant::INT, "button_index"), "set_button_index", "get_button_index");
    }

private:
    double button_radius = 100.0;
    JoyButton button_index = JOY_BUTTON_A;
    Dictionary _finger_positions;
    bool _mouse_down_consumed = false;
};

#endif // GUIDE_VIRTUAL_BUTTON_H
