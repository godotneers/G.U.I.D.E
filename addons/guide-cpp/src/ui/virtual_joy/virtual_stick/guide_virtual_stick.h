#ifndef GUIDE_VIRTUAL_STICK_H
#define GUIDE_VIRTUAL_STICK_H

#include "guide_virtual_joy_base.h"
#include <godot_cpp/classes/input_event_mouse_motion.hpp>

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

    GUIDEVirtualStick();
    virtual ~GUIDEVirtualStick();

    void _ready() override;
    void _draw() override;

    virtual void _handle_mouse_input(const Ref<InputEventMouse> &event) override;
    virtual void _handle_touch_input(const Ref<InputEvent> &event) override;

    void _try_actuate(Vector2 world_position);
    void _move_towards(Vector2 world_position);
    void _release();
    void _report_input();
    void _send_event(int axis, float value);

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
    static void _bind_methods();

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