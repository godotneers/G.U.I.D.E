#include "guide_trigger_combo.h"
#include <godot_cpp/variant/utility_functions.hpp>

using namespace godot;

void GUIDETriggerCombo::_bind_methods() {
    ClassDB::bind_method(D_METHOD("get_enable_debug_print"), &GUIDETriggerCombo::get_enable_debug_print);
    ClassDB::bind_method(D_METHOD("set_enable_debug_print", "val"), &GUIDETriggerCombo::set_enable_debug_print);
    ADD_PROPERTY(PropertyInfo(Variant::BOOL, "enable_debug_print"), "set_enable_debug_print", "get_enable_debug_print");

    ClassDB::bind_method(D_METHOD("get_steps"), &GUIDETriggerCombo::get_steps);
    ClassDB::bind_method(D_METHOD("set_steps", "steps"), &GUIDETriggerCombo::set_steps);
    ADD_PROPERTY(PropertyInfo(Variant::ARRAY, "steps", PROPERTY_HINT_NONE, "24/17:GUIDETriggerComboStep", PROPERTY_USAGE_DEFAULT, "GUIDETriggerComboStep"), "set_steps", "get_steps");

    ClassDB::bind_method(D_METHOD("get_cancellation_actions"), &GUIDETriggerCombo::get_cancellation_actions);
    ClassDB::bind_method(D_METHOD("set_cancellation_actions", "actions"), &GUIDETriggerCombo::set_cancellation_actions);
    ADD_PROPERTY(PropertyInfo(Variant::ARRAY, "cancellation_actions", PROPERTY_HINT_NONE, "24/17:GUIDETriggerComboCancelAction", PROPERTY_USAGE_DEFAULT, "GUIDETriggerComboCancelAction"), "set_cancellation_actions", "get_cancellation_actions");
}

GUIDETriggerCombo::GUIDETriggerCombo() {
}

GUIDETriggerCombo::~GUIDETriggerCombo() {
}

bool GUIDETriggerCombo::is_same_as(const Ref<GUIDETrigger> &other) const {
    Ref<GUIDETriggerCombo> o = other;
    if (o.is_null()) return false;
    if (steps.size() != o->get_steps().size() || cancellation_actions.size() != o->get_cancellation_actions().size()) return false;
    for (int i = 0; i < steps.size(); i++) {
        Ref<GUIDETriggerComboStep> s1 = steps[i];
        Ref<GUIDETriggerComboStep> s2 = o->get_steps()[i];
        if (!s1->is_same_as(s2)) return false;
    }
    for (int i = 0; i < cancellation_actions.size(); i++) {
        Ref<GUIDETriggerComboCancelAction> c1 = cancellation_actions[i];
        Ref<GUIDETriggerComboCancelAction> c2 = o->get_cancellation_actions()[i];
        if (!c1->is_same_as(c2)) return false;
    }
    return true;
}

GUIDETrigger::GUIDETriggerState GUIDETriggerCombo::_update_state(Vector3 input, double delta, int value_type) {
    if (steps.is_empty()) return NONE;

    if (_current_step == -1) {
        for (int i = 0; i < steps.size(); i++) ((Ref<GUIDETriggerComboStep>)steps[i])->_prepare();
        for (int i = 0; i < cancellation_actions.size(); i++) ((Ref<GUIDETriggerComboCancelAction>)cancellation_actions[i])->_prepare();
        _reset_combo();
    }

    Ref<GUIDEAction> current_action = ((Ref<GUIDETriggerComboStep>)steps[_current_step])->action;
    if (current_action.is_null()) return NONE;

    for (int i = 0; i < cancellation_actions.size(); i++) {
        Ref<GUIDETriggerComboCancelAction> action = cancellation_actions[i];
        if (action->action == current_action) continue;
        if (action->_has_fired) {
            if (enable_debug_print) UtilityFunctions::print("Combo cancelled by action.");
            _reset_combo();
            return NONE;
        }
    }

    for (int i = 0; i < steps.size(); i++) {
        Ref<GUIDETriggerComboStep> step = steps[i];
        if (step->action == current_action) continue;
        if (step->_has_fired) {
            if (enable_debug_print) UtilityFunctions::print("Combo out of order step.");
            _reset_combo();
            return NONE;
        }
    }

    if (_current_step > 0) {
        _remaining_time -= delta;
        if (_remaining_time <= 0.0) {
            if (enable_debug_print) UtilityFunctions::print("Step time exceeded.");
            _reset_combo();
            return NONE;
        }
    }

    Ref<GUIDETriggerComboStep> cur_step = steps[_current_step];
    if (cur_step->_has_fired) {
        cur_step->_has_fired = false;
        if (_current_step + 1 >= steps.size()) {
            if (enable_debug_print) UtilityFunctions::print("Combo fired.");
            _reset_combo();
            return TRIGGERED;
        }
        _current_step++;
        _remaining_time = ((Ref<GUIDETriggerComboStep>)steps[_current_step])->time_to_actuate;
        for (int i = 0; i < steps.size(); i++) ((Ref<GUIDETriggerComboStep>)steps[i])->_has_fired = false;
        for (int i = 0; i < cancellation_actions.size(); i++) ((Ref<GUIDETriggerComboCancelAction>)cancellation_actions[i])->_has_fired = false;
    }

    return ONGOING;
}

void GUIDETriggerCombo::_reset_combo() {
    _current_step = 0;
    if (!steps.is_empty()) {
        _remaining_time = ((Ref<GUIDETriggerComboStep>)steps[0])->time_to_actuate;
    }
    for (int i = 0; i < steps.size(); i++) ((Ref<GUIDETriggerComboStep>)steps[i])->_has_fired = false;
    for (int i = 0; i < cancellation_actions.size(); i++) ((Ref<GUIDETriggerComboCancelAction>)cancellation_actions[i])->_has_fired = false;
}

String GUIDETriggerCombo::_editor_name() const {
    return "Combo";
}

String GUIDETriggerCombo::_editor_description() const {
    return "Fires upon completion of a sequence of actions.";
}
