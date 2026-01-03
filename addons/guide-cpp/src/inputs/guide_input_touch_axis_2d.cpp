#include "guide_input_touch_axis_2d.h"

using namespace godot;

void GUIDEInputTouchAxis2D::_bind_methods() {
    ClassDB::bind_method(D_METHOD("_to_string"), &GUIDEInputTouchAxis2D::_to_string);
}

void GUIDEInputTouchAxis2D::_apply_value(Vector2 value) {
    _value = Vector3(value.x, value.y, 0);
}

bool GUIDEInputTouchAxis2D::is_same_as(const Ref<GUIDEInput> &other) const {
    Ref<GUIDEInputTouchAxis2D> o = other;
    if (o.is_null()) return false;
    return o->get_finger_count() == finger_count && 
           o->get_finger_index() == finger_index;
}

String GUIDEInputTouchAxis2D::_to_string() const {
    return "(GUIDEInputTouchAxis2D finger_count=" + String::num(finger_count) + 
           " finger_index=" + String::num(finger_index) + ")";
}

String GUIDEInputTouchAxis2D::_editor_name() const {
    return "Touch Axis2D";
}

String GUIDEInputTouchAxis2D::_editor_description() const {
    return "2D relative movement of a touching finger.";
}

GUIDEAction::GUIDEActionValueType GUIDEInputTouchAxis2D::_native_value_type() const {
    return GUIDEAction::AXIS_2D;
}