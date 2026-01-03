#ifndef GUIDE_FORMATTING_UTILS_H
#define GUIDE_FORMATTING_UTILS_H

#include <godot_cpp/core/class_db.hpp>
#include <godot_cpp/classes/input.hpp>
#include "guide_input_formatting_options.h"
#include "../inputs/guide_input.h"
#include "../inputs/guide_input_joy_base.h"

using namespace godot;

class GUIDEFormattingUtils : public Object {
    GDCLASS(GUIDEFormattingUtils, Object)

public:
    enum ControllerType {
        CONTROLLER_UNKNOWN = 0,
        CONTROLLER_MICROSOFT = 1,
        CONTROLLER_NINTENDO = 2,
        CONTROLLER_SONY = 3,
    };

    static ControllerType effective_controller_type(const Ref<GUIDEInput> &input, const Ref<GUIDEInputFormattingOptions> &options) {
        if (Object::cast_to<GUIDEInputJoyBase>(input.ptr()) == nullptr) {
            return CONTROLLER_UNKNOWN;
        }

        if (options->get_joy_rendering() == GUIDEInputFormattingOptions::FORCE_JOY_TYPE) {
            return _controller_type_from_joy_type(options->get_preferred_joy_type());
        }

        ControllerType detected = _detect_controller_type(input);

        if (options->get_joy_rendering() == GUIDEInputFormattingOptions::PREFER_JOY_TYPE) {
            if (detected == CONTROLLER_UNKNOWN) {
                return _controller_type_from_joy_type(options->get_preferred_joy_type());
            }
        }

        return detected;
    }

    static ControllerType _detect_controller_type(const Ref<GUIDEInput> &input) {
        static Dictionary strings;
        if (strings.is_empty()) {
            strings[CONTROLLER_MICROSOFT] = Array::make("XBox", "XInput");
            strings[CONTROLLER_NINTENDO] = Array::make("Nintendo Switch");
            strings[CONTROLLER_SONY] = Array::make("DualSense", "DualShock", "PlayStation", "PS3", "PS4", "PS5");
        }

        String haystack = _joy_name_for_input(input).to_lower();
        if (haystack.is_empty()) return CONTROLLER_UNKNOWN;

        Array types = strings.keys();
        for (int i = 0; i < types.size(); i++) {
            ControllerType type = (ControllerType)(int)types[i];
            Array needles = strings[type];
            for (int j = 0; j < needles.size(); j++) {
                if (haystack.contains(((String)needles[j]).to_lower())) {
                    return type;
                }
            }
        }

        return CONTROLLER_UNKNOWN;
    }

    static ControllerType _controller_type_from_joy_type(GUIDEInputFormattingOptions::JoyType joy_type) {
        switch (joy_type) {
            case GUIDEInputFormattingOptions::MICROSOFT_CONTROLLER: return CONTROLLER_MICROSOFT;
            case GUIDEInputFormattingOptions::NINTENDO_CONTROLLER: return CONTROLLER_NINTENDO;
            case GUIDEInputFormattingOptions::SONY_CONTROLLER: return CONTROLLER_SONY;
            default: return CONTROLLER_UNKNOWN;
        }
    }

    static String _joy_name_for_input(const Ref<GUIDEInput> &input) {
        Ref<GUIDEInputJoyBase> joy_in = input;
        if (joy_in.is_null()) return "";

        Array joypads = Input::get_singleton()->get_connected_joypads();
        int joy_index = joy_in->get_joy_index();
        if (joy_index < 0) joy_index = 0;

        if (joypads.size() <= joy_index) return "";

        int id = joypads[joy_index];
        return Input::get_singleton()->get_joy_name(id);
    }

protected:
    static void _bind_methods() {
        BIND_ENUM_CONSTANT(CONTROLLER_UNKNOWN);
        BIND_ENUM_CONSTANT(CONTROLLER_MICROSOFT);
        BIND_ENUM_CONSTANT(CONTROLLER_NINTENDO);
        BIND_ENUM_CONSTANT(CONTROLLER_SONY);
    }
};

VARIANT_ENUM_CAST(GUIDEFormattingUtils::ControllerType);

#endif // GUIDE_FORMATTING_UTILS_H