#ifndef GUIDE_JOY_RENDER_STYLE_H
#define GUIDE_JOY_RENDER_STYLE_H

#include <godot_cpp/classes/resource.hpp>
#include <godot_cpp/classes/texture2d.hpp>
#include <godot_cpp/classes/font.hpp>

using namespace godot;

class GUIDEJoyRenderStyle : public Resource {
    GDCLASS(GUIDEJoyRenderStyle, Resource)

public:
    Ref<Texture2D> button;
    Ref<Texture2D> stick;
    Ref<Font> font;
    Color font_color = Color(0.843, 0.843, 0.843);
    int font_size = 50;
    Ref<Texture2D> horizontal;
    Ref<Texture2D> vertical;

protected:
    static void _bind_methods() {
        #define BIND_PROP(name, type) \
            ClassDB::bind_method(D_METHOD("get_" #name), &GUIDEJoyRenderStyle::get_##name); \
            ClassDB::bind_method(D_METHOD("set_" #name, "val"), &GUIDEJoyRenderStyle::set_##name); \
            ADD_PROPERTY(PropertyInfo(Variant::type, #name), "set_" #name, "get_" #name);

        BIND_PROP(button, OBJECT)
        BIND_PROP(stick, OBJECT)
        BIND_PROP(font, OBJECT)
        BIND_PROP(font_color, COLOR)
        BIND_PROP(font_size, INT)

        ADD_GROUP("Directions", "");
        BIND_PROP(horizontal, OBJECT)
        BIND_PROP(vertical, OBJECT)
        #undef BIND_PROP
    }

private:
    #define DEF_GET_SET(name, type) \
        type get_##name() const { return name; } \
        void set_##name(type p_val) { name = p_val; }

    DEF_GET_SET(button, Ref<Texture2D>)
    DEF_GET_SET(stick, Ref<Texture2D>)
    DEF_GET_SET(font, Ref<Font>)
    DEF_GET_SET(font_color, Color)
    DEF_GET_SET(font_size, int)
    DEF_GET_SET(horizontal, Ref<Texture2D>)
    DEF_GET_SET(vertical, Ref<Texture2D>)
    #undef DEF_GET_SET
};

#endif // GUIDE_JOY_RENDER_STYLE_H
