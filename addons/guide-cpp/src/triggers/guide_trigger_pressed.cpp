#include "guide_trigger_pressed.h"

using namespace godot;

void GUIDETriggerPressed::_bind_methods() {
}

GUIDETriggerPressed::GUIDETriggerPressed() {
}

GUIDETriggerPressed::~GUIDETriggerPressed() {
}

bool GUIDETriggerPressed::is_same_as(const Ref<GUIDETrigger> &other) const {
    return other.is_valid() && other->get_class() == get_class();
}

GUIDETrigger::GUIDETriggerState GUIDETriggerPressed::_update_state(Vector3 input, double delta, int value_type) {
    if (_is_actuated(input, value_type)) {
        if (!_is_actuated(get_last_value(), value_type)) {
            return TRIGGERED;
        }
    }
    return NONE;
}

String GUIDETriggerPressed::_editor_name() const {
    return "Pressed";
}

String GUIDETriggerPressed::_editor_description() const {
    return "Fires once, when the input exceeds actuation threshold. Holding the input\nwill not fire additional triggers.";
}
