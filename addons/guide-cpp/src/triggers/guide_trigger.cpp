#include "guide_trigger.h"
#include <godot_cpp/core/math.hpp>
#include <cmath>

using namespace godot;

void GUIDETrigger::_bind_methods() {
    BIND_ENUM_CONSTANT(NONE);
    BIND_ENUM_CONSTANT(ONGOING);
    BIND_ENUM_CONSTANT(TRIGGERED);

    BIND_ENUM_CONSTANT(EXPLICIT);
    BIND_ENUM_CONSTANT(IMPLICIT);
    BIND_ENUM_CONSTANT(BLOCKING);

    ClassDB::bind_method(D_METHOD("get_actuation_threshold"), &GUIDETrigger::get_actuation_threshold);
    ClassDB::bind_method(D_METHOD("set_actuation_threshold", "threshold"), &GUIDETrigger::set_actuation_threshold);
    ADD_PROPERTY(PropertyInfo(Variant::FLOAT, "actuation_threshold"), "set_actuation_threshold", "get_actuation_threshold");
}

GUIDETrigger::GUIDETrigger() {
}

GUIDETrigger::~GUIDETrigger() {
}

bool GUIDETrigger::is_same_as(const Ref<GUIDETrigger> &other) const {
    return this == other.ptr();
}

GUIDETrigger::GUIDETriggerType GUIDETrigger::_get_trigger_type() const {
    return EXPLICIT;
}

GUIDETrigger::GUIDETriggerState GUIDETrigger::_update_state(Vector3 input, double delta, int value_type) {
    return NONE;
}

bool GUIDETrigger::_is_actuated(Vector3 input, int value_type) const {
    // value_type corresponds to GUIDEActionValueType
    switch (value_type) {
        case 0: // BOOL
        case 1: // AXIS_1D
            return _is_axis1d_actuated(input);
        case 2: // AXIS_2D
            return _is_axis2d_actuated(input);
        case 3: // AXIS_3D
            return _is_axis3d_actuated(input);
    }
    return false;
}

bool GUIDETrigger::_is_axis1d_actuated(Vector3 input) const {
    return Math::is_finite(input.x) && Math::abs(input.x) > actuation_threshold;
}

bool GUIDETrigger::_is_axis2d_actuated(Vector3 input) const {
    return Math::is_finite(input.x) && Math::is_finite(input.y) && (input.x * input.x + input.y * input.y) > actuation_threshold * actuation_threshold;
}

bool GUIDETrigger::_is_axis3d_actuated(Vector3 input) const {
    return input.is_finite() && input.length_squared() > actuation_threshold * actuation_threshold;
}

String GUIDETrigger::_editor_name() const {
    return "GUIDETrigger";
}

String GUIDETrigger::_editor_description() const {
    return "";
}
