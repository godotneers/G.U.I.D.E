#include "guide_input.h"

using namespace godot;

void GUIDEInput::_bind_methods() {
    BIND_ENUM_CONSTANT(DEVICE_NONE);
    BIND_ENUM_CONSTANT(DEVICE_KEYBOARD);
    BIND_ENUM_CONSTANT(DEVICE_MOUSE);
    BIND_ENUM_CONSTANT(DEVICE_JOY);
    BIND_ENUM_CONSTANT(DEVICE_TOUCH);
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

int GUIDEInput::_native_value_type() const {
    return -1;
}

GUIDEInput::DeviceType GUIDEInput::_device_type() const {
    return DEVICE_NONE;
}