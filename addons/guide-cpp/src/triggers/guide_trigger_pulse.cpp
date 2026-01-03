#include "guide_trigger_pulse.h"
#include <godot_cpp/core/math.hpp>
#include <algorithm>
#include <cmath>

using namespace godot;

void GUIDETriggerPulse::_bind_methods() {
    ClassDB::bind_method(D_METHOD("get_trigger_on_start"), &GUIDETriggerPulse::get_trigger_on_start);
    ClassDB::bind_method(D_METHOD("set_trigger_on_start", "val"), &GUIDETriggerPulse::set_trigger_on_start);
    ADD_PROPERTY(PropertyInfo(Variant::BOOL, "trigger_on_start"), "set_trigger_on_start", "get_trigger_on_start");

    ClassDB::bind_method(D_METHOD("get_initial_delay"), &GUIDETriggerPulse::get_initial_delay);
    ClassDB::bind_method(D_METHOD("set_initial_delay", "val"), &GUIDETriggerPulse::set_initial_delay);
    ADD_PROPERTY(PropertyInfo(Variant::FLOAT, "initial_delay"), "set_initial_delay", "get_initial_delay");

    ClassDB::bind_method(D_METHOD("get_pulse_interval"), &GUIDETriggerPulse::get_pulse_interval);
    ClassDB::bind_method(D_METHOD("set_pulse_interval", "val"), &GUIDETriggerPulse::set_pulse_interval);
    ADD_PROPERTY(PropertyInfo(Variant::FLOAT, "pulse_interval"), "set_pulse_interval", "get_pulse_interval");

    ClassDB::bind_method(D_METHOD("get_max_pulses"), &GUIDETriggerPulse::get_max_pulses);
    ClassDB::bind_method(D_METHOD("set_max_pulses", "val"), &GUIDETriggerPulse::set_max_pulses);
    ADD_PROPERTY(PropertyInfo(Variant::INT, "max_pulses"), "set_max_pulses", "get_max_pulses");
}

GUIDETriggerPulse::GUIDETriggerPulse() {
}

GUIDETriggerPulse::~GUIDETriggerPulse() {
}

bool GUIDETriggerPulse::is_same_as(const Ref<GUIDETrigger> &other) const {
    Ref<GUIDETriggerPulse> o = other;
    if (o.is_null()) return false;
    return Math::is_equal_approx(o->get_initial_delay(), initial_delay) &&
           Math::is_equal_approx(o->get_pulse_interval(), pulse_interval) &&
           o->get_max_pulses() == max_pulses &&
           o->get_trigger_on_start() == trigger_on_start;
}

GUIDETrigger::GUIDETriggerState GUIDETriggerPulse::_update_state(Vector3 input, double delta, GUIDEAction::GUIDEActionValueType value_type) {
    if (_is_actuated(input, value_type)) {
        if (!_is_actuated(get_last_value(), value_type)) {
            // we went from "not actuated" to actuated, pulsing starts
            _delay_until_next_pulse = initial_delay;
            _emitted_pulses = 0;
            if (trigger_on_start) {
                return TRIGGERED;
            } else {
                return ONGOING;
            }
        }

        // if we already are pulsing and have exceeded the maximum number of pulses, we will not pulse anymore.
        if (max_pulses > 0 && _emitted_pulses >= max_pulses) {
            return NONE;	
        }
        
        // subtract the delta from the delay until the next pulse
        _delay_until_next_pulse -= delta;
        
        if (_delay_until_next_pulse > 0) {
            // we are still waiting for the next pulse, nothing to do.
            return ONGOING;
        }
        
        // now delta could be larger than our pulse, in which case we loose a few pulses.
        // as we can pulse at most once per frame.

        // in case someone sets the pulse interval to 0, we will pulse every frame.
        if (Math::is_equal_approx(pulse_interval, 0.0)) {
            _delay_until_next_pulse = 0;
            if (max_pulses > 0) {
                _emitted_pulses += 1;
            }
            return TRIGGERED;
        }
            
        // Now add the delay until the next pulse
        _delay_until_next_pulse += pulse_interval;
        
        // If the interval is really small, we can potentially have skipped some pulses
        if (_delay_until_next_pulse <= 0) { 
            // we have skipped some pulses
            int skipped_pulses = (int)(-_delay_until_next_pulse / pulse_interval);
            _delay_until_next_pulse += skipped_pulses * pulse_interval;
            if (max_pulses > 0) {
                _emitted_pulses += skipped_pulses;
                if (_emitted_pulses >= max_pulses) {
                    return NONE;
                }
            }
        }
        
        // Record a pulse and return triggered
        if (max_pulses > 0) {
            _emitted_pulses += 1;
        }
        return TRIGGERED;
    }

    _emitted_pulses = 0;
    _delay_until_next_pulse = 0;
    return NONE;
}

String GUIDETriggerPulse::_editor_name() const {
    return "Pulse";
}

String GUIDETriggerPulse::_editor_description() const {
    return "Fires at an interval while the input is actuated.";
}