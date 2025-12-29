#include "guide_trigger_tap.h"
#include <godot_cpp/core/math.hpp>

using namespace godot;

void GUIDETriggerTap::_bind_methods() {
    ClassDB::bind_method(D_METHOD("get_tap_threshold"), &GUIDETriggerTap::get_tap_threshold);
    ClassDB::bind_method(D_METHOD("set_tap_threshold", "value"), &GUIDETriggerTap::set_tap_threshold);
    ADD_PROPERTY(PropertyInfo(Variant::FLOAT, "tap_threshold"), "set_tap_threshold", "get_tap_threshold");
}

GUIDETriggerTap::GUIDETriggerTap() {
}

GUIDETriggerTap::~GUIDETriggerTap() {
}

bool GUIDETriggerTap::is_same_as(const Ref<GUIDETrigger> &other) const {
    Ref<GUIDETriggerTap> o = other;
    if (o.is_null()) return false;
    return Math::is_equal_approx(o->get_tap_threshold(), tap_threshold);
}

GUIDETrigger::GUIDETriggerState GUIDETriggerTap::_update_state(Vector3 input, double delta, GUIDEAction::GUIDEActionValueType value_type) {
    if (_is_actuated(input, value_type)) {
        if (_is_actuated(get_last_value(), value_type) && _accumulated_time > tap_threshold) {
            return NONE;
        }
        _accumulated_time += delta;
        if (_accumulated_time < tap_threshold) {
            return ONGOING;
        } else {
            return NONE;
        }
    } else {
        if (_is_actuated(get_last_value(), value_type)) {
            if (_accumulated_time < tap_threshold) {
                _accumulated_time = 0;
                return TRIGGERED;
            }
            _accumulated_time = 0;
        }
        return NONE;
    }
}

String GUIDETriggerTap::_editor_name() const {
    return "Tap";
}

String GUIDETriggerTap::_editor_description() const {
    return "Fires when the input is actuated and released within the given timeframe.";
}