#ifndef GUIDE_KEY_RENDER_STYLE_H
#define GUIDE_KEY_RENDER_STYLE_H

#include <godot_cpp/classes/resource.hpp>
#include <godot_cpp/classes/texture2d.hpp>
#include <godot_cpp/classes/font.hpp>

using namespace godot;

class GUIDEKeyRenderStyle : public Resource {
    GDCLASS(GUIDEKeyRenderStyle, Resource)

public:
    Ref<Texture2D> keycaps;
    Rect2 region_rect;
    int patch_margin_left = 0;
    int patch_margin_top = 0;
    int patch_margin_right = 0;
    int patch_margin_bottom = 0;
    Ref<Font> font;
    Color font_color = Color(0.843, 0.843, 0.843);
    int font_size = 45;

protected:
    static void _bind_methods() {
        #define BIND_PROP(name, type) \
            ClassDB::bind_method(D_METHOD("get_" #name), &GUIDEKeyRenderStyle::get_##name); \
            ClassDB::bind_method(D_METHOD("set_" #name, "val"), &GUIDEKeyRenderStyle::set_##name); \
            ADD_PROPERTY(PropertyInfo(Variant::type, #name), "set_" #name, "get_" #name);

        #define BIND_PROP_HINT(name, type, hint_mode, hint_string) \
        ClassDB::bind_method(D_METHOD("get_" #name), &GUIDEKeyRenderStyle::get_##name); \
        ClassDB::bind_method(D_METHOD("set_" #name, "val"), &GUIDEKeyRenderStyle::set_##name); \
        ADD_PROPERTY(PropertyInfo(Variant::type, #name, hint_mode, hint_string), "set_" #name, "get_" #name);

        BIND_PROP(keycaps, OBJECT)
        BIND_PROP(region_rect, RECT2)

        ADD_GROUP("Patch margin", "patch_margin");
        BIND_PROP_HINT(patch_margin_left, INT, PROPERTY_HINT_RANGE, "0,100,1")
        BIND_PROP_HINT(patch_margin_top, INT, PROPERTY_HINT_RANGE, "0,100,1")
        BIND_PROP_HINT(patch_margin_right, INT, PROPERTY_HINT_RANGE, "0,100,1")
        BIND_PROP_HINT(patch_margin_bottom, INT, PROPERTY_HINT_RANGE, "0,100,1")

        BIND_PROP(font, OBJECT)
        BIND_PROP(font_color, COLOR)
        BIND_PROP(font_size, INT)
        #undef BIND_PROP
        #undef BIND_PROP_HINT
    }

private:
    #define DEF_GET_SET(name, type) \
        type get_##name() const { return name; } \
        void set_##name(type p_val) { name = p_val; }

    DEF_GET_SET(keycaps, Ref<Texture2D>)
    DEF_GET_SET(region_rect, Rect2)
    DEF_GET_SET(patch_margin_left, int)
    DEF_GET_SET(patch_margin_top, int)
    DEF_GET_SET(patch_margin_right, int)
    DEF_GET_SET(patch_margin_bottom, int)
    DEF_GET_SET(font, Ref<Font>)
    DEF_GET_SET(font_color, Color)
    DEF_GET_SET(font_size, int)
    #undef DEF_GET_SET
};

#endif // GUIDE_KEY_RENDER_STYLE_H
