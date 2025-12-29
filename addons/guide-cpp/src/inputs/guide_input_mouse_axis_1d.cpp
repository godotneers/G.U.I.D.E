#include "guide_input_mouse_axis_1d.h"
#include "guide_input_state.h"

using namespace godot;

void GUIDEInputMouseAxis1D::_bind_methods() {
    BIND_ENUM_CONSTANT(AXIS_X);
    BIND_ENUM_CONSTANT(AXIS_Y);

    ClassDB::bind_method(D_METHOD("get_axis"), &GUIDEInputMouseAxis1D::get_axis);
    ClassDB::bind_method(D_METHOD("set_axis", "axis"), &GUIDEInputMouseAxis1D::set_axis);
    ADD_PROPERTY(PropertyInfo(Variant::INT, "axis", PROPERTY_HINT_ENUM, "X,Y"), "set_axis", "get_axis");

    ClassDB::bind_method(D_METHOD("_refresh"), &GUIDEInputMouseAxis1D::_refresh);
    ClassDB::bind_method(D_METHOD("_to_string"), &GUIDEInputMouseAxis1D::_to_string);
}

GUIDEInputMouseAxis1D::GUIDEInputMouseAxis1D() {
}

GUIDEInputMouseAxis1D::~GUIDEInputMouseAxis1D() {
}

bool GUIDEInputMouseAxis1D::_needs_reset() const {
    return true;
}

void GUIDEInputMouseAxis1D::_begin_usage() {
    if (_state) {
        _state->connect("mouse_position_changed", Callable(this, "_refresh"));
        _refresh();
    }
}

void GUIDEInputMouseAxis1D::_end_usage() {
    if (_state) {
        _state->disconnect("mouse_position_changed", Callable(this, "_refresh"));
    }
}

void GUIDEInputMouseAxis1D::_refresh() {
    if (_state) {
        Vector2 delta = _state->get_mouse_delta_since_last_frame();
        if (axis == AXIS_X) {
            _value.x = delta.x;
        } else {
            _value.x = delta.y;
        }
    }
}

bool GUIDEInputMouseAxis1D::is_same_as(const Ref<GUIDEInput> &other) const {
    Ref<GUIDEInputMouseAxis1D> o = other;
    if (o.is_null()) return false;
    return o->axis == axis;
}

String GUIDEInputMouseAxis1D::_to_string() const {
    return "(GUIDEInputMouseAxis1D: axis=" + String::num(axis) + ")";
}

String GUIDEInputMouseAxis1D::_editor_name() const {
    return "Mouse Axis 1D";
}

String GUIDEInputMouseAxis1D::_editor_description() const {
    return "Relative mouse movement on a single axis.";
}

GUIDEAction::GUIDEActionValueType GUIDEInputMouseAxis1D::_native_value_type() const {
    return GUIDEAction::AXIS_1D;
}

GUIDEInput::DeviceType GUIDEInputMouseAxis1D::_device_type() const {
    return MOUSE;
}
