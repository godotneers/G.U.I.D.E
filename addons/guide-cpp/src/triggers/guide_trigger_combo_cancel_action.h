#ifndef GUIDE_TRIGGER_COMBO_CANCEL_ACTION_H
#define GUIDE_TRIGGER_COMBO_CANCEL_ACTION_H

#include <godot_cpp/classes/resource.hpp>
#include <godot_cpp/core/class_db.hpp>
#include "guide_action.h"

using namespace godot;

class GUIDETriggerComboCancelAction : public Resource {
    GDCLASS(GUIDETriggerComboCancelAction, Resource)
public:
    Ref<GUIDEAction> action;
    int completion_events = 1; // TRIGGERED
    bool _has_fired = false;

    GUIDETriggerComboCancelAction() {}
    virtual ~GUIDETriggerComboCancelAction() {}

    void _prepare();
    void _fired() { _has_fired = true; }
    bool is_same_as(const Ref<GUIDETriggerComboCancelAction> &other) const;

    Ref<GUIDEAction> get_action() const { return action; }
    void set_action(const Ref<GUIDEAction> &p_action) { action = p_action; emit_changed(); }

    int get_completion_events() const { return completion_events; }
    void set_completion_events(int p_events) { completion_events = p_events; emit_changed(); }

protected:
    static void _bind_methods();
};

#endif // GUIDE_TRIGGER_COMBO_CANCEL_ACTION_H
