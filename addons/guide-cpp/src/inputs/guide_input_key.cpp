#include "guide_input_key.h"
#include "guide_input_state.h"

using namespace godot;

void GUIDEInputKey::_bind_methods() {
    ClassDB::bind_method(D_METHOD("get_key"), &GUIDEInputKey::get_key);
    ClassDB::bind_method(D_METHOD("set_key", "key"), &GUIDEInputKey::set_key);
    ADD_PROPERTY(PropertyInfo(Variant::INT, "key"), "set_key", "get_key");

    ClassDB::bind_method(D_METHOD("get_shift"), &GUIDEInputKey::get_shift);
    ClassDB::bind_method(D_METHOD("set_shift", "shift"), &GUIDEInputKey::set_shift);
    ADD_PROPERTY(PropertyInfo(Variant::BOOL, "shift"), "set_shift", "get_shift");

    ClassDB::bind_method(D_METHOD("get_control"), &GUIDEInputKey::get_control);
    ClassDB::bind_method(D_METHOD("set_control", "control"), &GUIDEInputKey::set_control);
    ADD_PROPERTY(PropertyInfo(Variant::BOOL, "control"), "set_control", "get_control");

    ClassDB::bind_method(D_METHOD("get_alt"), &GUIDEInputKey::get_alt);
    ClassDB::bind_method(D_METHOD("set_alt", "alt"), &GUIDEInputKey::set_alt);
    ADD_PROPERTY(PropertyInfo(Variant::BOOL, "alt"), "set_alt", "get_alt");

    ClassDB::bind_method(D_METHOD("get_meta"), &GUIDEInputKey::get_meta);
    ClassDB::bind_method(D_METHOD("set_meta", "meta"), &GUIDEInputKey::set_meta);
    ADD_PROPERTY(PropertyInfo(Variant::BOOL, "meta"), "set_meta", "get_meta");

    ClassDB::bind_method(D_METHOD("get_allow_additional_modifiers"), &GUIDEInputKey::get_allow_additional_modifiers);
    ClassDB::bind_method(D_METHOD("set_allow_additional_modifiers", "allow"), &GUIDEInputKey::set_allow_additional_modifiers);
    ADD_PROPERTY(PropertyInfo(Variant::BOOL, "allow_additional_modifiers"), "set_allow_additional_modifiers", "get_allow_additional_modifiers");

    ClassDB::bind_method(D_METHOD("_refresh"), &GUIDEInputKey::_refresh);
    ClassDB::bind_method(D_METHOD("_to_string"), &GUIDEInputKey::_to_string);
}

GUIDEInputKey::GUIDEInputKey() {
}

GUIDEInputKey::~GUIDEInputKey() {
}

void GUIDEInputKey::_begin_usage() {
    _must_be_pressed.clear();
    _must_be_pressed.append(key);
    if (shift) _must_be_pressed.append(KEY_SHIFT);
    if (control) _must_be_pressed.append(KEY_CTRL);
    if (alt) _must_be_pressed.append(KEY_ALT);
    if (meta) _must_be_pressed.append(KEY_META);

    _must_not_be_pressed.clear();
    if (!allow_additional_modifiers) {
        if (!shift && key != KEY_SHIFT) _must_not_be_pressed.append(KEY_SHIFT);
        if (!control && key != KEY_CTRL) _must_not_be_pressed.append(KEY_CTRL);
        if (!alt && key != KEY_ALT) _must_not_be_pressed.append(KEY_ALT);
        if (!meta && key != KEY_META) _must_not_be_pressed.append(KEY_META);
    }

    if (_state) {
        _state->connect("keyboard_state_changed", Callable(this, "_refresh"));
        _refresh();
    }
}

void GUIDEInputKey::_end_usage() {
    if (_state) {
        _state->disconnect("keyboard_state_changed", Callable(this, "_refresh"));
    }
}

void GUIDEInputKey::_refresh() {
    if (_state) {
        bool is_actuated = _state->are_all_keys_pressed(_must_be_pressed) && !_state->is_at_least_one_key_pressed(_must_not_be_pressed);
        _value.x = is_actuated ? 1.0 : 0.0;
    }
}

bool GUIDEInputKey::is_same_as(const Ref<GUIDEInput> &other) const {
    Ref<GUIDEInputKey> o = other;
    if (o.is_null()) return false;
    return o->key == key && 
           o->shift == shift && 
           o->control == control && 
           o->alt == alt && 
           o->meta == meta && 
           o->allow_additional_modifiers == allow_additional_modifiers;
}

String GUIDEInputKey::_to_string() const {
    return "(GUIDEInputKey: key=" + String::num(key) + ", shift=" + (shift ? String("true") : String("false")) + ", alt=" + (alt ? String("true") : String("false")) + ", control=" + (control ? String("true") : String("false")) + ", meta=" + (meta ? String("true") : String("false")) + ")";
}

String GUIDEInputKey::_editor_name() const {
    return "Key";
}

String GUIDEInputKey::_editor_description() const {
    return "A button press on the keyboard.";
}

GUIDEAction::GUIDEActionValueType GUIDEInputKey::_native_value_type() const {
    return GUIDEAction::BOOL;
}

GUIDEInput::DeviceType GUIDEInputKey::_device_type() const {
    return KEYBOARD;
}
