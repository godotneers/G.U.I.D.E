#ifndef GUIDE_MOUSE_RENDER_STYLE_H
#define GUIDE_MOUSE_RENDER_STYLE_H

#include <godot_cpp/classes/resource.hpp>
#include <godot_cpp/classes/texture2d.hpp>

using namespace godot;

class GUIDEMouseRenderStyle : public Resource {
    GDCLASS(GUIDEMouseRenderStyle, Resource)

public:
    Ref<Texture2D> mouse_blank;
    Ref<Texture2D> mouse_left;
    Ref<Texture2D> mouse_right;
    Ref<Texture2D> mouse_middle;
    Ref<Texture2D> mouse_side_a;
    Ref<Texture2D> mouse_side_b;
    Ref<Texture2D> mouse_cursor;
    Ref<Texture2D> left;
    Ref<Texture2D> right;
    Ref<Texture2D> up;
    Ref<Texture2D> down;
    Ref<Texture2D> horizontal;
    Ref<Texture2D> vertical;

protected:
    static void _bind_methods() {
        #define BIND_PROP(name) \
            ClassDB::bind_method(D_METHOD("get_" #name), &GUIDEMouseRenderStyle::get_##name); \
            ClassDB::bind_method(D_METHOD("set_" #name, "val"), &GUIDEMouseRenderStyle::set_##name); \
            ADD_PROPERTY(PropertyInfo(Variant::OBJECT, #name, PROPERTY_HINT_RESOURCE_TYPE, "Texture2D"), "set_" #name, "get_" #name);

        BIND_PROP(mouse_blank)
        BIND_PROP(mouse_left)
        BIND_PROP(mouse_right)
        BIND_PROP(mouse_middle)
        BIND_PROP(mouse_side_a)
        BIND_PROP(mouse_side_b)
        BIND_PROP(mouse_cursor)
        
        ADD_GROUP("Directions", "");
        BIND_PROP(left)
        BIND_PROP(right)
        BIND_PROP(up)
        BIND_PROP(down)
        BIND_PROP(horizontal)
        BIND_PROP(vertical)
        #undef BIND_PROP
    }

private:
    #define DEF_GET_SET(name) \
        Ref<Texture2D> get_##name() const { return name; } \
        void set_##name(const Ref<Texture2D>& p_val) { name = p_val; }

    DEF_GET_SET(mouse_blank)
    DEF_GET_SET(mouse_left)
    DEF_GET_SET(mouse_right)
    DEF_GET_SET(mouse_middle)
    DEF_GET_SET(mouse_side_a)
    DEF_GET_SET(mouse_side_b)
    DEF_GET_SET(mouse_cursor)
    DEF_GET_SET(left)
    DEF_GET_SET(right)
    DEF_GET_SET(up)
    DEF_GET_SET(down)
    DEF_GET_SET(horizontal)
    DEF_GET_SET(vertical)
    #undef DEF_GET_SET
};

#endif // GUIDE_MOUSE_RENDER_STYLE_H
