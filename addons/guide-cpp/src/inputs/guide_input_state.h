#ifndef GUIDE_INPUT_STATE_H
#define GUIDE_INPUT_STATE_H

#include <godot_cpp/core/class_db.hpp>
#include <godot_cpp/variant/dictionary.hpp>
#include <godot_cpp/variant/vector2.hpp>
#include <godot_cpp/classes/input_event.hpp>
#include <godot_cpp/classes/input_event_key.hpp>
#include <godot_cpp/classes/input_event_mouse_motion.hpp>
#include <godot_cpp/classes/input_event_mouse_button.hpp>
#include <godot_cpp/classes/input_event_joypad_button.hpp>
#include <godot_cpp/classes/input_event_joypad_motion.hpp>
#include <godot_cpp/classes/input_event_screen_touch.hpp>
#include <godot_cpp/classes/input_event_screen_drag.hpp>
#include <limits>

using namespace godot;

class GUIDEInputState : public Object {
    GDCLASS(GUIDEInputState, Object)

public:
    static const int ANY_JOY_DEVICE_ID = -1;
    static const int VIRTUAL_JOY_DEVICE_ID_OFFSET = -2;

    GUIDEInputState();
    virtual ~GUIDEInputState();

    int connect_virtual_stick(int stick_index);
    void disconnect_virtual_stick(int device_id);

    void _clear();
    void _refresh_joy_device_ids(int p_id, bool p_connected);
    void _reset();
    void _input(const Ref<InputEvent> &event);

    bool is_key_pressed(Key key) const;
    bool is_at_least_one_key_pressed(const TypedArray<int> &keys) const;
    bool are_all_keys_pressed(const TypedArray<int> &keys) const;
    bool is_any_key_pressed() const;

    Vector2 get_mouse_delta_since_last_frame() const;
    Vector2 get_mouse_position() const;
    bool is_mouse_button_pressed(MouseButton button_index) const;
    bool is_any_mouse_button_pressed() const;

    float get_joy_axis_value(int index, JoyAxis axis) const;
    bool is_joy_button_pressed(int index, JoyButton button) const;
    bool is_any_joy_button_pressed() const;
    bool is_any_joy_axis_actuated(float minimum_strength) const;

    Vector2 get_finger_position(int finger_index, int finger_count) const;
    TypedArray<Vector2> get_finger_positions() const;
    bool is_any_finger_down() const;

protected:
    static void _bind_methods();

private:
    float INF = std::numeric_limits<float>::infinity();
    Dictionary _virtual_joy_devices;
    Dictionary _keys;
    Dictionary _finger_positions;
    Vector2 _mouse_movement;
    Dictionary _mouse_buttons;
    Dictionary _joy_buttons;
    Dictionary _joy_axes;
    Dictionary _joy_index_to_device_id;

    Dictionary _pending_keys;
    Dictionary _pending_mouse_buttons;
    Dictionary _pending_joy_buttons;
};

#endif // GUIDE_INPUT_STATE_H