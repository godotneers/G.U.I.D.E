#include "guide_input_touch_distance.h"
#include "guide_input_state.h"
#include <godot_cpp/core/math.hpp>
#include <limits>

using namespace godot;

void GUIDEInputTouchDistance::_bind_methods() {
    ClassDB::bind_method(D_METHOD("_refresh"), &GUIDEInputTouchDistance::_refresh);
    ClassDB::bind_method(D_METHOD("_to_string"), &GUIDEInputTouchDistance::_to_string);
}

GUIDEInputTouchDistance::GUIDEInputTouchDistance() {
    _initial_distance = INF;
}

GUIDEInputTouchDistance::~GUIDEInputTouchDistance() {}

bool GUIDEInputTouchDistance::_needs_reset() const {
    return true;
}

void GUIDEInputTouchDistance::_reset() {
    double distance = _calculate_distance();
    if (Math::is_finite(_initial_distance) != Math::is_finite(distance)) {
        _initial_distance = distance;
    }
}

void GUIDEInputTouchDistance::_begin_usage() {
    if (_state) {
        _state->connect("touch_state_changed", Callable(this, "_refresh"));
        _refresh();
    }
}

void GUIDEInputTouchDistance::_end_usage() {
    if (_state) {
        _state->disconnect("touch_state_changed", Callable(this, "_refresh"));
    }
}

void GUIDEInputTouchDistance::_refresh() {
    if (_state) {
        double distance = _calculate_distance();
        if (!Math::is_finite(distance) || !Math::is_finite(_initial_distance)) {
            _value = Vector3(0, 0, 0);
        } else {
            _value = Vector3(distance / _initial_distance, 0, 0);
        }
    }
}

double GUIDEInputTouchDistance::_calculate_distance() {
    if (!_state) return INF;
    Vector2 p1 = _state->get_finger_position(0, 2);
    if (Math::is_nan(p1.x)) return INF;
    Vector2 p2 = _state->get_finger_position(1, 2);
    if (Math::is_nan(p2.x)) return INF;
    return p1.distance_to(p2);
}

bool GUIDEInputTouchDistance::is_same_as(const Ref<GUIDEInput> &other) const {
    Ref<GUIDEInputTouchDistance> o = other;
    if (o.is_null()) return false;
    return true;
}

String GUIDEInputTouchDistance::_to_string() const {
    return "(GUIDEInputTouchDistance)";
}

String GUIDEInputTouchDistance::_editor_name() const {
    return "Touch Distance";
}

String GUIDEInputTouchDistance::_editor_description() const {
    return "Distance of two touching fingers.";
}

GUIDEAction::GUIDEActionValueType GUIDEInputTouchDistance::_native_value_type() const {
    return GUIDEAction::AXIS_1D;
}

GUIDEInput::DeviceType GUIDEInputTouchDistance::_device_type() const {
    return TOUCH;
}
