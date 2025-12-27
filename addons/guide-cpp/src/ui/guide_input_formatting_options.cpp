#include "guide_input_formatting_options.h"

using namespace godot;

void GUIDEInputFormattingOptions::_bind_methods() {
    BIND_ENUM_CONSTANT(JOY_RENDERING_DEFAULT);
    BIND_ENUM_CONSTANT(JOY_RENDERING_PREFER_JOY_TYPE);
    BIND_ENUM_CONSTANT(JOY_RENDERING_FORCE_JOY_TYPE);

    BIND_ENUM_CONSTANT(JOY_TYPE_GENERIC_JOY);
    BIND_ENUM_CONSTANT(JOY_TYPE_MICROSOFT_CONTROLLER);
    BIND_ENUM_CONSTANT(JOY_TYPE_NINTENDO_CONTROLLER);
    BIND_ENUM_CONSTANT(JOY_TYPE_SONY_CONTROLLER);

    ClassDB::bind_method(D_METHOD("get_input_filter"), &GUIDEInputFormattingOptions::get_input_filter);
    ClassDB::bind_method(D_METHOD("set_input_filter", "filter"), &GUIDEInputFormattingOptions::set_input_filter);
    ADD_PROPERTY(PropertyInfo(Variant::CALLABLE, "input_filter"), "set_input_filter", "get_input_filter");

    ClassDB::bind_method(D_METHOD("get_joy_rendering"), &GUIDEInputFormattingOptions::get_joy_rendering);
    ClassDB::bind_method(D_METHOD("set_joy_rendering", "rendering"), &GUIDEInputFormattingOptions::set_joy_rendering);
    ADD_PROPERTY(PropertyInfo(Variant::INT, "joy_rendering", PROPERTY_HINT_ENUM, "DEFAULT,PREFER_JOY_TYPE,FORCE_JOY_TYPE"), "set_joy_rendering", "get_joy_rendering");

    ClassDB::bind_method(D_METHOD("get_preferred_joy_type"), &GUIDEInputFormattingOptions::get_preferred_joy_type);
    ClassDB::bind_method(D_METHOD("set_preferred_joy_type", "type"), &GUIDEInputFormattingOptions::set_preferred_joy_type);
    ADD_PROPERTY(PropertyInfo(Variant::INT, "preferred_joy_type", PROPERTY_HINT_ENUM, "GENERIC_JOY,MICROSOFT_CONTROLLER,NINTENDO_CONTROLLER,SONY_CONTROLLER"), "set_preferred_joy_type", "get_preferred_joy_type");
}

GUIDEInputFormattingOptions::GUIDEInputFormattingOptions() {
    input_filter = Callable(this, "default_input_filter");
}

GUIDEInputFormattingOptions::~GUIDEInputFormattingOptions() {}
