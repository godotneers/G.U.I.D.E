#include "guide_input_joy_base.h"

using namespace godot;

void GUIDEInputJoyBase::_bind_methods() {
    ClassDB::bind_method(D_METHOD("get_joy_index"), &GUIDEInputJoyBase::get_joy_index);
    ClassDB::bind_method(D_METHOD("set_joy_index", "index"), &GUIDEInputJoyBase::set_joy_index);
    ADD_PROPERTY(PropertyInfo(Variant::INT, "joy_index", PROPERTY_HINT_ENUM, "Any:-1,1:0,2:1,3:2,4:3,Virtual 1:-2,Virtual 2:-3,Virtual 3:-4,Virtual 4:-5"), "set_joy_index", "get_joy_index");
}

GUIDEInputJoyBase::GUIDEInputJoyBase() {
}

GUIDEInputJoyBase::~GUIDEInputJoyBase() {
}

GUIDEInput::DeviceType GUIDEInputJoyBase::_device_type() const {
    return JOY;
}