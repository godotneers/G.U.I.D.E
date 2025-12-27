#ifndef GUIDE_VIRTUAL_JOY_BASE_H
#define GUIDE_VIRTUAL_JOY_BASE_H

#include <godot_cpp/classes/center_container.hpp>
#include <godot_cpp/classes/input_event_mouse.hpp>
#include <godot_cpp/core/class_db.hpp>

using namespace godot;

class GUIDEVirtualJoyBase : public CenterContainer {
    GDCLASS(GUIDEVirtualJoyBase, CenterContainer)

public:
    enum InputMode {
        MODE_TOUCH,
        MODE_MOUSE,
        MODE_MOUSE_AND_TOUCH
    };

    GUIDEVirtualJoyBase();
    virtual ~GUIDEVirtualJoyBase();

    void _input(const Ref<InputEvent> &event) override;
    virtual void _handle_mouse_input(const Ref<InputEventMouse> &event);
    virtual void _handle_touch_input(const Ref<InputEvent> &event);

    Vector2 _screen_to_world(Vector2 input) const;
    void _reconnect();

    int get_virtual_device() const { return virtual_device; }
    void set_virtual_device(int p_device) { virtual_device = p_device; _reconnect(); emit_signal("configuration_changed"); }

    InputMode get_input_mode() const { return input_mode; }
    void set_input_mode(InputMode p_mode) { input_mode = p_mode; emit_signal("configuration_changed"); }

    bool get_draw_debug() const { return draw_debug; }
    void set_draw_debug(bool p_draw) { draw_debug = p_draw; queue_redraw(); emit_signal("configuration_changed"); }

protected:
    static void _bind_methods();

    int virtual_device = 0;
    InputMode input_mode = MODE_TOUCH;
    bool draw_debug = false;
    bool _is_actuated = false;
    int _virtual_joy_id = 0;
};

VARIANT_ENUM_CAST(GUIDEVirtualJoyBase::InputMode);

#endif // GUIDE_VIRTUAL_JOY_BASE_H