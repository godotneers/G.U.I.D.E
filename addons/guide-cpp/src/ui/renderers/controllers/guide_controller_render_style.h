#ifndef GUIDE_CONTROLLER_RENDER_STYLE_H
#define GUIDE_CONTROLLER_RENDER_STYLE_H

#include <godot_cpp/classes/resource.hpp>
#include <godot_cpp/classes/texture2d.hpp>

using namespace godot;

class GUIDEControllerRenderStyle : public Resource {
    GDCLASS(GUIDEControllerRenderStyle, Resource)

public:
    GUIDEControllerRenderStyle() {}
    virtual ~GUIDEControllerRenderStyle() {}

    Ref<Texture2D> a_button;
    Ref<Texture2D> b_button;
    Ref<Texture2D> x_button;
    Ref<Texture2D> y_button;
    Ref<Texture2D> left_stick;
    Ref<Texture2D> left_stick_click;
    Ref<Texture2D> right_stick;
    Ref<Texture2D> right_stick_click;
    Ref<Texture2D> left_bumper;
    Ref<Texture2D> right_bumper;
    Ref<Texture2D> left_trigger;
    Ref<Texture2D> right_trigger;
    Ref<Texture2D> dpad_up;
    Ref<Texture2D> dpad_left;
    Ref<Texture2D> dpad_right;
    Ref<Texture2D> dpad_down;
    Ref<Texture2D> start;
    Ref<Texture2D> misc1;
    Ref<Texture2D> back;
    Ref<Texture2D> touch_pad;
    Ref<Texture2D> horizontal;
    Ref<Texture2D> vertical;

protected:
    static void _bind_methods() {
        ClassDB::bind_method(D_METHOD("get_a_button"), &GUIDEControllerRenderStyle::get_a_button);
        ClassDB::bind_method(D_METHOD("set_a_button", "val"), &GUIDEControllerRenderStyle::set_a_button);
        ADD_PROPERTY(PropertyInfo(Variant::OBJECT, "a_button", PROPERTY_HINT_RESOURCE_TYPE, "Texture2D"), "set_a_button", "get_a_button");

        ClassDB::bind_method(D_METHOD("get_b_button"), &GUIDEControllerRenderStyle::get_b_button);
        ClassDB::bind_method(D_METHOD("set_b_button", "val"), &GUIDEControllerRenderStyle::set_b_button);
        ADD_PROPERTY(PropertyInfo(Variant::OBJECT, "b_button", PROPERTY_HINT_RESOURCE_TYPE, "Texture2D"), "set_b_button", "get_b_button");

        ClassDB::bind_method(D_METHOD("get_x_button"), &GUIDEControllerRenderStyle::get_x_button);
        ClassDB::bind_method(D_METHOD("set_x_button", "val"), &GUIDEControllerRenderStyle::set_x_button);
        ADD_PROPERTY(PropertyInfo(Variant::OBJECT, "x_button", PROPERTY_HINT_RESOURCE_TYPE, "Texture2D"), "set_x_button", "get_x_button");

        ClassDB::bind_method(D_METHOD("get_y_button"), &GUIDEControllerRenderStyle::get_y_button);
        ClassDB::bind_method(D_METHOD("set_y_button", "val"), &GUIDEControllerRenderStyle::set_y_button);
        ADD_PROPERTY(PropertyInfo(Variant::OBJECT, "y_button", PROPERTY_HINT_RESOURCE_TYPE, "Texture2D"), "set_y_button", "get_y_button");

        ClassDB::bind_method(D_METHOD("get_left_stick"), &GUIDEControllerRenderStyle::get_left_stick);
        ClassDB::bind_method(D_METHOD("set_left_stick", "val"), &GUIDEControllerRenderStyle::set_left_stick);
        ADD_PROPERTY(PropertyInfo(Variant::OBJECT, "left_stick", PROPERTY_HINT_RESOURCE_TYPE, "Texture2D"), "set_left_stick", "get_left_stick");

        ClassDB::bind_method(D_METHOD("get_left_stick_click"), &GUIDEControllerRenderStyle::get_left_stick_click);
        ClassDB::bind_method(D_METHOD("set_left_stick_click", "val"), &GUIDEControllerRenderStyle::set_left_stick_click);
        ADD_PROPERTY(PropertyInfo(Variant::OBJECT, "left_stick_click", PROPERTY_HINT_RESOURCE_TYPE, "Texture2D"), "set_left_stick_click", "get_left_stick_click");

        ClassDB::bind_method(D_METHOD("get_right_stick"), &GUIDEControllerRenderStyle::get_right_stick);
        ClassDB::bind_method(D_METHOD("set_right_stick", "val"), &GUIDEControllerRenderStyle::set_right_stick);
        ADD_PROPERTY(PropertyInfo(Variant::OBJECT, "right_stick", PROPERTY_HINT_RESOURCE_TYPE, "Texture2D"), "set_right_stick", "get_right_stick");

        ClassDB::bind_method(D_METHOD("get_right_stick_click"), &GUIDEControllerRenderStyle::get_right_stick_click);
        ClassDB::bind_method(D_METHOD("set_right_stick_click", "val"), &GUIDEControllerRenderStyle::set_right_stick_click);
        ADD_PROPERTY(PropertyInfo(Variant::OBJECT, "right_stick_click", PROPERTY_HINT_RESOURCE_TYPE, "Texture2D"), "set_right_stick_click", "get_right_stick_click");

        ClassDB::bind_method(D_METHOD("get_left_bumper"), &GUIDEControllerRenderStyle::get_left_bumper);
        ClassDB::bind_method(D_METHOD("set_left_bumper", "val"), &GUIDEControllerRenderStyle::set_left_bumper);
        ADD_PROPERTY(PropertyInfo(Variant::OBJECT, "left_bumper", PROPERTY_HINT_RESOURCE_TYPE, "Texture2D"), "set_left_bumper", "get_left_bumper");

        ClassDB::bind_method(D_METHOD("get_right_bumper"), &GUIDEControllerRenderStyle::get_right_bumper);
        ClassDB::bind_method(D_METHOD("set_right_bumper", "val"), &GUIDEControllerRenderStyle::set_right_bumper);
        ADD_PROPERTY(PropertyInfo(Variant::OBJECT, "right_bumper", PROPERTY_HINT_RESOURCE_TYPE, "Texture2D"), "set_right_bumper", "get_right_bumper");

        ClassDB::bind_method(D_METHOD("get_left_trigger"), &GUIDEControllerRenderStyle::get_left_trigger);
        ClassDB::bind_method(D_METHOD("set_left_trigger", "val"), &GUIDEControllerRenderStyle::set_left_trigger);
        ADD_PROPERTY(PropertyInfo(Variant::OBJECT, "left_trigger", PROPERTY_HINT_RESOURCE_TYPE, "Texture2D"), "set_left_trigger", "get_left_trigger");

        ClassDB::bind_method(D_METHOD("get_right_trigger"), &GUIDEControllerRenderStyle::get_right_trigger);
        ClassDB::bind_method(D_METHOD("set_right_trigger", "val"), &GUIDEControllerRenderStyle::set_right_trigger);
        ADD_PROPERTY(PropertyInfo(Variant::OBJECT, "right_trigger", PROPERTY_HINT_RESOURCE_TYPE, "Texture2D"), "set_right_trigger", "get_right_trigger");

        ClassDB::bind_method(D_METHOD("get_dpad_up"), &GUIDEControllerRenderStyle::get_dpad_up);
        ClassDB::bind_method(D_METHOD("set_dpad_up", "val"), &GUIDEControllerRenderStyle::set_dpad_up);
        ADD_PROPERTY(PropertyInfo(Variant::OBJECT, "dpad_up", PROPERTY_HINT_RESOURCE_TYPE, "Texture2D"), "set_dpad_up", "get_dpad_up");

        ClassDB::bind_method(D_METHOD("get_dpad_left"), &GUIDEControllerRenderStyle::get_dpad_left);
        ClassDB::bind_method(D_METHOD("set_dpad_left", "val"), &GUIDEControllerRenderStyle::set_dpad_left);
        ADD_PROPERTY(PropertyInfo(Variant::OBJECT, "dpad_left", PROPERTY_HINT_RESOURCE_TYPE, "Texture2D"), "set_dpad_left", "get_dpad_left");

        ClassDB::bind_method(D_METHOD("get_dpad_right"), &GUIDEControllerRenderStyle::get_dpad_right);
        ClassDB::bind_method(D_METHOD("set_dpad_right", "val"), &GUIDEControllerRenderStyle::set_dpad_right);
        ADD_PROPERTY(PropertyInfo(Variant::OBJECT, "dpad_right", PROPERTY_HINT_RESOURCE_TYPE, "Texture2D"), "set_dpad_right", "get_dpad_right");

        ClassDB::bind_method(D_METHOD("get_dpad_down"), &GUIDEControllerRenderStyle::get_dpad_down);
        ClassDB::bind_method(D_METHOD("set_dpad_down", "val"), &GUIDEControllerRenderStyle::set_dpad_down);
        ADD_PROPERTY(PropertyInfo(Variant::OBJECT, "dpad_down", PROPERTY_HINT_RESOURCE_TYPE, "Texture2D"), "set_dpad_down", "get_dpad_down");

        ClassDB::bind_method(D_METHOD("get_start"), &GUIDEControllerRenderStyle::get_start);
        ClassDB::bind_method(D_METHOD("set_start", "val"), &GUIDEControllerRenderStyle::set_start);
        ADD_PROPERTY(PropertyInfo(Variant::OBJECT, "start", PROPERTY_HINT_RESOURCE_TYPE, "Texture2D"), "set_start", "get_start");

        ClassDB::bind_method(D_METHOD("get_misc1"), &GUIDEControllerRenderStyle::get_misc1);
        ClassDB::bind_method(D_METHOD("set_misc1", "val"), &GUIDEControllerRenderStyle::set_misc1);
        ADD_PROPERTY(PropertyInfo(Variant::OBJECT, "misc1", PROPERTY_HINT_RESOURCE_TYPE, "Texture2D"), "set_misc1", "get_misc1");

        ClassDB::bind_method(D_METHOD("get_back"), &GUIDEControllerRenderStyle::get_back);
        ClassDB::bind_method(D_METHOD("set_back", "val"), &GUIDEControllerRenderStyle::set_back);
        ADD_PROPERTY(PropertyInfo(Variant::OBJECT, "back", PROPERTY_HINT_RESOURCE_TYPE, "Texture2D"), "set_back", "get_back");

        ClassDB::bind_method(D_METHOD("get_touch_pad"), &GUIDEControllerRenderStyle::get_touch_pad);
        ClassDB::bind_method(D_METHOD("set_touch_pad", "val"), &GUIDEControllerRenderStyle::set_touch_pad);
        ADD_PROPERTY(PropertyInfo(Variant::OBJECT, "touch_pad", PROPERTY_HINT_RESOURCE_TYPE, "Texture2D"), "set_touch_pad", "get_touch_pad");

        ADD_GROUP("Directions", "");
        ClassDB::bind_method(D_METHOD("get_horizontal"), &GUIDEControllerRenderStyle::get_horizontal);
        ClassDB::bind_method(D_METHOD("set_horizontal", "val"), &GUIDEControllerRenderStyle::set_horizontal);
        ADD_PROPERTY(PropertyInfo(Variant::OBJECT, "horizontal", PROPERTY_HINT_RESOURCE_TYPE, "Texture2D"), "set_horizontal", "get_horizontal");

        ClassDB::bind_method(D_METHOD("get_vertical"), &GUIDEControllerRenderStyle::get_vertical);
        ClassDB::bind_method(D_METHOD("set_vertical", "val"), &GUIDEControllerRenderStyle::set_vertical);
        ADD_PROPERTY(PropertyInfo(Variant::OBJECT, "vertical", PROPERTY_HINT_RESOURCE_TYPE, "Texture2D"), "set_vertical", "get_vertical");
    }

private:
    #define DEF_GET_SET(name) \
        Ref<Texture2D> get_##name() const { return name; } \
        void set_##name(const Ref<Texture2D>& p_val) { name = p_val; }

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
    DEF_GET_SET(horizontal)
    DEF_GET_SET(vertical)
    #undef DEF_GET_SET
};

#endif // GUIDE_CONTROLLER_RENDER_STYLE_H
