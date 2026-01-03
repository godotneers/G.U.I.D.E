#include "guide_input_joy_axis_1d.h"
#include "guide_input_state.h"

using namespace godot;

void GUIDEInputJoyAxis1D::_bind_methods() {
    ClassDB::bind_method(D_METHOD("get_axis"), &GUIDEInputJoyAxis1D::get_axis);
    ClassDB::bind_method(D_METHOD("set_axis", "axis"), &GUIDEInputJoyAxis1D::set_axis);
    ADD_PROPERTY(PropertyInfo(Variant::INT, "axis"), "set_axis", "get_axis");

    ClassDB::bind_method(D_METHOD("_refresh"), &GUIDEInputJoyAxis1D::_refresh);
    ClassDB::bind_method(D_METHOD("_to_string"), &GUIDEInputJoyAxis1D::_to_string);
}

GUIDEInputJoyAxis1D::GUIDEInputJoyAxis1D() {
}

GUIDEInputJoyAxis1D::~GUIDEInputJoyAxis1D() {
}

void GUIDEInputJoyAxis1D::_begin_usage() {
    if (_state) {
        _state->connect("joy_axis_state_changed", Callable(this, "_refresh"));
        _refresh();
    }
}

void GUIDEInputJoyAxis1D::_end_usage() {
    if (_state) {
        _state->disconnect("joy_axis_state_changed", Callable(this, "_refresh"));
    }
}

void GUIDEInputJoyAxis1D::_refresh() {
    if (_state) {
        _value.x = _state->get_joy_axis_value(joy_index, (JoyAxis)axis);
    }
}

bool GUIDEInputJoyAxis1D::is_same_as(const Ref<GUIDEInput> &other) const {
    Ref<GUIDEInputJoyAxis1D> o = other;
    if (o.is_null()) return false;
    return o->axis == axis && o->joy_index == joy_index;
}

String GUIDEInputJoyAxis1D::_to_string() const {
    return "(GUIDEInputJoyAxis1D: axis=" + String::num(axis) + ", joy_index=" + String::num(joy_index) + ")";
}

String GUIDEInputJoyAxis1D::_editor_name() const {
    return "Joy Axis 1D";
}

String GUIDEInputJoyAxis1D::_editor_description() const {
    return "The input from a single joy axis.";
}

GUIDEAction::GUIDEActionValueType GUIDEInputJoyAxis1D::_native_value_type() const {
    return GUIDEAction::AXIS_1D;
}