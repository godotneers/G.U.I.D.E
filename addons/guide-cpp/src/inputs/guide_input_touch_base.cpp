#include "guide_input_touch_base.h"

using namespace godot;

void GUIDEInputTouchBase::_bind_methods() {
    ClassDB::bind_method(D_METHOD("get_finger_count"), &GUIDEInputTouchBase::get_finger_count);
    ClassDB::bind_method(D_METHOD("set_finger_count", "count"), &GUIDEInputTouchBase::set_finger_count);
    ADD_PROPERTY(PropertyInfo(Variant::INT, "finger_count"), "set_finger_count", "get_finger_count");

    ClassDB::bind_method(D_METHOD("get_finger_index"), &GUIDEInputTouchBase::get_finger_index);
    ClassDB::bind_method(D_METHOD("set_finger_index", "index"), &GUIDEInputTouchBase::set_finger_index);
    ADD_PROPERTY(PropertyInfo(Variant::INT, "finger_index"), "set_finger_index", "get_finger_index");
}

GUIDEInputTouchBase::GUIDEInputTouchBase() {}
GUIDEInputTouchBase::~GUIDEInputTouchBase() {}