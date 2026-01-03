#include "guide_trigger_combo_cancel_action.h"
#include "guide_trigger_combo.h"

using namespace godot;

void GUIDETriggerComboCancelAction::_bind_methods() {
    ClassDB::bind_method(D_METHOD("get_action"), &GUIDETriggerComboCancelAction::get_action);
    ClassDB::bind_method(D_METHOD("set_action", "action"), &GUIDETriggerComboCancelAction::set_action);
    ADD_PROPERTY(PropertyInfo(Variant::OBJECT, "action", PROPERTY_HINT_RESOURCE_TYPE, "GUIDEAction"), "set_action", "get_action");

    ClassDB::bind_method(D_METHOD("get_completion_events"), &GUIDETriggerComboCancelAction::get_completion_events);
    ClassDB::bind_method(D_METHOD("set_completion_events", "events"), &GUIDETriggerComboCancelAction::set_completion_events);
    ADD_PROPERTY(PropertyInfo(Variant::INT, "completion_events", PROPERTY_HINT_FLAGS, "Triggered:1,Started:2,Ongoing:4,Cancelled:8,Completed:16"), "set_completion_events", "get_completion_events");

    ClassDB::bind_method(D_METHOD("_fired"), &GUIDETriggerComboCancelAction::_fired);
}

void GUIDETriggerComboCancelAction::_prepare() {
    if (action.is_null()) return;
    if (completion_events & GUIDETriggerCombo::TRIGGERED) action->connect("triggered", Callable(this, "_fired"));
    if (completion_events & GUIDETriggerCombo::STARTED) action->connect("started", Callable(this, "_fired"));
    if (completion_events & GUIDETriggerCombo::ONGOING) action->connect("ongoing", Callable(this, "_fired"));
    if (completion_events & GUIDETriggerCombo::CANCELLED) action->connect("cancelled", Callable(this, "_fired"));
    if (completion_events & GUIDETriggerCombo::COMPLETED) action->connect("completed", Callable(this, "_fired"));
    _has_fired = false;
}

bool GUIDETriggerComboCancelAction::is_same_as(const Ref<GUIDETriggerComboCancelAction> &other) const {
    Ref<GUIDETriggerComboCancelAction> o = other;
    if (o.is_null()) return false;
    return action == o->action && 
           completion_events == o->completion_events;
}
