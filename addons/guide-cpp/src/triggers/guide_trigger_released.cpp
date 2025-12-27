#include "guide_trigger_released.h"

using namespace godot;

void GUIDETriggerReleased::_bind_methods() {
}

GUIDETriggerReleased::GUIDETriggerReleased() {
}

GUIDETriggerReleased::~GUIDETriggerReleased() {
}

bool GUIDETriggerReleased::is_same_as(const Ref<GUIDETrigger> &other) const {
    return other.is_valid() && other->get_class() == get_class();
}

GUIDETrigger::GUIDETriggerState GUIDETriggerReleased::_update_state(Vector3 input, double delta, int value_type) {
    if (!_is_actuated(input, value_type)) {
        if (_is_actuated(get_last_value(), value_type)) {
            return TRIGGERED;
        }
    }
    return NONE;
}

String GUIDETriggerReleased::_editor_name() const {
    return "Released";
}

String GUIDETriggerReleased::_editor_description() const {
    return "Fires once, when the input goes from actuated to not actuated. The opposite of the Pressed trigger.";
}
