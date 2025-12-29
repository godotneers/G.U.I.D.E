#ifndef GUIDE_TRIGGER_PULSE_H
#define GUIDE_TRIGGER_PULSE_H

#include "guide_trigger.h"

using namespace godot;

class GUIDETriggerPulse : public GUIDETrigger {
    GDCLASS(GUIDETriggerPulse, GUIDETrigger)

public:
    GUIDETriggerPulse();
    virtual ~GUIDETriggerPulse();

    virtual bool is_same_as(const Ref<GUIDETrigger> &other) const override;
    virtual GUIDETriggerState _update_state(Vector3 input, double delta, GUIDEAction::GUIDEActionValueType value_type) override;
    virtual String _editor_name() const override;
    virtual String _editor_description() const override;

    bool get_trigger_on_start() const { return trigger_on_start; }
    void set_trigger_on_start(bool p_val) { trigger_on_start = p_val; emit_changed(); }

    double get_initial_delay() const { return initial_delay; }
    void set_initial_delay(double p_val) { initial_delay = std::max(0.0, p_val); emit_changed(); }

    double get_pulse_interval() const { return pulse_interval; }
    void set_pulse_interval(double p_val) { pulse_interval = std::max(0.0, p_val); emit_changed(); }

    int get_max_pulses() const { return max_pulses; }
    void set_max_pulses(int p_val) { max_pulses = p_val; emit_changed(); }

protected:
    static void _bind_methods();

    bool trigger_on_start = true;
    double initial_delay = 0.3;
    double pulse_interval = 0.1;
    int max_pulses = 0;

    double _delay_until_next_pulse = 0.0;
    int _emitted_pulses = 0;
};

#endif // GUIDE_TRIGGER_PULSE_H