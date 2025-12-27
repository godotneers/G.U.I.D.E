#ifndef GUIDE_TRIGGER_TAP_H
#define GUIDE_TRIGGER_TAP_H

#include "guide_trigger.h"

using namespace godot;

class GUIDETriggerTap : public GUIDETrigger {
    GDCLASS(GUIDETriggerTap, GUIDETrigger)

public:
    GUIDETriggerTap();
    virtual ~GUIDETriggerTap();

    virtual bool is_same_as(const Ref<GUIDETrigger> &other) const override;
    virtual GUIDETriggerState _update_state(Vector3 input, double delta, int value_type) override;
    virtual String _editor_name() const override;
    virtual String _editor_description() const override;

    double get_tap_threshold() const { return tap_threshold; }
    void set_tap_threshold(double p_value) { tap_threshold = p_value; emit_changed(); }

protected:
    static void _bind_methods();

    double tap_threshold = 0.2;
    double _accumulated_time = 0.0;
};

#endif // GUIDE_TRIGGER_TAP_H