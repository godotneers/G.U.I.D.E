#include "guide_input.h"

using namespace godot;

void GUIDEInput::_bind_methods() {
    BIND_ENUM_CONSTANT(NONE);
    BIND_ENUM_CONSTANT(KEYBOARD);
    BIND_ENUM_CONSTANT(MOUSE);
    BIND_ENUM_CONSTANT(JOY);
    BIND_ENUM_CONSTANT(TOUCH);

    ClassDB::bind_method(D_METHOD("get_value"), &GUIDEInput::get_value);
    ClassDB::bind_method(D_METHOD("set_value", "value"), &GUIDEInput::set_value);
    ADD_PROPERTY(PropertyInfo(Variant::VECTOR3, "value"), "set_value", "get_value");

    ClassDB::bind_method(D_METHOD("is_same_as", "other"), &GUIDEInput::is_same_as);
    ClassDB::bind_method(D_METHOD("_to_string"), &GUIDEInput::_to_string);
}

GUIDEInput::GUIDEInput() {
    _value = Vector3(0, 0, 0);
}

GUIDEInput::~GUIDEInput() {
}

bool GUIDEInput::_needs_reset() const {
    return false;
}

void GUIDEInput::_reset() {
    _value = Vector3(0, 0, 0);
}

bool GUIDEInput::is_same_as(const Ref<GUIDEInput> &other) const {
    return false;
}

void GUIDEInput::_begin_usage() {
}

void GUIDEInput::_end_usage() {
}

String GUIDEInput::_editor_name() const {
    return "";
}

String GUIDEInput::_editor_description() const {
    return "";
}

GUIDEAction::GUIDEActionValueType GUIDEInput::_native_value_type() const {
    return GUIDEAction::BOOL;
}

GUIDEInput::DeviceType GUIDEInput::_device_type() const {
    return NONE;
}

String GUIDEInput::_to_string() const {
    return "(GUIDEInput)";
}