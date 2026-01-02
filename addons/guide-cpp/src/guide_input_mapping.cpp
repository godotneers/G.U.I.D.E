#include "guide_input_mapping.h"
#include "triggers/guide_trigger_down.h"
#include "triggers/guide_trigger_hold.h"
#include <godot_cpp/core/math.hpp>
#include <algorithm>

using namespace godot;

void GUIDEInputMapping::_bind_methods() {
    ClassDB::bind_method(D_METHOD("get_override_action_settings"), &GUIDEInputMapping::get_override_action_settings);
    ClassDB::bind_method(D_METHOD("set_override_action_settings", "override"), &GUIDEInputMapping::set_override_action_settings);
    ADD_PROPERTY(PropertyInfo(Variant::BOOL, "override_action_settings"), "set_override_action_settings", "get_override_action_settings");

    ClassDB::bind_method(D_METHOD("get_is_remappable"), &GUIDEInputMapping::get_is_remappable);
    ClassDB::bind_method(D_METHOD("set_is_remappable", "remappable"), &GUIDEInputMapping::set_is_remappable);
    ADD_PROPERTY(PropertyInfo(Variant::BOOL, "is_remappable"), "set_is_remappable", "get_is_remappable");

    ClassDB::bind_method(D_METHOD("get_display_name"), &GUIDEInputMapping::get_display_name);
    ClassDB::bind_method(D_METHOD("set_display_name", "name"), &GUIDEInputMapping::set_display_name);
    ADD_PROPERTY(PropertyInfo(Variant::STRING, "display_name"), "set_display_name", "get_display_name");

    ClassDB::bind_method(D_METHOD("get_display_category"), &GUIDEInputMapping::get_display_category);
    ClassDB::bind_method(D_METHOD("set_display_category", "category"), &GUIDEInputMapping::set_display_category);
    ADD_PROPERTY(PropertyInfo(Variant::STRING, "display_category"), "set_display_category", "get_display_category");

    ClassDB::bind_method(D_METHOD("get_input"), &GUIDEInputMapping::get_input);
    ClassDB::bind_method(D_METHOD("set_input", "input"), &GUIDEInputMapping::set_input);
    ADD_PROPERTY(PropertyInfo(Variant::OBJECT, "input", PROPERTY_HINT_RESOURCE_TYPE, "GUIDEInput"), "set_input", "get_input");

    ClassDB::bind_method(D_METHOD("get_modifiers"), &GUIDEInputMapping::get_modifiers);
    ClassDB::bind_method(D_METHOD("set_modifiers", "modifiers"), &GUIDEInputMapping::set_modifiers);
    ADD_PROPERTY(PropertyInfo(Variant::ARRAY, "modifiers", PROPERTY_HINT_NONE, "24/17:GUIDEModifier", PROPERTY_USAGE_DEFAULT, "GUIDEModifier"), "set_modifiers", "get_modifiers");

    ClassDB::bind_method(D_METHOD("get_triggers"), &GUIDEInputMapping::get_triggers);
    ClassDB::bind_method(D_METHOD("set_triggers", "triggers"), &GUIDEInputMapping::set_triggers);
    ADD_PROPERTY(PropertyInfo(Variant::ARRAY, "triggers", PROPERTY_HINT_NONE, "24/17:GUIDETrigger", PROPERTY_USAGE_DEFAULT, "GUIDETrigger"), "set_triggers", "get_triggers");
}

GUIDEInputMapping::GUIDEInputMapping() {
}

GUIDEInputMapping::~GUIDEInputMapping() {
}

void GUIDEInputMapping::_initialize(GUIDEAction::GUIDEActionValueType value_type) {
    _trigger_list.clear();
    _implicit_count = 0;
    _explicit_count = 0;
    _trigger_hold_threshold = -1.0;

    if (triggers.is_empty()) {
        Ref<GUIDETriggerDown> default_trigger;
        default_trigger.instantiate();
        default_trigger->set_actuation_threshold(0);
        _explicit_count = 1;
        _trigger_list.append(default_trigger);
        return;
    }

    Vector3 input_value = Vector3(0, 0, 0);
    if (input.is_valid()) {
        input_value = input->get_value();
    }

    for (int i = 0; i < modifiers.size(); i++) {
        Ref<GUIDEModifier> modifier = modifiers[i];
        if (modifier.is_valid()) {
            input_value = modifier->_modify_input(input_value, 0, value_type);
        }
    }

    for (int i = 0; i < triggers.size(); i++) {
        Ref<GUIDETrigger> trigger = triggers[i];
        if (!trigger.is_valid()) continue;

        switch (trigger->_get_trigger_type()) {
            case GUIDETrigger::EXPLICIT:
                _explicit_count++;
                break;
            case GUIDETrigger::IMPLICIT:
                _implicit_count++;
                break;
            case GUIDETrigger::BLOCKING:
                break;
        }
        _trigger_list.append(trigger);

        Ref<GUIDETriggerHold> hold_trigger = trigger;
        if (hold_trigger.is_valid()) {
            if (_trigger_hold_threshold == -1) {
                _trigger_hold_threshold = hold_trigger->get_hold_threshold();
            } else {
                _trigger_hold_threshold = Math::min(_trigger_hold_threshold, hold_trigger->get_hold_threshold());
            }
        }
        trigger->set_last_value(input_value);
    }
}

void GUIDEInputMapping::_update_state(double delta, GUIDEAction::GUIDEActionValueType value_type) {

    Vector3 input_value = Vector3(0, 0, 0);
    if (input.is_valid()) {
        input_value = input->get_value();
    }

    for (int i = 0; i < modifiers.size(); i++) {
        Ref<GUIDEModifier> modifier = modifiers[i];
        if (modifier.is_valid()) {
            input_value = modifier->_modify_input(input_value, delta, value_type);
            // UtilityFunctions::print("Modifier ", i, " processing input after: ", input_value);
        }
    }

    _value = input_value;

    int triggered_implicits = 0;
    int triggered_explicits = 0;
    int triggered_blocked = 0;

    int result = GUIDETrigger::NONE;

    for (int i = 0; i < _trigger_list.size(); i++) {
        Ref<GUIDETrigger> trigger = _trigger_list[i];
        if (!trigger.is_valid()) continue;

        GUIDETrigger::GUIDETriggerState trigger_result = trigger->_update_state(_value, delta, value_type);
        trigger->set_last_value(_value);

        GUIDETrigger::GUIDETriggerType trigger_type = trigger->_get_trigger_type();
        if (trigger_result == GUIDETrigger::TRIGGERED) {
            switch (trigger_type) {
                case GUIDETrigger::EXPLICIT:
                    triggered_explicits++;
                    break;
                case GUIDETrigger::IMPLICIT:
                    triggered_implicits++;
                    break;
                case GUIDETrigger::BLOCKING:
                    triggered_blocked++;
                    break;
            }
        }

        if (trigger_type == GUIDETrigger::EXPLICIT) {
            result = Math::max(result, (int)trigger_result);
        }
    }

    if (triggered_blocked > 0) {
        _state = GUIDETrigger::NONE;
        return;
    }

    if (triggered_implicits < _implicit_count) {
        _state = GUIDETrigger::NONE;
        return;
    }

    if (_explicit_count == 0 && _implicit_count > 0) {
        _state = GUIDETrigger::TRIGGERED;
        return;
    }

    _state = (GUIDETrigger::GUIDETriggerState)result;
}
