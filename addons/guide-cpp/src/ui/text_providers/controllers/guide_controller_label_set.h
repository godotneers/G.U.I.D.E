#ifndef GUIDE_CONTROLLER_LABEL_SET_H
#define GUIDE_CONTROLLER_LABEL_SET_H

#include <godot_cpp/classes/resource.hpp>

using namespace godot;

class GUIDEControllerLabelSet : public Resource {
    GDCLASS(GUIDEControllerLabelSet, Resource)

public:
    GUIDEControllerLabelSet() {}
    virtual ~GUIDEControllerLabelSet() {}

    String a_button = "";
    String b_button = "";
    String x_button = "";
    String y_button = "";

    String left_stick = "Left Stick";
    String left_stick_click = "";
    String right_stick = "Right Stick";
    String right_stick_click = "";

    String left_bumper = "";
    String right_bumper = "";
    String left_trigger = "";
    String right_trigger = "";

    String dpad_up = "DPAD Up";
    String dpad_left = "DPAD Left";
    String dpad_right = "DPAD Right";
    String dpad_down = "DPAD Down";

    String start = "";
    String misc1 = "";
    String back = "";
    String touch_pad = "";

    String left_stick_horizontal_movement = "Left Stick Horizontal";
    String left_stick_vertical_movement = "Left Stick Vertical";
    String right_stick_horizontal_movement = "Right Stick Horizontal";
    String right_stick_vertical_movement = "Right Stick Vertical";

protected:
    static void _bind_methods() {
        #define BIND_PROP(name) \
            ClassDB::bind_method(D_METHOD("get_" #name), &GUIDEControllerLabelSet::get_##name); \
            ClassDB::bind_method(D_METHOD("set_" #name, "val"), &GUIDEControllerLabelSet::set_##name); \
            ADD_PROPERTY(PropertyInfo(Variant::STRING, #name), "set_" #name, "get_" #name);

        BIND_PROP(a_button)
        BIND_PROP(b_button)
        BIND_PROP(x_button)
        BIND_PROP(y_button)
        BIND_PROP(left_stick)
        BIND_PROP(left_stick_click)
        BIND_PROP(right_stick)
        BIND_PROP(right_stick_click)
        BIND_PROP(left_bumper)
        BIND_PROP(right_bumper)
        BIND_PROP(left_trigger)
        BIND_PROP(right_trigger)
        BIND_PROP(dpad_up)
        BIND_PROP(dpad_left)
        BIND_PROP(dpad_right)
        BIND_PROP(dpad_down)
        BIND_PROP(start)
        BIND_PROP(misc1)
        BIND_PROP(back)
        BIND_PROP(touch_pad)
        BIND_PROP(left_stick_horizontal_movement)
        BIND_PROP(left_stick_vertical_movement)
        BIND_PROP(right_stick_horizontal_movement)
        BIND_PROP(right_stick_vertical_movement)
        #undef BIND_PROP
    }

private:
    #define DEF_GET_SET(name) \
        String get_##name() const { return name; } \
        void set_##name(const String& p_val) { name = p_val; }

    DEF_GET_SET(a_button)
    DEF_GET_SET(b_button)
    DEF_GET_SET(x_button)
    DEF_GET_SET(y_button)
    DEF_GET_SET(left_stick)
    DEF_GET_SET(left_stick_click)
    DEF_GET_SET(right_stick)
    DEF_GET_SET(right_stick_click)
    DEF_GET_SET(left_bumper)
    DEF_GET_SET(right_bumper)
    DEF_GET_SET(left_trigger)
    DEF_GET_SET(right_trigger)
    DEF_GET_SET(dpad_up)
    DEF_GET_SET(dpad_left)
    DEF_GET_SET(dpad_right)
    DEF_GET_SET(dpad_down)
    DEF_GET_SET(start)
    DEF_GET_SET(misc1)
    DEF_GET_SET(back)
    DEF_GET_SET(touch_pad)
    DEF_GET_SET(left_stick_horizontal_movement)
    DEF_GET_SET(left_stick_vertical_movement)
    DEF_GET_SET(right_stick_horizontal_movement)
    DEF_GET_SET(right_stick_vertical_movement)
    #undef DEF_GET_SET
};

#endif // GUIDE_CONTROLLER_LABEL_SET_H
