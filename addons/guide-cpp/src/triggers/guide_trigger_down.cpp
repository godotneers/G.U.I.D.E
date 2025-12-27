#include "guide_trigger_down.h"

using namespace godot;

void GUIDETriggerDown::_bind_methods() {
}

GUIDETriggerDown::GUIDETriggerDown() {
}

GUIDETriggerDown::~GUIDETriggerDown() {
}

bool GUIDETriggerDown::is_same_as(const Ref<GUIDETrigger> &other) const {
    return other.is_valid() && other->get_class() == get_class();
}

GUIDETrigger::GUIDETriggerState GUIDETriggerDown::_update_state(Vector3 input, double delta, int value_type) {
    if (_is_actuated(input, value_type)) {
        return TRIGGERED;
    }
    return NONE;
}

String GUIDETriggerDown::_editor_name() const {
    return "Down";
}

String GUIDETriggerDown::_editor_description() const {
    return "Fires, when the input exceeds the actuation threshold. This is\nthe default trigger when no trigger is specified.";
}

} // namespace godot
