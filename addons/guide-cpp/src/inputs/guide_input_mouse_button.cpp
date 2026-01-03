#include "guide_input_mouse_button.h"
#include "guide_input_state.h"

using namespace godot;

void GUIDEInputMouseButton::_bind_methods() {
    ClassDB::bind_method(D_METHOD("get_button"), &GUIDEInputMouseButton::get_button);
    ClassDB::bind_method(D_METHOD("set_button", "button"), &GUIDEInputMouseButton::set_button);
    ADD_PROPERTY(PropertyInfo(Variant::INT, "button"), "set_button", "get_button");

    ClassDB::bind_method(D_METHOD("_refresh"), &GUIDEInputMouseButton::_refresh);
    ClassDB::bind_method(D_METHOD("_to_string"), &GUIDEInputMouseButton::_to_string);
}

GUIDEInputMouseButton::GUIDEInputMouseButton() {
}

GUIDEInputMouseButton::~GUIDEInputMouseButton() {
}

bool GUIDEInputMouseButton::_needs_reset() const {
    return button == MOUSE_BUTTON_WHEEL_UP || button == MOUSE_BUTTON_WHEEL_DOWN;
}

void GUIDEInputMouseButton::_reset() {
    _was_pressed_this_frame = false;
    _value = _reset_to;
}

void GUIDEInputMouseButton::_begin_usage() {
    if (_state) {
        _state->connect("mouse_button_state_changed", Callable(this, "_refresh"));
        _refresh();
    }
}

void GUIDEInputMouseButton::_end_usage() {
    if (_state) {
        _state->disconnect("mouse_button_state_changed", Callable(this, "_refresh"));
    }
}

void GUIDEInputMouseButton::_refresh() {
    if (_state) {
        bool is_pressed = _state->is_mouse_button_pressed(button);
        if (_needs_reset()) {
            _reset_to.x = is_pressed ? 1.0 : 0.0;
            if (is_pressed) _was_pressed_this_frame = true;
            if (!is_pressed && _was_pressed_this_frame) return;
        }
        _value.x = is_pressed ? 1.0 : 0.0;
    }
}

bool GUIDEInputMouseButton::is_same_as(const Ref<GUIDEInput> &other) const {
    Ref<GUIDEInputMouseButton> o = other;
    if (o.is_null()) return false;
    return o->button == button;
}

String GUIDEInputMouseButton::_to_string() const {
    return "(GUIDEInputMouseButton: button=" + String::num(button) + ")";
}

String GUIDEInputMouseButton::_editor_name() const {
    return "Mouse Button";
}

String GUIDEInputMouseButton::_editor_description() const {
    return "A press of a mouse button. The mouse wheel is also a button.";
}

GUIDEAction::GUIDEActionValueType GUIDEInputMouseButton::_native_value_type() const {
    return GUIDEAction::BOOL;
}

GUIDEInput::DeviceType GUIDEInputMouseButton::_device_type() const {
    return MOUSE;
}
