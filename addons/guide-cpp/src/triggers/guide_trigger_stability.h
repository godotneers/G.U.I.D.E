#ifndef GUIDE_TRIGGER_STABILITY_H
#define GUIDE_TRIGGER_STABILITY_H

#include "guide_trigger.h"

using namespace godot;

class GUIDETriggerStability : public GUIDETrigger {
    GDCLASS(GUIDETriggerStability, GUIDETrigger)

public:
    enum TriggerWhen {
        INPUT_IS_STABLE,
        INPUT_CHANGES
    };

    GUIDETriggerStability();
    virtual ~GUIDETriggerStability();

    virtual bool is_same_as(const Ref<GUIDETrigger> &other) const override;
    virtual GUIDETriggerType _get_trigger_type() const override;
    virtual GUIDETriggerState _update_state(Vector3 input, double delta, GUIDEAction::GUIDEActionValueType value_type) override;
    
    virtual String _editor_name() const override;
    virtual String _editor_description() const override;

    double get_max_deviation() const { return max_deviation; }
    void set_max_deviation(double p_val) { max_deviation = p_val; emit_changed(); }

    TriggerWhen get_trigger_when() const { return trigger_when; }
    void set_trigger_when(TriggerWhen p_val) { trigger_when = p_val; emit_changed(); }

protected:
    static void _bind_methods();

    double max_deviation = 1.0;
    TriggerWhen trigger_when = INPUT_IS_STABLE;

    Vector3 _initial_value;
    bool _deviated = false;
};

VARIANT_ENUM_CAST(GUIDETriggerStability::TriggerWhen);

#endif // GUIDE_TRIGGER_STABILITY_H