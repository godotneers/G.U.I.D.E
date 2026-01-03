#include "guide_trigger_stability.h"
#include <godot_cpp/core/math.hpp>
#include <cmath>

using namespace godot;

void GUIDETriggerStability::_bind_methods() {
    BIND_ENUM_CONSTANT(INPUT_IS_STABLE);
    BIND_ENUM_CONSTANT(INPUT_CHANGES);

    ClassDB::bind_method(D_METHOD("get_max_deviation"), &GUIDETriggerStability::get_max_deviation);
    ClassDB::bind_method(D_METHOD("set_max_deviation", "val"), &GUIDETriggerStability::set_max_deviation);
    ADD_PROPERTY(PropertyInfo(Variant::FLOAT, "max_deviation"), "set_max_deviation", "get_max_deviation");

    ClassDB::bind_method(D_METHOD("get_trigger_when"), &GUIDETriggerStability::get_trigger_when);
    ClassDB::bind_method(D_METHOD("set_trigger_when", "val"), &GUIDETriggerStability::set_trigger_when);
    ADD_PROPERTY(PropertyInfo(Variant::INT, "trigger_when", PROPERTY_HINT_ENUM, "INPUT_IS_STABLE,INPUT_CHANGES"), "set_trigger_when", "get_trigger_when");
}

GUIDETriggerStability::GUIDETriggerStability() {
}

GUIDETriggerStability::~GUIDETriggerStability() {
}

bool GUIDETriggerStability::is_same_as(const Ref<GUIDETrigger> &other) const {
    Ref<GUIDETriggerStability> o = other;
    if (o.is_null()) return false;
    return o->get_trigger_when() == trigger_when &&
           Math::is_equal_approx(o->get_max_deviation(), max_deviation);
}

GUIDETrigger::GUIDETriggerType GUIDETriggerStability::_get_trigger_type() const {
    return IMPLICIT;
}

GUIDETrigger::GUIDETriggerState GUIDETriggerStability::_update_state(Vector3 input, double delta, GUIDEAction::GUIDEActionValueType value_type) {
    if (_is_actuated(input, value_type)) {
        if (_deviated) {
            return (trigger_when == INPUT_IS_STABLE) ? NONE : TRIGGERED;
        }

        if (!_is_actuated(get_last_value(), value_type)) {
            _initial_value = input;
            return (trigger_when == INPUT_IS_STABLE) ? TRIGGERED : ONGOING;
        }

        if (_initial_value.distance_squared_to(input) > (max_deviation * max_deviation)) {
            _deviated = true;
            return (trigger_when == INPUT_IS_STABLE) ? NONE : TRIGGERED;
        }

        return (trigger_when == INPUT_IS_STABLE) ? TRIGGERED : ONGOING;
    }

    _deviated = false;
    return NONE;
}

String GUIDETriggerStability::_editor_name() const {
    return "Stability";
}

String GUIDETriggerStability::_editor_description() const {
    return "Triggers depending on whether the input changes while actuated. This trigger\nis implicit, so it must succeed for all other triggers to succeed.";
}

 // namespace godot
