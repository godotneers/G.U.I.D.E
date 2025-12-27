#include "guide_trigger_hold.h"
#include <godot_cpp/core/math.hpp>

using namespace godot;

void GUIDETriggerHold::_bind_methods() {
    ClassDB::bind_method(D_METHOD("get_hold_threshold"), &GUIDETriggerHold::get_hold_threshold);
    ClassDB::bind_method(D_METHOD("set_hold_threshold", "threshold"), &GUIDETriggerHold::set_hold_threshold);
    ADD_PROPERTY(PropertyInfo(Variant::FLOAT, "hold_threshold"), "set_hold_threshold", "get_hold_threshold");

    ClassDB::bind_method(D_METHOD("get_is_one_shot"), &GUIDETriggerHold::get_is_one_shot);
    ClassDB::bind_method(D_METHOD("set_is_one_shot", "one_shot"), &GUIDETriggerHold::set_is_one_shot);
    ADD_PROPERTY(PropertyInfo(Variant::BOOL, "is_one_shot"), "set_is_one_shot", "get_is_one_shot");
}

GUIDETriggerHold::GUIDETriggerHold() {
}

GUIDETriggerHold::~GUIDETriggerHold() {
}

bool GUIDETriggerHold::is_same_as(const Ref<GUIDETrigger> &other) const {
    Ref<GUIDETriggerHold> o = other;
    if (o.is_null()) return false;
    return Math::abs(o->get_hold_threshold() - hold_threshold) < 0.00001 && o->get_is_one_shot() == is_one_shot;
}

GUIDETrigger::GUIDETriggerState GUIDETriggerHold::_update_state(Vector3 input, double delta, int value_type) {
    if (_is_actuated(input, value_type)) {
        _accumulated_time += delta;
        if (_accumulated_time >= hold_threshold) {
            if (is_one_shot && _did_shoot) {
                return GUIDETrigger::STATE_NONE;
            } else {
                _did_shoot = true;
                return GUIDETrigger::STATE_TRIGGERED;
            }
        } else {
            return GUIDETrigger::STATE_ONGOING;
        }
    } else {
        _accumulated_time = 0;
        _did_shoot = false;
        return GUIDETrigger::STATE_NONE;
    }
}

String GUIDETriggerHold::_editor_name() const {
    return "Hold";
}

String GUIDETriggerHold::_editor_description() const {
    return "Fires, once the input has remained actuated for hold_threshold seconds.\nMy fire once or repeatedly.";
}

} // namespace godot