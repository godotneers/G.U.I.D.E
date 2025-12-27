#include "guide_trigger_combo_components.h"
#include <godot_cpp/core/math.hpp>

using namespace godot;

void GUIDETriggerComboStep::_bind_methods() {
    ClassDB::bind_method(D_METHOD("_fired"), &GUIDETriggerComboStep::_fired);
}

void GUIDETriggerComboStep::_prepare() {
    if (action.is_null()) return;
    if (completion_events & 1) action->connect("triggered", Callable(this, "_fired"));
    if (completion_events & 2) action->connect("started", Callable(this, "_fired"));
    if (completion_events & 4) action->connect("ongoing", Callable(this, "_fired"));
    if (completion_events & 8) action->connect("cancelled", Callable(this, "_fired"));
    if (completion_events & 16) action->connect("completed", Callable(this, "_fired"));
    _has_fired = false;
}

bool GUIDETriggerComboStep::is_same_as(const Ref<GUIDETriggerComboStep> &other) const {
    if (other.is_null()) return false;
    return action == other->action && completion_events == other->completion_events && Math::abs(time_to_actuate - other->time_to_actuate) < 0.00001;
}

void GUIDETriggerComboCancelAction::_bind_methods() {
    ClassDB::bind_method(D_METHOD("_fired"), &GUIDETriggerComboCancelAction::_fired);
}

void GUIDETriggerComboCancelAction::_prepare() {
    if (action.is_null()) return;
    if (completion_events & 1) action->connect("triggered", Callable(this, "_fired"));
    if (completion_events & 2) action->connect("started", Callable(this, "_fired"));
    if (completion_events & 4) action->connect("ongoing", Callable(this, "_fired"));
    if (completion_events & 8) action->connect("cancelled", Callable(this, "_fired"));
    if (completion_events & 16) action->connect("completed", Callable(this, "_fired"));
    _has_fired = false;
}

bool GUIDETriggerComboCancelAction::is_same_as(const Ref<GUIDETriggerComboCancelAction> &other) const {
    if (other.is_null()) return false;
    return action == other->action && completion_events == other->completion_events;
}