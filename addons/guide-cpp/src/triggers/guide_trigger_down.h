#ifndef GUIDE_TRIGGER_DOWN_H
#define GUIDE_TRIGGER_DOWN_H

#include "guide_trigger.h"

using namespace godot;

class GUIDETriggerDown : public GUIDETrigger {
    GDCLASS(GUIDETriggerDown, GUIDETrigger)

public:
    GUIDETriggerDown();
    virtual ~GUIDETriggerDown();

    virtual bool is_same_as(const Ref<GUIDETrigger> &other) const override;
    virtual GUIDETriggerState _update_state(Vector3 input, double delta, int value_type) override;
    virtual String _editor_name() const override;
    virtual String _editor_description() const override;

protected:
    static void _bind_methods();
};

#endif // GUIDE_TRIGGER_DOWN_H