#include "guide_formatting_utils.h"
#include <godot_cpp/classes/input.hpp>
#include "../inputs/guide_input_joy_base.h"

using namespace godot;

Dictionary GUIDEFormattingUtils::_controller_detection_strings;

void GUIDEFormattingUtils::_bind_methods() {
    BIND_ENUM_CONSTANT(CONTROLLER_UNKNOWN);
    BIND_ENUM_CONSTANT(CONTROLLER_MICROSOFT);
    BIND_ENUM_CONSTANT(CONTROLLER_NINTENDO);
    BIND_ENUM_CONSTANT(CONTROLLER_SONY);
}

GUIDEFormattingUtils::ControllerType GUIDEFormattingUtils::effective_controller_type(const Ref<GUIDEInput> &input, const Ref<GUIDEInputFormattingOptions> &options) {
    if (Object::cast_to<GUIDEInputJoyBase>(input.ptr()) == nullptr) {
        return CONTROLLER_UNKNOWN;
    }

    if (options->get_joy_rendering() == GUIDEInputFormattingOptions::JOY_RENDERING_FORCE_JOY_TYPE) {
        return _controller_type_from_joy_type(options->get_preferred_joy_type());
    }

    ControllerType detected = _detect_controller_type(input);

    if (options->get_joy_rendering() == GUIDEInputFormattingOptions::JOY_RENDERING_PREFER_JOY_TYPE) {
        if (detected == CONTROLLER_UNKNOWN) {
            return _controller_type_from_joy_type(options->get_preferred_joy_type());
        }
    }

    return detected;
}

GUIDEFormattingUtils::ControllerType GUIDEFormattingUtils::_detect_controller_type(const Ref<GUIDEInput> &input) {
    if (_controller_detection_strings.is_empty()) {
        _controller_detection_strings[CONTROLLER_MICROSOFT] = Array::make("XBox", "XInput");
        _controller_detection_strings[CONTROLLER_NINTENDO] = Array::make("Nintendo Switch");
        _controller_detection_strings[CONTROLLER_SONY] = Array::make("DualSense", "DualShock", "PlayStation", "PS3", "PS4", "PS5");
    }

    String haystack = _joy_name_for_input(input).to_lower();
    if (haystack.is_empty()) return CONTROLLER_UNKNOWN;

    Array types = _controller_detection_strings.keys();
    for (int i = 0; i < types.size(); i++) {
        ControllerType type = (ControllerType)(int)types[i];
        Array needles = _controller_detection_strings[type];
        for (int j = 0; j < needles.size(); j++) {
            if (haystack.contains(((String)needles[j]).to_lower())) {
                return type;
            }
        }
    }

    return CONTROLLER_UNKNOWN;
}

GUIDEFormattingUtils::ControllerType GUIDEFormattingUtils::_controller_type_from_joy_type(GUIDEInputFormattingOptions::JoyType joy_type) {
    switch (joy_type) {
        case GUIDEInputFormattingOptions::JOY_TYPE_MICROSOFT_CONTROLLER: return CONTROLLER_MICROSOFT;
        case GUIDEInputFormattingOptions::JOY_TYPE_NINTENDO_CONTROLLER: return CONTROLLER_NINTENDO;
        case GUIDEInputFormattingOptions::JOY_TYPE_SONY_CONTROLLER: return CONTROLLER_SONY;
        default: return CONTROLLER_UNKNOWN;
    }
}

String GUIDEFormattingUtils::_joy_name_for_input(const Ref<GUIDEInput> &input) {
    Ref<GUIDEInputJoyBase> joy_in = input;
    if (joy_in.is_null()) return "";

    Array joypads = Input::get_singleton()->get_connected_joypads();
    int joy_index = joy_in->get_joy_index();
    if (joy_index < 0) joy_index = 0;

    if (joypads.size() <= joy_index) return "";

    int id = joypads[joy_index];
    return Input::get_singleton()->get_joy_name(id);
}
