#include "guide_input_state.h"
#include <godot_cpp/classes/input.hpp>
#include <godot_cpp/classes/engine.hpp>
#include <godot_cpp/classes/scene_tree.hpp>
#include <godot_cpp/classes/window.hpp>
#include <godot_cpp/core/math.hpp>
#include <cmath>

using namespace godot;

void GUIDEInputState::_bind_methods() {
    ADD_SIGNAL(MethodInfo("keyboard_state_changed"));
    ADD_SIGNAL(MethodInfo("mouse_position_changed"));
    ADD_SIGNAL(MethodInfo("mouse_button_state_changed"));
    ADD_SIGNAL(MethodInfo("joy_button_state_changed"));
    ADD_SIGNAL(MethodInfo("joy_axis_state_changed"));
    ADD_SIGNAL(MethodInfo("touch_state_changed"));
}

GUIDEInputState::GUIDEInputState() {
    Input::get_singleton()->connect("joy_connection_changed", Callable(this, "_refresh_joy_device_ids"));
    _clear();
}

GUIDEInputState::~GUIDEInputState() {
}

int GUIDEInputState::connect_virtual_stick(int stick_index) {
    if (stick_index < 0) {
        stick_index = 0;
    }
    int device_id = VIRTUAL_JOY_DEVICE_ID_OFFSET - stick_index;
    if (_virtual_joy_devices.has(device_id)) {
        _virtual_joy_devices[device_id] = (int)_virtual_joy_devices[device_id] + 1;
        return device_id;
    }
    _virtual_joy_devices[device_id] = 1;
    _refresh_joy_device_ids(0, false);
    return device_id;
}

void GUIDEInputState::disconnect_virtual_stick(int device_id) {
    if (!_virtual_joy_devices.has(device_id)) {
        return;
    }
    int count = _virtual_joy_devices[device_id];
    if (count > 1) {
        _virtual_joy_devices[device_id] = count - 1;
        return;
    }
    _virtual_joy_devices.erase(device_id);
    _joy_index_to_device_id.erase(device_id);
    if (_joy_buttons.has(device_id)) {
        _joy_buttons.erase(device_id);
        emit_signal("joy_button_state_changed");
    }
    if (_joy_axes.has(device_id)) {
        _joy_axes.erase(device_id);
        emit_signal("joy_axis_state_changed");
    }
}

void GUIDEInputState::_clear() {
    _keys.clear();
    _finger_positions.clear();
    _mouse_movement = Vector2(0, 0);
    _mouse_buttons.clear();
    _joy_buttons.clear();
    _joy_axes.clear();
    _refresh_joy_device_ids(0, false);
    _joy_buttons[ANY_JOY_DEVICE_ID] = Dictionary();
    _joy_axes[ANY_JOY_DEVICE_ID] = Dictionary();
    Array virtual_keys = _virtual_joy_devices.keys();
    for (int i = 0; i < virtual_keys.size(); i++) {
        _joy_index_to_device_id.erase(virtual_keys[i]);
    }
    _virtual_joy_devices.clear();
}

void GUIDEInputState::_refresh_joy_device_ids(int p_id, bool p_connected) {
    _joy_index_to_device_id.clear();
    Array connected_joys = Input::get_singleton()->get_connected_joypads();
    Array virtual_keys = _virtual_joy_devices.keys();
    for (int i = 0; i < virtual_keys.size(); i++) {
        connected_joys.append(virtual_keys[i]);
    }

    for (int i = 0; i < connected_joys.size(); i++) {
        int device_id = connected_joys[i];
        if (device_id >= 0) {
            _joy_index_to_device_id[i] = device_id;
        } else {
            _joy_index_to_device_id[device_id] = device_id;
        }
        if (!_joy_buttons.has(device_id)) {
            _joy_buttons[device_id] = Dictionary();
        }
        if (!_joy_axes.has(device_id)) {
            _joy_axes[device_id] = Dictionary();
        }
        if (!_pending_joy_buttons.has(device_id)) {
            _pending_joy_buttons[device_id] = Dictionary();
        }
    }
    _joy_index_to_device_id[-1] = ANY_JOY_DEVICE_ID;

    Array pending_joy_keys = _pending_joy_buttons.keys();
    for (int i = 0; i < pending_joy_keys.size(); i++) {
        int device_id = pending_joy_keys[i];
        if (device_id != ANY_JOY_DEVICE_ID && !connected_joys.has(device_id)) {
            _pending_joy_buttons.erase(device_id);
        }
    }

    bool dirty = false;
    Array joy_button_keys = _joy_buttons.keys();
    for (int i = 0; i < joy_button_keys.size(); i++) {
        int device_id = joy_button_keys[i];
        if (device_id != ANY_JOY_DEVICE_ID && !connected_joys.has(device_id)) {
            dirty = true;
            _joy_buttons.erase(device_id);
        }
    }
    if (dirty) {
        emit_signal("joy_button_state_changed");
    }

    dirty = false;
    Array joy_axis_keys = _joy_axes.keys();
    for (int i = 0; i < joy_axis_keys.size(); i++) {
        int device_id = joy_axis_keys[i];
        if (device_id != ANY_JOY_DEVICE_ID && !connected_joys.has(device_id)) {
            dirty = true;
            _joy_axes.erase(device_id);
        }
    }
    if (dirty) {
        emit_signal("joy_axis_state_changed");
    }
}

void GUIDEInputState::_reset() {
    _mouse_movement = Vector2(0, 0);
    Array pending_key_list = _pending_keys.keys();
    for (int i = 0; i < pending_key_list.size(); i++) {
        int key = pending_key_list[i];
        bool is_down = _pending_keys[key];
        if (is_down && !_keys.has(key)) {
            _keys[key] = true;
            emit_signal("keyboard_state_changed");
        } else if (!is_down && _keys.has(key)) {
            _keys.erase(key);
            emit_signal("keyboard_state_changed");
        }
    }
    _pending_keys.clear();

    Array pending_mouse_list = _pending_mouse_buttons.keys();
    for (int i = 0; i < pending_mouse_list.size(); i++) {
        int button = pending_mouse_list[i];
        bool is_down = _pending_mouse_buttons[button];
        if (is_down && !_mouse_buttons.has(button)) {
            _mouse_buttons[button] = true;
            emit_signal("mouse_button_state_changed");
        } else if (!is_down && _mouse_buttons.has(button)) {
            _mouse_buttons.erase(button);
            emit_signal("mouse_button_state_changed");
        }
    }
    _pending_mouse_buttons.clear();

    Array pending_joy_list = _pending_joy_buttons.keys();
    for (int i = 0; i < pending_joy_list.size(); i++) {
        int joy = pending_joy_list[i];
        Dictionary buttons = _pending_joy_buttons[joy];
        Array button_keys = buttons.keys();
        for (int j = 0; j < button_keys.size(); j++) {
            int button = button_keys[j];
            bool changed = false;
            bool is_down = buttons[button];
            Dictionary joy_btns = _joy_buttons[joy];
            if (is_down && !joy_btns.has(button)) {
                joy_btns[button] = true;
                changed = true;
            } else if (!is_down && joy_btns.has(button)) {
                joy_btns.erase(button);
                changed = true;
            }
            if (changed) {
                bool any_value = false;
                Array all_joy_ids = _joy_buttons.keys();
                for (int k = 0; k < all_joy_ids.size(); k++) {
                    int inner_id = all_joy_ids[k];
                    if (inner_id != ANY_JOY_DEVICE_ID && ((Dictionary)_joy_buttons[inner_id]).has(button)) {
                        any_value = true;
                        break;
                    }
                }
                Dictionary any_joy_btns = _joy_buttons[ANY_JOY_DEVICE_ID];
                if (any_value) {
                    any_joy_btns[button] = true;
                } else {
                    any_joy_btns.erase(button);
                }
                emit_signal("joy_button_state_changed");
            }
        }
        ((Dictionary)_pending_joy_buttons[joy]).clear();
    }
}

void GUIDEInputState::_input(const Ref<InputEvent> &event) {
    Ref<InputEventKey> k = event;
    if (k.is_valid()) {
        int index = k->get_physical_keycode();
        if (_pending_keys.has(index)) {
            _pending_keys[index] = k->is_pressed();
            return;
        }
        _pending_keys[index] = k->is_pressed();
        if (k->is_pressed() && !_keys.has(index)) {
            _keys[index] = true;
            emit_signal("keyboard_state_changed");
        } else if (!k->is_pressed() && _keys.has(index)) {
            _keys.erase(index);
            emit_signal("keyboard_state_changed");
        }
        return;
    }

    Ref<InputEventMouseMotion> mm = event;
    if (mm.is_valid()) {
        _mouse_movement += mm->get_relative();
        emit_signal("mouse_position_changed");
        return;
    }

    Ref<InputEventMouseButton> mb = event;
    if (mb.is_valid()) {
        int index = mb->get_button_index();
        if (_pending_mouse_buttons.has(index)) {
            _pending_mouse_buttons[index] = mb->is_pressed();
            return;
        }
        _pending_mouse_buttons[index] = mb->is_pressed();
        if (mb->is_pressed() && !_mouse_buttons.has(index)) {
            _mouse_buttons[index] = true;
            emit_signal("mouse_button_state_changed");
        } else if (!mb->is_pressed() && _mouse_buttons.has(index)) {
            _mouse_buttons.erase(index);
            emit_signal("mouse_button_state_changed");
        }
        return;
    }

    Ref<InputEventJoypadButton> jb = event;
    if (jb.is_valid()) {
        int device_id = jb->get_device();
        int button = jb->get_button_index();
        Dictionary pending_btns = _pending_joy_buttons[device_id];
        if (pending_btns.has(button)) {
            pending_btns[button] = jb->is_pressed();
            return;
        }
        pending_btns[button] = jb->is_pressed();
        bool changed = false;
        Dictionary joy_btns = _joy_buttons[device_id];
        if (jb->is_pressed() && !joy_btns.has(button)) {
            joy_btns[button] = true;
            changed = true;
        } else if (!jb->is_pressed() && joy_btns.has(button)) {
            joy_btns.erase(button);
            changed = true;
        }
        
        if (changed) {
            bool any_value = false;
            Array all_joy_ids = _joy_buttons.keys();
            for (int i = 0; i < all_joy_ids.size(); i++) {
                int inner_id = all_joy_ids[i];
                if (inner_id != ANY_JOY_DEVICE_ID && ((Dictionary)_joy_buttons[inner_id]).has(button)) {
                    any_value = true;
                    break;
                }
            }
            Dictionary any_joy_btns = _joy_buttons[ANY_JOY_DEVICE_ID];
            if (any_value) {
                any_joy_btns[button] = true;
            } else {
                any_joy_btns.erase(button);
            }
            emit_signal("joy_button_state_changed");
        }
        return;
    }

    Ref<InputEventJoypadMotion> jm = event;
    if (jm.is_valid()) {
        int device_id = jm->get_device();
        int axis = jm->get_axis();
        ((Dictionary)_joy_axes[device_id])[axis] = jm->get_axis_value();
        float any_value = 0.0;
        float max_actuation = 0.0;
        Array all_joy_ids = _joy_axes.keys();
        for (int i = 0; i < all_joy_ids.size(); i++) {
            int inner_id = all_joy_ids[i];
            if (inner_id != ANY_JOY_DEVICE_ID) {
                Dictionary inner_axes = _joy_axes[inner_id];
                if (inner_axes.has(axis)) {
                    float val = inner_axes[axis];
                    float strength = Math::abs(val);
                    if (strength > max_actuation) {
                        max_actuation = strength;
                        any_value = val;
                    }
                }
            }
        }
        ((Dictionary)_joy_axes[ANY_JOY_DEVICE_ID])[axis] = any_value;
        emit_signal("joy_axis_state_changed");
        return;
    }

    Ref<InputEventScreenTouch> st = event;
    if (st.is_valid()) {
        if (st->is_pressed()) {
            _finger_positions[st->get_index()] = st->get_position();
        } else {
            _finger_positions.erase(st->get_index());
        }
        emit_signal("touch_state_changed");
        return;
    }

    Ref<InputEventScreenDrag> sd = event;
    if (sd.is_valid()) {
        _finger_positions[sd->get_index()] = sd->get_position();
        emit_signal("touch_state_changed");
        return;
    }
}

bool GUIDEInputState::is_key_pressed(Key key) const {
    return _keys.has(key);
}

bool GUIDEInputState::is_at_least_one_key_pressed(const TypedArray<int> &keys) const {
    for (int i = 0; i < keys.size(); i++) {
        if (_keys.has(keys[i])) {
            return true;
        }
    }
    return false;
}

bool GUIDEInputState::are_all_keys_pressed(const TypedArray<int> &keys) const {
    for (int i = 0; i < keys.size(); i++) {
        if (!_keys.has(keys[i])) {
            return false;
        }
    }
    return true;
}

bool GUIDEInputState::is_any_key_pressed() const {
    return !_keys.is_empty();
}

Vector2 GUIDEInputState::get_mouse_delta_since_last_frame() const {
    return _mouse_movement;
}

Vector2 GUIDEInputState::get_mouse_position() const {
    return SceneTree::get_singleton()->get_root()->get_mouse_position();
}

bool GUIDEInputState::is_mouse_button_pressed(MouseButton button_index) const {
    return _mouse_buttons.has(button_index);
}

bool GUIDEInputState::is_any_mouse_button_pressed() const {
    return !_mouse_buttons.is_empty();
}

float GUIDEInputState::get_joy_axis_value(int index, JoyAxis axis) const {
    int device_id = _joy_index_to_device_id.get(index, -9999);
    if (device_id == -9999) return 0.0;
    if (_joy_axes.has(device_id)) {
        Dictionary inner = _joy_axes[device_id];
        return inner.get(axis, 0.0);
    }
    return 0.0;
}

bool GUIDEInputState::is_joy_button_pressed(int index, JoyButton button) const {
    int device_id = _joy_index_to_device_id.get(index, -9999);
    if (device_id == -9999) return false;
    if (_joy_buttons.has(device_id)) {
        return ((Dictionary)_joy_buttons[device_id]).has(button);
    }
    return false;
}

bool GUIDEInputState::is_any_joy_button_pressed() const {
    Array vals = _joy_buttons.values();
    for (int i = 0; i < vals.size(); i++) {
        if (!((Dictionary)vals[i]).is_empty()) return true;
    }
    return false;
}

bool GUIDEInputState::is_any_joy_axis_actuated(float minimum_strength) const {
    Array vals = _joy_axes.values();
    for (int i = 0; i < vals.size(); i++) {
        Dictionary inner = vals[i];
        Array inner_vals = inner.values();
        for (int j = 0; j < inner_vals.size(); j++) {
            if (Math::abs((float)inner_vals[j]) >= minimum_strength) return true;
        }
    }
    return false;
}

Vector2 GUIDEInputState::get_finger_position(int finger_index, int finger_count) const {
    if (_finger_positions.is_empty()) return Vector2(NAN, NAN);
    if (_finger_positions.size() != finger_count) return Vector2(NAN, NAN);
    if (finger_index > -1) {
        return _finger_positions.get(finger_index, Vector2(NAN, NAN));
    }
    Vector2 result = Vector2(0, 0);
    Array vals = _finger_positions.values();
    for (int i = 0; i < vals.size(); i++) {
        result += (Vector2)vals[i];
    }
    result /= (float)finger_count;
    return result;
}

TypedArray<Vector2> GUIDEInputState::get_finger_positions() const {
    TypedArray<Vector2> result;
    Array vals = _finger_positions.values();
    for (int i = 0; i < vals.size(); i++) {
        result.append(vals[i]);
    }
    return result;
}

bool GUIDEInputState::is_any_finger_down() const {
    return !_finger_positions.is_empty();
}
