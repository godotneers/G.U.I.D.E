#ifndef GUIDE_TRIGGER_PRESSED_H
#define GUIDE_TRIGGER_PRESSED_H

#include "guide_trigger.h"

using namespace godot;

class GUIDETriggerPressed : public GUIDETrigger {
    GDCLASS(GUIDETriggerPressed, GUIDETrigger)

public:
    GUIDETriggerPressed();
    virtual ~GUIDETriggerPressed();

    virtual bool is_same_as(const Ref<GUIDETrigger> &other) const override;
    virtual GUIDETriggerState _update_state(Vector3 input, double delta, GUIDEAction::GUIDEActionValueType value_type) override;
    virtual String _editor_name() const override;
    virtual String _editor_description() const override;

protected:
    static void _bind_methods();
};

#endif // GUIDE_TRIGGER_PRESSED_H