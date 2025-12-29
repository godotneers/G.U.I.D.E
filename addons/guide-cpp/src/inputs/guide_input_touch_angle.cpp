#include "guide_input_touch_angle.h"
#include "guide_input_state.h"
#include <godot_cpp/core/math.hpp>
#include <limits.h>

using namespace godot;

void GUIDEInputTouchAngle::_bind_methods() {
    BIND_ENUM_CONSTANT(RADIANS);
    BIND_ENUM_CONSTANT(DEGREES);

    ClassDB::bind_method(D_METHOD("get_unit"), &GUIDEInputTouchAngle::get_unit);
    ClassDB::bind_method(D_METHOD("set_unit", "unit"), &GUIDEInputTouchAngle::set_unit);
    ADD_PROPERTY(PropertyInfo(Variant::INT, "unit", PROPERTY_HINT_ENUM, "RADIANS,DEGREES"), "set_unit", "get_unit");

    ClassDB::bind_method(D_METHOD("_refresh"), &GUIDEInputTouchAngle::_refresh);
    ClassDB::bind_method(D_METHOD("_to_string"), &GUIDEInputTouchAngle::_to_string);
}

GUIDEInputTouchAngle::GUIDEInputTouchAngle() {
    _initial_angle = NAN;
}

GUIDEInputTouchAngle::~GUIDEInputTouchAngle() {}

bool GUIDEInputTouchAngle::_needs_reset() const {
    return true;
}

void GUIDEInputTouchAngle::_reset() {
    double angle = _calculate_angle();
    if (Math::is_finite(_initial_angle) != Math::is_finite(angle)) {
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
        if (!Math::is_finite(angle) || !Math::is_finite(_initial_angle)) {
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
    double INF = std::numeric_limits<double>::infinity();
    if (!_state) return INF;
    Vector2 p1 = _state->get_finger_position(0, 2);
    if (!Math::is_finite(p1.x)) return INF;
    Vector2 p2 = _state->get_finger_position(1, 2);
    if (!Math::is_finite(p2.x)) return INF;
    return -p1.angle_to_point(p2);
}

bool GUIDEInputTouchAngle::is_same_as(const Ref<GUIDEInput> &other) const {
    Ref<GUIDEInputTouchAngle> o = other;
    if (o.is_null()) return false;
    return o->get_unit() == unit;
}

String GUIDEInputTouchAngle::_to_string() const {
    return "(GUIDEInputTouchAngle unit=" + (unit == RADIANS ? String("radians") : String("degrees")) + ")";
}

String GUIDEInputTouchAngle::_editor_name() const {
    return "Touch Angle";
}

String GUIDEInputTouchAngle::_editor_description() const {
    return "Angle changes of two touching fingers.";
}

GUIDEAction::GUIDEActionValueType GUIDEInputTouchAngle::_native_value_type() const {
    return GUIDEAction::AXIS_1D;
}

GUIDEInput::DeviceType GUIDEInputTouchAngle::_device_type() const {
    return TOUCH;
}
