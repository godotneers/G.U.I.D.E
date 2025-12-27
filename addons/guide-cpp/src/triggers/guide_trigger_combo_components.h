#ifndef GUIDE_TRIGGER_COMBO_COMPONENTS_H
#define GUIDE_TRIGGER_COMBO_COMPONENTS_H

#include <godot_cpp/classes/resource.hpp>
#include <godot_cpp/core/class_db.hpp>
#include "../guide_action.h"

using namespace godot;

class GUIDETriggerComboStep : public Resource {
    GDCLASS(GUIDETriggerComboStep, Resource)
public:
    Ref<GUIDEAction> action;
    int completion_events = 1; // TRIGGERED
    double time_to_actuate = 0.5;
    bool _has_fired = false;

    GUIDETriggerComboStep() {}
    virtual ~GUIDETriggerComboStep() {}

    void _prepare();
    void _fired() { _has_fired = true; }
    bool is_same_as(const Ref<GUIDETriggerComboStep> &other) const;

protected:
    static void _bind_methods();
};

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

protected:
    static void _bind_methods();
};

#endif // GUIDE_TRIGGER_COMBO_COMPONENTS_H
