#ifndef GUIDE_VIRTUAL_STICK_H
#define GUIDE_VIRTUAL_STICK_H

#include "../guide_virtual_joy_base.h"
#include <godot_cpp/classes/engine.hpp>
#include <godot_cpp/classes/input.hpp>
#include <godot_cpp/classes/input_event_joypad_motion.hpp>
#include <godot_cpp/classes/input_event_screen_touch.hpp>
#include <godot_cpp/classes/input_event_screen_drag.hpp>
#include <godot_cpp/classes/viewport.hpp>
#include <godot_cpp/core/math.hpp>
#include "../../../guide.h"

using namespace godot;

class GUIDEVirtualStick : public GUIDEVirtualJoyBase {
    GDCLASS(GUIDEVirtualStick, GUIDEVirtualJoyBase)

public:
    enum PositionMode {
        MODE_FIXED,
        MODE_RELATIVE
    };

    enum StickPosition {
        POSITION_LEFT,
        POSITION_RIGHT
    };

    GUIDEVirtualStick() {}
    virtual ~GUIDEVirtualStick() {}

    void _ready() override {
        set_use_top_left(true);
        set_size(Vector2(0, 0));
        if (Engine::get_singleton()->is_editor_hint()) {
            set_deferred("size", Vector2(0, 0));
        }
        _initial_pos = get_global_position();
        _start_pos = get_global_position();
        _current_pos = get_global_position();
        set_mouse_filter(MOUSE_FILTER_IGNORE);

        emit_signal("configuration_changed");
        emit_signal("changed");

        if (Engine::get_singleton()->is_editor_hint()) return;

        _reconnect();
        _report_input();
    }

    void _draw() override {
        if (!draw_debug) return;
        draw_circle(Vector2(0, 0), interaction_zone_radius, Color(0.5, 0.5, 1.0, 0.5));
        draw_circle(Vector2(0, 0), max_actuation_radius, Color(0.9, 0.2, 0.2, 0.5));
        draw_circle(Vector2(0, 0), stick_radius, Color(0.9, 0.9, 0.3, 0.5));
        if (_is_actuated) {
            draw_circle(get_stick_relative_position(), stick_radius, Color(0.9, 0.9, 0.7, 0.5));
        }
    }

    virtual void _handle_mouse_input(const Ref<InputEventMouse> &event) override {
        if (!_is_actuated) {
            Ref<InputEventMouseMotion> mm = event;
            if (mm.is_valid()) return;

            Ref<InputEventMouseButton> mb = event;
            if (mb.is_valid() && mb->is_pressed() && mb->get_button_index() == MOUSE_BUTTON_LEFT) {
                Vector2 pos = _screen_to_world(mb->get_position());
                _try_actuate(pos);
                if (_is_actuated) {
                    get_viewport()->set_input_as_handled();
                }
            }
            return;
        }

        Ref<InputEventMouseMotion> mm = event;
        if (mm.is_valid()) {
            _move_towards(_screen_to_world(mm->get_position()));
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
        if (!_is_actuated) {
            Ref<InputEventScreenTouch> st = event;
            if (st.is_valid() && st->is_pressed()) {
                Vector2 pos = _screen_to_world(st->get_position());
                _try_actuate(pos);
                if (_is_actuated) {
                    _finger_index = st->get_index();
                    get_viewport()->set_input_as_handled();
                }
            }
            return;
        }

        Ref<InputEventScreenTouch> st = event;
        Ref<InputEventScreenDrag> sd = event;

        int index = -1;
        Vector2 pos;
        bool released = false;

        if (st.is_valid()) {
            index = st->get_index();
            pos = st->get_position();
            released = !st->is_pressed();
        } else if (sd.is_valid()) {
            index = sd->get_index();
            pos = sd->get_position();
        }

        if (index != _finger_index) return;

        if (sd.is_valid()) {
            _move_towards(_screen_to_world(pos));
            get_viewport()->set_input_as_handled();
        } else if (released) {
            _release();
            get_viewport()->set_input_as_handled();
            _finger_index = -1;
        }
    }

    void _try_actuate(Vector2 world_position) {
        if (position_mode == MODE_FIXED) {
            if (world_position.distance_to(get_global_position()) > stick_radius) return;
            _start_pos = get_global_position();
            _current_pos = world_position;
            _is_actuated = true;
            _report_input();
        } else {
            if (world_position.distance_to(get_global_position()) > interaction_zone_radius) return;
            set_global_position(world_position);
            _start_pos = world_position;
            _current_pos = world_position;
            _is_actuated = true;
            _report_input();
        }
    }

    void _move_towards(Vector2 world_position) {
        Vector2 direction = _start_pos.direction_to(world_position);
        double distance = _start_pos.distance_to(world_position);
        _current_pos = _start_pos + direction * Math::min(distance, max_actuation_radius);
        _report_input();
    }

    void _release() {
        _is_actuated = false;
        set_global_position(_initial_pos);
        _start_pos = get_global_position();
        _current_pos = get_global_position();
        _report_input();
    }

    void _report_input() {
        Vector2 direction(0, 0);
        if (!_start_pos.is_equal_approx(_current_pos)) {
            direction = _start_pos.direction_to(_current_pos);
        }
        double distance = _start_pos.distance_to(_current_pos);
        Vector2 offset = direction * (distance / max_actuation_radius);

        if (stick_position == POSITION_LEFT) {
            _send_event(JOY_AXIS_LEFT_X, offset.x);
            _send_event(JOY_AXIS_LEFT_Y, offset.y);
        } else {
            _send_event(JOY_AXIS_RIGHT_X, offset.x);
            _send_event(JOY_AXIS_RIGHT_Y, offset.y);
        }
        if (draw_debug) queue_redraw();
        emit_signal("changed");
    }

    void _send_event(int axis, float value) {
        Ref<InputEventJoypadMotion> event;
        event.instantiate();
        event->set_axis((JoyAxis)axis);
        event->set_axis_value(value);
        event->set_device(_virtual_joy_id);
        GUIDECPP::get_singleton()->inject_input(event);
    }

    Vector2 get_stick_relative_position() const { return _current_pos - _start_pos; }

    double get_interaction_zone_radius() const { return interaction_zone_radius; }
    void set_interaction_zone_radius(double p_radius) { interaction_zone_radius = p_radius; queue_redraw(); emit_signal("configuration_changed"); }

    double get_stick_radius() const { return stick_radius; }
    void set_stick_radius(double p_radius) { stick_radius = p_radius; queue_redraw(); emit_signal("configuration_changed"); }

    double get_max_actuation_radius() const { return max_actuation_radius; }
    void set_max_actuation_radius(double p_radius) { max_actuation_radius = p_radius; queue_redraw(); emit_signal("configuration_changed"); }

    StickPosition get_stick_position() const { return stick_position; }
    void set_stick_position(StickPosition p_pos) { stick_position = p_pos; emit_signal("configuration_changed"); }

    PositionMode get_position_mode() const { return position_mode; }
    void set_position_mode(PositionMode p_mode) { position_mode = p_mode; emit_signal("configuration_changed"); }

    Vector2 _start_pos;
    Vector2 _current_pos;

protected:
    static void _bind_methods() {
        BIND_ENUM_CONSTANT(MODE_FIXED);
        BIND_ENUM_CONSTANT(MODE_RELATIVE);

        BIND_ENUM_CONSTANT(POSITION_LEFT);
        BIND_ENUM_CONSTANT(POSITION_RIGHT);

        ClassDB::bind_method(D_METHOD("get_interaction_zone_radius"), &GUIDEVirtualStick::get_interaction_zone_radius);
        ClassDB::bind_method(D_METHOD("set_interaction_zone_radius", "radius"), &GUIDEVirtualStick::set_interaction_zone_radius);
        ADD_PROPERTY(PropertyInfo(Variant::FLOAT, "interaction_zone_radius"), "set_interaction_zone_radius", "get_interaction_zone_radius");

        ClassDB::bind_method(D_METHOD("get_stick_radius"), &GUIDEVirtualStick::get_stick_radius);
        ClassDB::bind_method(D_METHOD("set_stick_radius", "radius"), &GUIDEVirtualStick::set_stick_radius);
        ADD_PROPERTY(PropertyInfo(Variant::FLOAT, "stick_radius"), "set_stick_radius", "get_stick_radius");

        ClassDB::bind_method(D_METHOD("get_max_actuation_radius"), &GUIDEVirtualStick::get_max_actuation_radius);
        ClassDB::bind_method(D_METHOD("set_max_actuation_radius", "radius"), &GUIDEVirtualStick::set_max_actuation_radius);
        ADD_PROPERTY(PropertyInfo(Variant::FLOAT, "max_actuation_radius"), "set_max_actuation_radius", "get_max_actuation_radius");

        ClassDB::bind_method(D_METHOD("get_stick_position"), &GUIDEVirtualStick::get_stick_position);
        ClassDB::bind_method(D_METHOD("set_stick_position", "position"), &GUIDEVirtualStick::set_stick_position);
        ADD_PROPERTY(PropertyInfo(Variant::INT, "stick_position", PROPERTY_HINT_ENUM, "LEFT,RIGHT"), "set_stick_position", "get_stick_position");

        ClassDB::bind_method(D_METHOD("get_position_mode"), &GUIDEVirtualStick::get_position_mode);
        ClassDB::bind_method(D_METHOD("set_position_mode", "mode"), &GUIDEVirtualStick::set_position_mode);
        ADD_PROPERTY(PropertyInfo(Variant::INT, "position_mode", PROPERTY_HINT_ENUM, "FIXED,RELATIVE"), "set_position_mode", "get_position_mode");
    }

private:
    double interaction_zone_radius = 200.0;
    double stick_radius = 100.0;
    double max_actuation_radius = 100.0;
    StickPosition stick_position = POSITION_LEFT;
    PositionMode position_mode = MODE_FIXED;

    Vector2 _initial_pos;
    int _finger_index = -1;
};

VARIANT_ENUM_CAST(GUIDEVirtualStick::PositionMode);
VARIANT_ENUM_CAST(GUIDEVirtualStick::StickPosition);

#endif // GUIDE_VIRTUAL_STICK_H
