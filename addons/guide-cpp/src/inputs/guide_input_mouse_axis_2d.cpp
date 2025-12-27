#include "guide_input_mouse_axis_2d.h"
#include "guide_input_state.h"

using namespace godot;

void GUIDEInputMouseAxis2D::_bind_methods() {
    ClassDB::bind_method(D_METHOD("_refresh"), &GUIDEInputMouseAxis2D::_refresh);
}

GUIDEInputMouseAxis2D::GUIDEInputMouseAxis2D() {
}

GUIDEInputMouseAxis2D::~GUIDEInputMouseAxis2D() {
}

bool GUIDEInputMouseAxis2D::_needs_reset() const {
    return true;
}

void GUIDEInputMouseAxis2D::_begin_usage() {
    if (_state) {
        _state->connect("mouse_position_changed", Callable(this, "_refresh"));
        _refresh();
    }
}

void GUIDEInputMouseAxis2D::_end_usage() {
    if (_state) {
        _state->disconnect("mouse_position_changed", Callable(this, "_refresh"));
    }
}

void GUIDEInputMouseAxis2D::_refresh() {
    if (_state) {
        Vector2 delta = _state->get_mouse_delta_since_last_frame();
        _value.x = delta.x;
        _value.y = delta.y;
    }
}

bool GUIDEInputMouseAxis2D::is_same_as(const Ref<GUIDEInput> &other) const {
    return other.is_valid() && other->get_class() == get_class();
}

String GUIDEInputMouseAxis2D::_editor_name() const {
    return "Mouse Axis 2D";
}

String GUIDEInputMouseAxis2D::_editor_description() const {
    return "Relative mouse movement on 2 axes.";
}

int GUIDEInputMouseAxis2D::_native_value_type() const {
    return 2; // AXIS_2D
}

GUIDEInput::DeviceType GUIDEInputMouseAxis2D::_device_type() const {
    return DEVICE_MOUSE;
}