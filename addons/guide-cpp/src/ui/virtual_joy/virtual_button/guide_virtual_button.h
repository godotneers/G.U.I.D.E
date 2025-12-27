#ifndef GUIDE_VIRTUAL_BUTTON_H
#define GUIDE_VIRTUAL_BUTTON_H

#include "../guide_virtual_joy_base.h"
#include <godot_cpp/classes/input_event_mouse_motion.hpp>

using namespace godot;

class GUIDEVirtualButton : public GUIDEVirtualJoyBase {
    GDCLASS(GUIDEVirtualButton, GUIDEVirtualJoyBase)

public:
    GUIDEVirtualButton();
    virtual ~GUIDEVirtualButton();

    void _ready() override;
    void _draw() override;

    virtual void _handle_mouse_input(const Ref<InputEventMouse> &event) override;
    virtual void _handle_touch_input(const Ref<InputEvent> &event) override;

    bool _is_over_button(Vector2 world_position) const;
    void _try_actuate(Vector2 world_position);
    void _release();
    void _report_input();

    double get_button_radius() const { return button_radius; }
    void set_button_radius(double p_radius) { button_radius = p_radius; queue_redraw(); emit_signal("configuration_changed"); }

    int get_button_index() const { return (int)button_index; }
    void set_button_index(int p_index) { button_index = (JoyButton)p_index; emit_signal("configuration_changed"); }

protected:
    static void _bind_methods();

private:
    double button_radius = 100.0;
    JoyButton button_index = JOY_BUTTON_A;
    Dictionary _finger_positions;
    bool _mouse_down_consumed = false;
};

#endif // GUIDE_VIRTUAL_BUTTON_H