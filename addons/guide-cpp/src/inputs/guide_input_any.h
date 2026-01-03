#ifndef GUIDE_INPUT_ANY_H
#define GUIDE_INPUT_ANY_H

#include "guide_input.h"

using namespace godot;

class GUIDEInputAny : public GUIDEInput {
    GDCLASS(GUIDEInputAny, GUIDEInput)

public:
    GUIDEInputAny();
    virtual ~GUIDEInputAny();

    virtual bool _needs_reset() const override;
    virtual void _begin_usage() override;
    virtual void _end_usage() override;
    virtual bool is_same_as(const Ref<GUIDEInput> &other) const override;
    virtual String _editor_name() const override;
    virtual String _editor_description() const override;
    virtual GUIDEAction::GUIDEActionValueType _native_value_type() const override;
    virtual DeviceType _device_type() const override;

    void _refresh();

    // Getters and Setters
    bool get_mouse_buttons() const { return mouse_buttons; }
    void set_mouse_buttons(bool p_val) { mouse_buttons = p_val; emit_changed(); }

    bool get_mouse_movement() const { return mouse_movement; }
    void set_mouse_movement(bool p_val) { mouse_movement = p_val; emit_changed(); }

    double get_minimum_mouse_movement_distance() const { return minimum_mouse_movement_distance; }
    void set_minimum_mouse_movement_distance(double p_val) { minimum_mouse_movement_distance = p_val; emit_changed(); }

    bool get_joy_buttons() const { return joy_buttons; }
    void set_joy_buttons(bool p_val) { joy_buttons = p_val; emit_changed(); }

    bool get_joy_axes() const { return joy_axes; }
    void set_joy_axes(bool p_val) { joy_axes = p_val; emit_changed(); }

    double get_minimum_joy_axis_actuation_strength() const { return minimum_joy_axis_actuation_strength; }
    void set_minimum_joy_axis_actuation_strength(double p_val) { minimum_joy_axis_actuation_strength = p_val; emit_changed(); }

    bool get_keyboard() const { return keyboard; }
    void set_keyboard(bool p_val) { keyboard = p_val; emit_changed(); }

    bool get_touch() const { return touch; }
    void set_touch(bool p_val) { touch = p_val; emit_changed(); }

protected:
    static void _bind_methods();
    String _to_string() const;

    bool mouse_buttons = false;
    bool mouse_movement = false;
    double minimum_mouse_movement_distance = 1.0;
    bool joy_buttons = false;
    bool joy_axes = false;
    double minimum_joy_axis_actuation_strength = 0.2;
    bool keyboard = false;
    bool touch = false;
};

#endif // GUIDE_INPUT_ANY_H
