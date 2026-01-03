#ifndef GUIDE_INPUT_MAPPING_H
#define GUIDE_INPUT_MAPPING_H

#include <godot_cpp/classes/resource.hpp>
#include <godot_cpp/variant/vector3.hpp>
#include <godot_cpp/core/class_db.hpp>
#include "inputs/guide_input.h"
#include "modifiers/guide_modifier.h"
#include "triggers/guide_trigger.h"
#include "guide_action.h"

using namespace godot;

class GUIDEInputMapping : public Resource {
    GDCLASS(GUIDEInputMapping, Resource)

public:
    GUIDEInputMapping();
    virtual ~GUIDEInputMapping();

    void _initialize(GUIDEAction::GUIDEActionValueType value_type);
    void _update_state(double delta, GUIDEAction::GUIDEActionValueType value_type);

    // Getters and Setters
    bool get_override_action_settings() const { return override_action_settings; }
    void set_override_action_settings(bool p_override) { override_action_settings = p_override; emit_changed(); }

    bool get_is_remappable() const { return is_remappable; }
    void set_is_remappable(bool p_remappable) { is_remappable = p_remappable; emit_changed(); }

    String get_display_name() const { return display_name; }
    void set_display_name(const String &p_name) { display_name = p_name; emit_changed(); }

    String get_display_category() const { return display_category; }
    void set_display_category(const String &p_category) { display_category = p_category; emit_changed(); }

    Ref<GUIDEInput> get_input() const { return input; }
    void set_input(const Ref<GUIDEInput> &p_input) { input = p_input; emit_changed(); }

    TypedArray<GUIDEModifier> get_modifiers() const { return modifiers; }
    void set_modifiers(const TypedArray<GUIDEModifier> &p_modifiers) { modifiers = p_modifiers; emit_changed(); }

    TypedArray<GUIDETrigger> get_triggers() const { return triggers; }
    void set_triggers(const TypedArray<GUIDETrigger> &p_triggers) { triggers = p_triggers; emit_changed(); }

    double get_trigger_hold_threshold() const { return _trigger_hold_threshold; }
    GUIDETrigger::GUIDETriggerState get_state() const { return _state; }
    Vector3 get_value() const { return _value; }

protected:
    static void _bind_methods();

    bool override_action_settings = false;
    bool is_remappable = false;
    String display_name;
    String display_category;

    Ref<GUIDEInput> input;
    TypedArray<GUIDEModifier> modifiers;
    TypedArray<GUIDETrigger> triggers;

    double _trigger_hold_threshold = -1.0;
    GUIDETrigger::GUIDETriggerState _state = GUIDETrigger::NONE;
    Vector3 _value;

    TypedArray<GUIDETrigger> _trigger_list;
    int _implicit_count = 0;
    int _explicit_count = 0;
};

#endif // GUIDE_INPUT_MAPPING_H
