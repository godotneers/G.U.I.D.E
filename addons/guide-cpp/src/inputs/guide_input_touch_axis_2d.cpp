#include "guide_input_touch_axis_2d.h"

using namespace godot;

bool GUIDEInputTouchAxis2D::is_same_as(const Ref<GUIDEInput> &other) const {
    Ref<GUIDEInputTouchAxis2D> o = other;
    if (o.is_null()) return false;
    return o->get_finger_count() == finger_count && o->get_finger_index() == finger_index;
}