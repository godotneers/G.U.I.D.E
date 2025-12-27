#ifndef GUIDE_INPUT_FORMATTING_OPTIONS_H
#define GUIDE_INPUT_FORMATTING_OPTIONS_H

#include <godot_cpp/core/class_db.hpp>
#include <godot_cpp/variant/callable.hpp>
#include <godot_cpp/classes/ref_counted.hpp>

using namespace godot;

class GUIDEInputFormattingOptions : public RefCounted {
    GDCLASS(GUIDEInputFormattingOptions, RefCounted)

public:
    enum JoyRendering {
        JOY_RENDERING_DEFAULT = 0,
        JOY_RENDERING_PREFER_JOY_TYPE = 1,
        JOY_RENDERING_FORCE_JOY_TYPE = 2,
    };

    enum JoyType {
        JOY_TYPE_GENERIC_JOY = 0,
        JOY_TYPE_MICROSOFT_CONTROLLER = 1,
        JOY_TYPE_NINTENDO_CONTROLLER = 2,
        JOY_TYPE_SONY_CONTROLLER = 3
    };

    GUIDEInputFormattingOptions();
    virtual ~GUIDEInputFormattingOptions();

    static bool default_input_filter(const Variant &context) { return true; }

    Callable get_input_filter() const { return input_filter; }
    void set_input_filter(const Callable &p_filter) { input_filter = p_filter; }

    JoyRendering get_joy_rendering() const { return joy_rendering; }
    void set_joy_rendering(JoyRendering p_rendering) { joy_rendering = p_rendering; }

    JoyType get_preferred_joy_type() const { return preferred_joy_type; }
    void set_preferred_joy_type(JoyType p_type) { preferred_joy_type = p_type; }

protected:
    static void _bind_methods();

private:
    Callable input_filter;
    JoyRendering joy_rendering = JOY_RENDERING_DEFAULT;
    JoyType preferred_joy_type = JOY_TYPE_GENERIC_JOY;
};

VARIANT_ENUM_CAST(GUIDEInputFormattingOptions::JoyRendering);
VARIANT_ENUM_CAST(GUIDEInputFormattingOptions::JoyType);

#endif // GUIDE_INPUT_FORMATTING_OPTIONS_H