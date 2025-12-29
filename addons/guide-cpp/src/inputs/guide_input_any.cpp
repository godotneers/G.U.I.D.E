#include "guide_input_any.h"
#include "guide_input_state.h"
#include <godot_cpp/core/math.hpp>

using namespace godot;

void GUIDEInputAny::_bind_methods() {
    ClassDB::bind_method(D_METHOD("get_mouse_buttons"), &GUIDEInputAny::get_mouse_buttons);
    ClassDB::bind_method(D_METHOD("set_mouse_buttons", "val"), &GUIDEInputAny::set_mouse_buttons);
    ADD_PROPERTY(PropertyInfo(Variant::BOOL, "mouse_buttons"), "set_mouse_buttons", "get_mouse_buttons");

    ClassDB::bind_method(D_METHOD("get_mouse_movement"), &GUIDEInputAny::get_mouse_movement);
    ClassDB::bind_method(D_METHOD("set_mouse_movement", "val"), &GUIDEInputAny::set_mouse_movement);
    ADD_PROPERTY(PropertyInfo(Variant::BOOL, "mouse_movement"), "set_mouse_movement", "get_mouse_movement");

    ClassDB::bind_method(D_METHOD("get_minimum_mouse_movement_distance"), &GUIDEInputAny::get_minimum_mouse_movement_distance);
    ClassDB::bind_method(D_METHOD("set_minimum_mouse_movement_distance", "val"), &GUIDEInputAny::set_minimum_mouse_movement_distance);
    ADD_PROPERTY(PropertyInfo(Variant::FLOAT, "minimum_mouse_movement_distance"), "set_minimum_mouse_movement_distance", "get_minimum_mouse_movement_distance");

    ClassDB::bind_method(D_METHOD("get_joy_buttons"), &GUIDEInputAny::get_joy_buttons);
    ClassDB::bind_method(D_METHOD("set_joy_buttons", "val"), &GUIDEInputAny::set_joy_buttons);
    ADD_PROPERTY(PropertyInfo(Variant::BOOL, "joy_buttons"), "set_joy_buttons", "get_joy_buttons");

    ClassDB::bind_method(D_METHOD("get_joy_axes"), &GUIDEInputAny::get_joy_axes);
    ClassDB::bind_method(D_METHOD("set_joy_axes", "val"), &GUIDEInputAny::set_joy_axes);
    ADD_PROPERTY(PropertyInfo(Variant::BOOL, "joy_axes"), "set_joy_axes", "get_joy_axes");

    ClassDB::bind_method(D_METHOD("get_minimum_joy_axis_actuation_strength"), &GUIDEInputAny::get_minimum_joy_axis_actuation_strength);
    ClassDB::bind_method(D_METHOD("set_minimum_joy_axis_actuation_strength", "val"), &GUIDEInputAny::set_minimum_joy_axis_actuation_strength);
    ADD_PROPERTY(PropertyInfo(Variant::FLOAT, "minimum_joy_axis_actuation_strength"), "set_minimum_joy_axis_actuation_strength", "get_minimum_joy_axis_actuation_strength");

    ClassDB::bind_method(D_METHOD("get_keyboard"), &GUIDEInputAny::get_keyboard);
    ClassDB::bind_method(D_METHOD("set_keyboard", "val"), &GUIDEInputAny::set_keyboard);
    ADD_PROPERTY(PropertyInfo(Variant::BOOL, "keyboard"), "set_keyboard", "get_keyboard");

    ClassDB::bind_method(D_METHOD("get_touch"), &GUIDEInputAny::get_touch);
    ClassDB::bind_method(D_METHOD("set_touch", "val"), &GUIDEInputAny::set_touch);
    ADD_PROPERTY(PropertyInfo(Variant::BOOL, "touch"), "set_touch", "get_touch");

    ClassDB::bind_method(D_METHOD("_refresh"), &GUIDEInputAny::_refresh);
    ClassDB::bind_method(D_METHOD("_to_string"), &GUIDEInputAny::_to_string);
}

GUIDEInputAny::GUIDEInputAny() {
}

GUIDEInputAny::~GUIDEInputAny() {
}

bool GUIDEInputAny::_needs_reset() const {
    return true;
}

void GUIDEInputAny::_begin_usage() {
    if (_state) {
        if (mouse_movement) _state->connect("mouse_position_changed", Callable(this, "_refresh"));
        if (mouse_buttons) _state->connect("mouse_button_state_changed", Callable(this, "_refresh"));
        if (keyboard) _state->connect("keyboard_state_changed", Callable(this, "_refresh"));
        if (joy_buttons) _state->connect("joy_button_state_changed", Callable(this, "_refresh"));
        if (joy_axes) _state->connect("joy_axis_state_changed", Callable(this, "_refresh"));
        if (touch) _state->connect("touch_state_changed", Callable(this, "_refresh"));
        _refresh();
    }
}

void GUIDEInputAny::_end_usage() {
    if (_state) {
        if (mouse_movement) _state->disconnect("mouse_position_changed", Callable(this, "_refresh"));
        if (mouse_buttons) _state->disconnect("mouse_button_state_changed", Callable(this, "_refresh"));
        if (keyboard) _state->disconnect("keyboard_state_changed", Callable(this, "_refresh"));
        if (joy_buttons) _state->disconnect("joy_button_state_changed", Callable(this, "_refresh"));
        if (joy_axes) _state->disconnect("joy_axis_state_changed", Callable(this, "_refresh"));
        if (touch) _state->disconnect("touch_state_changed", Callable(this, "_refresh"));
    }
}

void GUIDEInputAny::_refresh() {
    if (!_value.is_zero_approx()) return;
    if (!_state) return;

    if (keyboard && _state->is_any_key_pressed()) {
        _value = Vector3(1, 0, 0);
        return;
    }
    if (mouse_buttons && _state->is_any_mouse_button_pressed()) {
        _value = Vector3(1, 0, 0);
        return;
    }
    if (mouse_movement && _state->get_mouse_delta_since_last_frame().length() >= minimum_mouse_movement_distance) {
        _value = Vector3(1, 0, 0);
        return;
    }
    if (joy_buttons && _state->is_any_joy_button_pressed()) {
        _value = Vector3(1, 0, 0);
        return;
    }
    if (joy_axes && _state->is_any_joy_axis_actuated(minimum_joy_axis_actuation_strength)) {
        _value = Vector3(1, 0, 0);
        return;
    }
    if (touch && _state->is_any_finger_down()) {
        _value = Vector3(1, 0, 0);
        return;
    }
    _value = Vector3(0, 0, 0);
}

bool GUIDEInputAny::is_same_as(const Ref<GUIDEInput> &other) const {
    Ref<GUIDEInputAny> o = other;
    if (o.is_null()) return false;
    return o->mouse_buttons == mouse_buttons && 
           o->mouse_movement == mouse_movement &&
           o->joy_buttons == joy_buttons && 
           o->joy_axes == joy_axes &&
           o->keyboard == keyboard && 
           o->touch == touch &&
           Math::abs(o->minimum_mouse_movement_distance - minimum_mouse_movement_distance) < 0.00001 &&
           Math::abs(o->minimum_joy_axis_actuation_strength - minimum_joy_axis_actuation_strength) < 0.00001;
}

String GUIDEInputAny::_editor_name() const {
    return "Any Input";
}

String GUIDEInputAny::_editor_description() const {
    return "Input that triggers if any input from the given device class is given.";
}

GUIDEAction::GUIDEActionValueType GUIDEInputAny::_native_value_type() const {
    return GUIDEAction::GUIDEActionValueType::BOOL;
}

GUIDEInput::DeviceType GUIDEInputAny::_device_type() const {
    int res = NONE;
    if (joy_axes || joy_buttons) res |= JOY;
    if (mouse_buttons || mouse_movement) res |= MOUSE;
    if (keyboard) res |= KEYBOARD;
    if (touch) res |= TOUCH;
    return (DeviceType)res;
}
