#ifndef GUIDE_FORMATTING_UTILS_H
#define GUIDE_FORMATTING_UTILS_H

#include <godot_cpp/core/class_db.hpp>
#include "guide_input_formatting_options.h"
#include "../inputs/guide_input.h"

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

    static ControllerType effective_controller_type(const Ref<GUIDEInput> &input, const Ref<GUIDEInputFormattingOptions> &options);
    static ControllerType _detect_controller_type(const Ref<GUIDEInput> &input);
    static ControllerType _controller_type_from_joy_type(GUIDEInputFormattingOptions::JoyType joy_type);
    static String _joy_name_for_input(const Ref<GUIDEInput> &input);

protected:
    static void _bind_methods();

private:
    static Dictionary _controller_detection_strings;
};

VARIANT_ENUM_CAST(GUIDEFormattingUtils::ControllerType);

#endif // GUIDE_FORMATTING_UTILS_H
