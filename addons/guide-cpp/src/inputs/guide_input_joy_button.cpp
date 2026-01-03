#include "guide_input_joy_button.h"
#include "guide_input_state.h"

using namespace godot;

void GUIDEInputJoyButton::_bind_methods() {
    ClassDB::bind_method(D_METHOD("get_button"), &GUIDEInputJoyButton::get_button);
    ClassDB::bind_method(D_METHOD("set_button", "button"), &GUIDEInputJoyButton::set_button);
    ADD_PROPERTY(PropertyInfo(Variant::INT, "button"), "set_button", "get_button");

    ClassDB::bind_method(D_METHOD("_refresh"), &GUIDEInputJoyButton::_refresh);
    ClassDB::bind_method(D_METHOD("_to_string"), &GUIDEInputJoyButton::_to_string);
}

GUIDEInputJoyButton::GUIDEInputJoyButton() {
}

GUIDEInputJoyButton::~GUIDEInputJoyButton() {
}

void GUIDEInputJoyButton::_begin_usage() {
    if (_state) {
        _state->connect("joy_button_state_changed", Callable(this, "_refresh"));
        _refresh();
    }
}

void GUIDEInputJoyButton::_end_usage() {
    if (_state) {
        _state->disconnect("joy_button_state_changed", Callable(this, "_refresh"));
    }
}

void GUIDEInputJoyButton::_refresh() {
    if (_state) {
        _value.x = _state->is_joy_button_pressed(joy_index, (JoyButton)button) ? 1.0 : 0.0;
    }
}

bool GUIDEInputJoyButton::is_same_as(const Ref<GUIDEInput> &other) const {
    Ref<GUIDEInputJoyButton> o = other;
    if (o.is_null()) return false;
    return o->button == button && o->joy_index == joy_index;
}

String GUIDEInputJoyButton::_to_string() const {
    return "(GUIDEInputJoyButton: button=" + String::num(button) + ", joy_index=" + String::num(joy_index) + ")";
}

String GUIDEInputJoyButton::_editor_name() const {
    return "Joy Button";
}

String GUIDEInputJoyButton::_editor_description() const {
    return "A button press from a joy button.";
}

GUIDEAction::GUIDEActionValueType GUIDEInputJoyButton::_native_value_type() const {
    return GUIDEAction::BOOL;
}
