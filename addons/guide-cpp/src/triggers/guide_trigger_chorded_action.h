#ifndef GUIDE_TRIGGER_CHORDED_ACTION_H
#define GUIDE_TRIGGER_CHORDED_ACTION_H

#include "guide_trigger.h"

using namespace godot;

class GUIDETriggerChordedAction : public GUIDETrigger {
    GDCLASS(GUIDETriggerChordedAction, GUIDETrigger)

public:
    GUIDETriggerChordedAction();
    virtual ~GUIDETriggerChordedAction();

    virtual bool is_same_as(const Ref<GUIDETrigger> &other) const override;
    virtual GUIDETriggerType _get_trigger_type() const override;
    virtual GUIDETriggerState _update_state(Vector3 input, double delta, GUIDEAction::GUIDEActionValueType value_type) override;
    
    virtual String _editor_name() const override;
    virtual String _editor_description() const override;

    Ref<GUIDEAction> get_action() const { return action; }
    void set_action(const Ref<GUIDEAction> &p_action) { action = p_action; emit_changed(); }

protected:
    static void _bind_methods();

    Ref<GUIDEAction> action;
};

#endif // GUIDE_TRIGGER_CHORDED_ACTION_H