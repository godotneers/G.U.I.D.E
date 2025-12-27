#include "guide_virtual_button.h"
#include <godot_cpp/classes/engine.hpp>
#include <godot_cpp/classes/input.hpp>
#include <godot_cpp/classes/input_event_joypad_button.hpp>
#include <godot_cpp/classes/input_event_screen_touch.hpp>
#include <godot_cpp/classes/input_event_screen_drag.hpp>
#include <godot_cpp/classes/viewport.hpp>
#include "../../../guide.h"

using namespace godot;

void GUIDEVirtualButton::_bind_methods() {
    ClassDB::bind_method(D_METHOD("get_button_radius"), &GUIDEVirtualButton::get_button_radius);
    ClassDB::bind_method(D_METHOD("set_button_radius", "radius"), &GUIDEVirtualButton::set_button_radius);
    ADD_PROPERTY(PropertyInfo(Variant::FLOAT, "button_radius"), "set_button_radius", "get_button_radius");

    ClassDB::bind_method(D_METHOD("get_button_index"), &GUIDEVirtualButton::get_button_index);
    ClassDB::bind_method(D_METHOD("set_button_index", "index"), &GUIDEVirtualButton::set_button_index);
    ADD_PROPERTY(PropertyInfo(Variant::INT, "button_index"), "set_button_index", "get_button_index");
}

GUIDEVirtualButton::GUIDEVirtualButton() {
}

GUIDEVirtualButton::~GUIDEVirtualButton() {
}

void GUIDEVirtualButton::_ready() {
    set_use_top_left(true);
    set_mouse_filter(MOUSE_FILTER_IGNORE);
    set_size(Vector2(0, 0));
    
    emit_signal("configuration_changed");
    emit_signal("changed");

    if (Engine::get_singleton()->is_editor_hint()) return;

    _reconnect();
    _report_input();
}

void GUIDEVirtualButton::_handle_mouse_input(const Ref<InputEventMouse> &event) {
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

void GUIDEVirtualButton::_handle_touch_input(const Ref<InputEvent> &event) {
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

bool GUIDEVirtualButton::_is_over_button(Vector2 world_position) const {
    return get_global_position().distance_squared_to(world_position) <= button_radius * button_radius;
}

void GUIDEVirtualButton::_try_actuate(Vector2 world_position) {
    if (!_is_actuated && _is_over_button(world_position)) {
        _is_actuated = true;
        _report_input();
    }
}

void GUIDEVirtualButton::_release() {
    if (_is_actuated) {
        _is_actuated = false;
        _report_input();
    }
}

void GUIDEVirtualButton::_report_input() {
    Ref<InputEventJoypadButton> event;
    event.instantiate();
    event->set_button_index(button_index);
    event->set_pressed(_is_actuated);
    event->set_device(_virtual_joy_id);
    GUIDE::get_singleton()->inject_input(event);
    if (draw_debug) queue_redraw();
    emit_signal("changed");
}

void GUIDEVirtualButton::_draw() {
    if (!draw_debug) return;
    Color color = _is_actuated ? Color(0.9, 0.9, 0.9, 0.8) : Color(0.5, 0.5, 0.5, 0.5);
    draw_circle(Vector2(0, 0), button_radius, color);
}