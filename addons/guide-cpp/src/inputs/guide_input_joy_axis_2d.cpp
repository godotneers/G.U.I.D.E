#include "guide_input_joy_axis_2d.h"
#include "guide_input_state.h"

using namespace godot;

void GUIDEInputJoyAxis2D::_bind_methods() {
    ClassDB::bind_method(D_METHOD("get_x_axis"), &GUIDEInputJoyAxis2D::get_x_axis);
    ClassDB::bind_method(D_METHOD("set_x_axis", "axis"), &GUIDEInputJoyAxis2D::set_x_axis);
    ADD_PROPERTY(PropertyInfo(Variant::INT, "x"), "set_x_axis", "get_x_axis");

    ClassDB::bind_method(D_METHOD("get_y_axis"), &GUIDEInputJoyAxis2D::get_y_axis);
    ClassDB::bind_method(D_METHOD("set_y_axis", "axis"), &GUIDEInputJoyAxis2D::set_y_axis);
    ADD_PROPERTY(PropertyInfo(Variant::INT, "y"), "set_y_axis", "get_y_axis");

    ClassDB::bind_method(D_METHOD("_refresh"), &GUIDEInputJoyAxis2D::_refresh);
}

GUIDEInputJoyAxis2D::GUIDEInputJoyAxis2D() {
}

GUIDEInputJoyAxis2D::~GUIDEInputJoyAxis2D() {
}

void GUIDEInputJoyAxis2D::_begin_usage() {
    if (_state) {
        _state->connect("joy_axis_state_changed", Callable(this, "_refresh"));
        _refresh();
    }
}

void GUIDEInputJoyAxis2D::_end_usage() {
    if (_state) {
        _state->disconnect("joy_axis_state_changed", Callable(this, "_refresh"));
    }
}

void GUIDEInputJoyAxis2D::_refresh() {
    if (_state) {
        _value.x = _state->get_joy_axis_value(joy_index, (JoyAxis)x);
        _value.y = _state->get_joy_axis_value(joy_index, (JoyAxis)y);
    }
}

bool GUIDEInputJoyAxis2D::is_same_as(const Ref<GUIDEInput> &other) const {
    Ref<GUIDEInputJoyAxis2D> o = other;
    if (o.is_null()) return false;
    return o->x == x && o->y == y && o->joy_index == joy_index;
}

String GUIDEInputJoyAxis2D::_editor_name() const {
    return "Joy Axis 2D";
}

String GUIDEInputJoyAxis2D::_editor_description() const {
    return "The input from two Joy axes. Usually from a stick.";
}

int GUIDEInputJoyAxis2D::_native_value_type() const {
    return 2; // AXIS_2D
}