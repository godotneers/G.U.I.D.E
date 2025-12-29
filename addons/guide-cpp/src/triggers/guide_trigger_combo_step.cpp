#include "guide_trigger_combo_step.h"
#include "guide_trigger_combo.h"
#include <godot_cpp/core/math.hpp>

using namespace godot;

void GUIDETriggerComboStep::_bind_methods() {
    ClassDB::bind_method(D_METHOD("get_action"), &GUIDETriggerComboStep::get_action);
    ClassDB::bind_method(D_METHOD("set_action", "action"), &GUIDETriggerComboStep::set_action);
    ADD_PROPERTY(PropertyInfo(Variant::OBJECT, "action", PROPERTY_HINT_RESOURCE_TYPE, "GUIDEAction"), "set_action", "get_action");

    ClassDB::bind_method(D_METHOD("get_completion_events"), &GUIDETriggerComboStep::get_completion_events);
    ClassDB::bind_method(D_METHOD("set_completion_events", "events"), &GUIDETriggerComboStep::set_completion_events);
    ADD_PROPERTY(PropertyInfo(Variant::INT, "completion_events", PROPERTY_HINT_FLAGS, "Triggered:1,Started:2,Ongoing:4,Cancelled:8,Completed:16"), "set_completion_events", "get_completion_events");

    ClassDB::bind_method(D_METHOD("get_time_to_actuate"), &GUIDETriggerComboStep::get_time_to_actuate);
    ClassDB::bind_method(D_METHOD("set_time_to_actuate", "time"), &GUIDETriggerComboStep::set_time_to_actuate);
    ADD_PROPERTY(PropertyInfo(Variant::FLOAT, "time_to_actuate"), "set_time_to_actuate", "get_time_to_actuate");

    ClassDB::bind_method(D_METHOD("_fired"), &GUIDETriggerComboStep::_fired);
}

void GUIDETriggerComboStep::_prepare() {
    if (action.is_null()) return;
    if (completion_events & GUIDETriggerCombo::TRIGGERED) action->connect("triggered", Callable(this, "_fired"));
    if (completion_events & GUIDETriggerCombo::STARTED) action->connect("started", Callable(this, "_fired"));
    if (completion_events & GUIDETriggerCombo::ONGOING) action->connect("ongoing", Callable(this, "_fired"));
    if (completion_events & GUIDETriggerCombo::CANCELLED) action->connect("cancelled", Callable(this, "_fired"));
    if (completion_events & GUIDETriggerCombo::COMPLETED) action->connect("completed", Callable(this, "_fired"));
    _has_fired = false;
}

bool GUIDETriggerComboStep::is_same_as(const Ref<GUIDETriggerComboStep> &other) const {
    Ref<GUIDETriggerComboStep> o = other;
    if (o.is_null()) return false;
    return action == o->action &&
           completion_events == o->completion_events &&
           Math::is_equal_approx(time_to_actuate, o->time_to_actuate);
}
