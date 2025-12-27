#ifndef GUIDE_TRIGGER_HOLD_H
#define GUIDE_TRIGGER_HOLD_H

#include "guide_trigger.h"

using namespace godot;

class GUIDETriggerHold : public GUIDETrigger {
    GDCLASS(GUIDETriggerHold, GUIDETrigger)

public:
    GUIDETriggerHold();
    virtual ~GUIDETriggerHold();

    virtual bool is_same_as(const Ref<GUIDETrigger> &other) const override;
    virtual GUIDETriggerState _update_state(Vector3 input, double delta, int value_type) override;
    virtual String _editor_name() const override;
    virtual String _editor_description() const override;

    double get_hold_threshold() const { return hold_threshold; }
    void set_hold_threshold(double p_threshold) { hold_threshold = p_threshold; emit_changed(); }

    bool get_is_one_shot() const { return is_one_shot; }
    void set_is_one_shot(bool p_one_shot) { is_one_shot = p_one_shot; emit_changed(); }

protected:
    static void _bind_methods();

    double hold_threshold = 1.0;
    bool is_one_shot = false;

    double _accumulated_time = 0.0;
    bool _did_shoot = false;
};

#endif // GUIDE_TRIGGER_HOLD_H