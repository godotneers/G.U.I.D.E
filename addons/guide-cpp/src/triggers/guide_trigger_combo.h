#ifndef GUIDE_TRIGGER_COMBO_H
#define GUIDE_TRIGGER_COMBO_H

#include "guide_trigger.h"
#include "guide_trigger_combo_step.h"
#include "guide_trigger_combo_cancel_action.h"

using namespace godot;

class GUIDETriggerCombo : public GUIDETrigger {
    GDCLASS(GUIDETriggerCombo, GUIDETrigger)

public:
    enum ActionEventType {
        TRIGGERED = 1,
        STARTED = 2,
        ONGOING = 4,
        CANCELLED = 8,
        COMPLETED = 16
    };

    GUIDETriggerCombo();
    virtual ~GUIDETriggerCombo();

    virtual bool is_same_as(const Ref<GUIDETrigger> &other) const override;
    virtual GUIDETriggerState _update_state(Vector3 input, double delta, GUIDEAction::GUIDEActionValueType value_type) override;
    virtual String _editor_name() const override;
    virtual String _editor_description() const override;

    void _reset();

    // Getters and Setters
    bool get_enable_debug_print() const { return enable_debug_print; }
    void set_enable_debug_print(bool p_val) { enable_debug_print = p_val; }

    TypedArray<GUIDETriggerComboStep> get_steps() const { return steps; }
    void set_steps(const TypedArray<GUIDETriggerComboStep> &p_steps) { steps = p_steps; emit_changed(); }

    TypedArray<GUIDETriggerComboCancelAction> get_cancellation_actions() const { return cancellation_actions; }
    void set_cancellation_actions(const TypedArray<GUIDETriggerComboCancelAction> &p_actions) { cancellation_actions = p_actions; emit_changed(); }

protected:
    static void _bind_methods();

    bool enable_debug_print = false;
    TypedArray<GUIDETriggerComboStep> steps;
    TypedArray<GUIDETriggerComboCancelAction> cancellation_actions;

    int _current_step = -1;
    double _remaining_time = 0.0;
};

VARIANT_ENUM_CAST(GUIDETriggerCombo::ActionEventType);

#endif // GUIDE_TRIGGER_COMBO_H