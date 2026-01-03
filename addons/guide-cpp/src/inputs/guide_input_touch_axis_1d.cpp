#include "guide_input_touch_axis_1d.h"

using namespace godot;

void GUIDEInputTouchAxis1D::_bind_methods() {
    BIND_ENUM_CONSTANT(AXIS_X);
    BIND_ENUM_CONSTANT(AXIS_Y);

    ClassDB::bind_method(D_METHOD("get_axis"), &GUIDEInputTouchAxis1D::get_axis);
    ClassDB::bind_method(D_METHOD("set_axis", "axis"), &GUIDEInputTouchAxis1D::set_axis);
    ADD_PROPERTY(PropertyInfo(Variant::INT, "axis", PROPERTY_HINT_ENUM, "X,Y"), "set_axis", "get_axis");

    ClassDB::bind_method(D_METHOD("_to_string"), &GUIDEInputTouchAxis1D::_to_string);
}

GUIDEInputTouchAxis1D::GUIDEInputTouchAxis1D() {}
GUIDEInputTouchAxis1D::~GUIDEInputTouchAxis1D() {}

void GUIDEInputTouchAxis1D::_apply_value(Vector2 value) {
    if (axis == AXIS_X) {
        _value = Vector3(value.x, 0, 0);
    } else {
        _value = Vector3(value.y, 0, 0);
    }
}

bool GUIDEInputTouchAxis1D::is_same_as(const Ref<GUIDEInput> &other) const {
    Ref<GUIDEInputTouchAxis1D> o = other;
    if (o.is_null()) return false;
    return o->get_finger_count() == finger_count && 
           o->get_finger_index() == finger_index && 
           o->axis == axis;
}

String GUIDEInputTouchAxis1D::_to_string() const {
    return "(GUIDEInputTouchAxis1D finger_count=" + String::num(finger_count) + 
           " finger_index=" + String::num(finger_index) + 
           " axis=" + (axis == AXIS_X ? String("X") : String("Y")) + ")";
}

String GUIDEInputTouchAxis1D::_editor_name() const {
    return "Touch Axis1D";
}

String GUIDEInputTouchAxis1D::_editor_description() const {
    return "Relative movement of a touching finger on a single axis.";
}

GUIDEAction::GUIDEActionValueType GUIDEInputTouchAxis1D::_native_value_type() const {
    return GUIDEAction::AXIS_1D;
}