#include "guide_trigger_chorded_action.h"
#include <godot_cpp/variant/utility_functions.hpp>

using namespace godot;

void GUIDETriggerChordedAction::_bind_methods() {
    ClassDB::bind_method(D_METHOD("get_action"), &GUIDETriggerChordedAction::get_action);
    ClassDB::bind_method(D_METHOD("set_action", "action"), &GUIDETriggerChordedAction::set_action);
    ADD_PROPERTY(PropertyInfo(Variant::OBJECT, "action", PROPERTY_HINT_RESOURCE_TYPE, "GUIDEAction"), "set_action", "get_action");
}

GUIDETriggerChordedAction::GUIDETriggerChordedAction() {
}

GUIDETriggerChordedAction::~GUIDETriggerChordedAction() {
}

bool GUIDETriggerChordedAction::is_same_as(const Ref<GUIDETrigger> &other) const {
    Ref<GUIDETriggerChordedAction> other_chord = other;
    if (other_chord.is_null()) return false;
    return action == other_chord->action;
}

GUIDETrigger::GUIDETriggerType GUIDETriggerChordedAction::_get_trigger_type() const {
    return IMPLICIT;
}

GUIDETrigger::GUIDETriggerState GUIDETriggerChordedAction::_update_state(Vector3 input, double delta, GUIDEAction::GUIDEActionValueType value_type) {
    if (action.is_null()) {
        UtilityFunctions::push_warning("Chorded trigger without action will never trigger.");
        return NONE;
    }
    if (action->is_triggered()) return TRIGGERED;
    return NONE;
}

String GUIDETriggerChordedAction::_editor_name() const {
    return "Chorded Action";
}

String GUIDETriggerChordedAction::_editor_description() const {
    return String("Fires when the given action is currently triggering. This trigger is implicit,\n") +
           String("so it will prevent the action from triggering even if other triggers are successful.");
}

