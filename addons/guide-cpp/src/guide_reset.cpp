#include "guide_reset.h"
#include "guide.h"

using namespace godot;

void GUIDEReset::_bind_methods() {
}

GUIDEReset::GUIDEReset() {
}

GUIDEReset::~GUIDEReset() {
}

void GUIDEReset::_notification(int p_what) {
    if (p_what == NOTIFICATION_ENTER_TREE) {
        set_process_priority(10000000);
    }
}

void GUIDEReset::_process(double delta) {
    for (int i = 0; i < _inputs_to_reset.size(); i++) {
        Ref<GUIDEInput> input = _inputs_to_reset[i];
        if (input.is_valid()) {
            input->_reset();
        }
    }
    
    // We need a way to access the GUIDE singleton's input state.
    // Assuming GUIDE is a singleton named GUIDE.
    GUIDECpp::get_singleton()->get_input_state()->_reset();
}