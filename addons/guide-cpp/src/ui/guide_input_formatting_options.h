#ifndef GUIDE_INPUT_FORMATTING_OPTIONS_H
#define GUIDE_INPUT_FORMATTING_OPTIONS_H

#include <godot_cpp/classes/resource.hpp>
#include <godot_cpp/variant/callable.hpp>
#include <godot_cpp/core/class_db.hpp>

using namespace godot;

class GUIDEInputFormattingOptions : public Resource {
    GDCLASS(GUIDEInputFormattingOptions, Resource)

public:
    enum JoyRendering {
        DEFAULT = 0,
        PREFER_JOY_TYPE = 1,
        FORCE_JOY_TYPE = 2
    };

    enum JoyType {
        GENERIC_JOY = 0,
        MICROSOFT_CONTROLLER = 1,
        NINTENDO_CONTROLLER = 2,
        SONY_CONTROLLER = 3
    };

    GUIDEInputFormattingOptions() {
        input_filter = Callable(this, "default_input_filter");
    }
    
    virtual ~GUIDEInputFormattingOptions() {}

    // Getters and Setters
    Callable get_input_filter() const { return input_filter; }
    void set_input_filter(const Callable &p_filter) { input_filter = p_filter; }

    JoyRendering get_joy_rendering() const { return joy_rendering; }
    void set_joy_rendering(JoyRendering p_rendering) { joy_rendering = p_rendering; }

    JoyType get_preferred_joy_type() const { return preferred_joy_type; }
    void set_preferred_joy_type(JoyType p_type) { preferred_joy_type = p_type; }

    static bool default_input_filter(const Variant &p_context) { return true; }

protected:
    static void _bind_methods() {
        BIND_ENUM_CONSTANT(DEFAULT);
        BIND_ENUM_CONSTANT(PREFER_JOY_TYPE);
        BIND_ENUM_CONSTANT(FORCE_JOY_TYPE);

        BIND_ENUM_CONSTANT(GENERIC_JOY);
        BIND_ENUM_CONSTANT(MICROSOFT_CONTROLLER);
        BIND_ENUM_CONSTANT(NINTENDO_CONTROLLER);
        BIND_ENUM_CONSTANT(SONY_CONTROLLER);

        ClassDB::bind_method(D_METHOD("get_input_filter"), &GUIDEInputFormattingOptions::get_input_filter);
        ClassDB::bind_method(D_METHOD("set_input_filter", "filter"), &GUIDEInputFormattingOptions::set_input_filter);
        ADD_PROPERTY(PropertyInfo(Variant::CALLABLE, "input_filter"), "set_input_filter", "get_input_filter");

        ClassDB::bind_method(D_METHOD("get_joy_rendering"), &GUIDEInputFormattingOptions::get_joy_rendering);
        ClassDB::bind_method(D_METHOD("set_joy_rendering", "rendering"), &GUIDEInputFormattingOptions::set_joy_rendering);
        ADD_PROPERTY(PropertyInfo(Variant::INT, "joy_rendering", PROPERTY_HINT_ENUM, "DEFAULT,PREFER_JOY_TYPE,FORCE_JOY_TYPE"), "set_joy_rendering", "get_joy_rendering");

        ClassDB::bind_method(D_METHOD("get_preferred_joy_type"), &GUIDEInputFormattingOptions::get_preferred_joy_type);
        ClassDB::bind_method(D_METHOD("set_preferred_joy_type", "type"), &GUIDEInputFormattingOptions::set_preferred_joy_type);
        ADD_PROPERTY(PropertyInfo(Variant::INT, "preferred_joy_type", PROPERTY_HINT_ENUM, "GENERIC_JOY,MICROSOFT_CONTROLLER,NINTENDO_CONTROLLER,SONY_CONTROLLER"), "set_preferred_joy_type", "get_preferred_joy_type");

        ClassDB::bind_static_method("GUIDEInputFormattingOptions", D_METHOD("default_input_filter", "context"), &GUIDEInputFormattingOptions::default_input_filter);
    }

private:
    Callable input_filter;
    JoyRendering joy_rendering = DEFAULT;
    JoyType preferred_joy_type = GENERIC_JOY;
};

VARIANT_ENUM_CAST(GUIDEInputFormattingOptions::JoyRendering);
VARIANT_ENUM_CAST(GUIDEInputFormattingOptions::JoyType);

#endif // GUIDE_INPUT_FORMATTING_OPTIONS_H