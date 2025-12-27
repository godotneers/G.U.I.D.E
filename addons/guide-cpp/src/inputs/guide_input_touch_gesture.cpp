#include "guide_input_touch_gesture.h"
#include "guide_input_state.h"
#include <godot_cpp/core/math.hpp>
#include <cmath>

using namespace godot;

// --- Distance ---

void GUIDEInputTouchDistance::_bind_methods() {
    ClassDB::bind_method(D_METHOD("_refresh"), &GUIDEInputTouchDistance::_refresh);
}

GUIDEInputTouchDistance::GUIDEInputTouchDistance() {
    _initial_distance = NAN;
}

GUIDEInputTouchDistance::~GUIDEInputTouchDistance() {}

void GUIDEInputTouchDistance::_reset() {
    double distance = _calculate_distance();
    if (Math::is_nan(_initial_distance) != Math::is_nan(distance)) {
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
        if (Math::is_nan(distance) || Math::is_nan(_initial_distance)) {
            _value = Vector3(0, 0, 0);
        } else {
            _value = Vector3(distance / _initial_distance, 0, 0);
        }
    }
}

double GUIDEInputTouchDistance::_calculate_distance() {
    if (!_state) return NAN;
    Vector2 p1 = _state->get_finger_position(0, 2);
    if (Math::is_nan(p1.x)) return NAN;
    Vector2 p2 = _state->get_finger_position(1, 2);
    if (Math::is_nan(p2.x)) return NAN;
    return p1.distance_to(p2);
}

bool GUIDEInputTouchDistance::is_same_as(const Ref<GUIDEInput> &other) const {
    return other.is_valid() && other->get_class() == get_class();
}

// --- Angle ---

void GUIDEInputTouchAngle::_bind_methods() {
    BIND_ENUM_CONSTANT(RADIANS);
    BIND_ENUM_CONSTANT(DEGREES);

    ClassDB::bind_method(D_METHOD("get_unit"), &GUIDEInputTouchAngle::get_unit);
    ClassDB::bind_method(D_METHOD("set_unit", "unit"), &GUIDEInputTouchAngle::set_unit);
    ADD_PROPERTY(PropertyInfo(Variant::INT, "unit", PROPERTY_HINT_ENUM, "RADIANS,DEGREES"), "set_unit", "get_unit");

    ClassDB::bind_method(D_METHOD("_refresh"), &GUIDEInputTouchAngle::_refresh);
}

GUIDEInputTouchAngle::GUIDEInputTouchAngle() {
    _initial_angle = NAN;
}

GUIDEInputTouchAngle::~GUIDEInputTouchAngle() {}

void GUIDEInputTouchAngle::_reset() {
    double angle = _calculate_angle();
    if (Math::is_nan(_initial_angle) != Math::is_nan(angle)) {
        _initial_angle = angle;
    }
}

void GUIDEInputTouchAngle::_begin_usage() {
    if (_state) {
        _state->connect("touch_state_changed", Callable(this, "_refresh"));
        _refresh();
    }
}

void GUIDEInputTouchAngle::_end_usage() {
    if (_state) {
        _state->disconnect("touch_state_changed", Callable(this, "_refresh"));
    }
}

void GUIDEInputTouchAngle::_refresh() {
    if (_state) {
        double angle = _calculate_angle();
        if (Math::is_nan(angle) || Math::is_nan(_initial_angle)) {
            _value = Vector3(0, 0, 0);
        } else {
            double final_angle = angle - _initial_angle;
            if (unit == DEGREES) {
                final_angle = Math::rad_to_deg(final_angle);
            }
            _value = Vector3(final_angle, 0, 0);
        }
    }
}

double GUIDEInputTouchAngle::_calculate_angle() {
    if (!_state) return NAN;
    Vector2 p1 = _state->get_finger_position(0, 2);
    if (Math::is_nan(p1.x)) return NAN;
    Vector2 p2 = _state->get_finger_position(1, 2);
    if (Math::is_nan(p2.x)) return NAN;
    return -p1.angle_to_point(p2);
}

bool GUIDEInputTouchAngle::is_same_as(const Ref<GUIDEInput> &other) const {
    Ref<GUIDEInputTouchAngle> o = other;
    if (o.is_null()) return false;
    return o->get_unit() == (int)unit;
}
