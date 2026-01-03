#ifndef GUIDE_TOUCH_RENDER_STYLE_H
#define GUIDE_TOUCH_RENDER_STYLE_H

#include <godot_cpp/classes/resource.hpp>
#include <godot_cpp/classes/texture2d.hpp>

using namespace godot;

class GUIDETouchRenderStyle : public Resource {
    GDCLASS(GUIDETouchRenderStyle, Resource)

public:
    Ref<Texture2D> one_finger;
    Ref<Texture2D> two_fingers;
    Ref<Texture2D> three_fingers;
    Ref<Texture2D> four_fingers;
    Ref<Texture2D> rotate;
    Ref<Texture2D> zoom;
    Ref<Texture2D> horizontal;
    Ref<Texture2D> vertical;
    Ref<Texture2D> both;

protected:
    static void _bind_methods() {
        #define BIND_PROP(name) \
            ClassDB::bind_method(D_METHOD("get_" #name), &GUIDETouchRenderStyle::get_##name); \
            ClassDB::bind_method(D_METHOD("set_" #name, "val"), &GUIDETouchRenderStyle::set_##name); \
            ADD_PROPERTY(PropertyInfo(Variant::OBJECT, #name, PROPERTY_HINT_RESOURCE_TYPE, "Texture2D"), "set_" #name, "get_" #name);

        BIND_PROP(one_finger)
        BIND_PROP(two_fingers)
        BIND_PROP(three_fingers)
        BIND_PROP(four_fingers)
        BIND_PROP(rotate)
        BIND_PROP(zoom)

        ADD_GROUP("Directions", "");
        BIND_PROP(horizontal)
        BIND_PROP(vertical)
        BIND_PROP(both)
        #undef BIND_PROP
    }

private:
    #define DEF_GET_SET(name) \
        Ref<Texture2D> get_##name() const { return name; } \
        void set_##name(const Ref<Texture2D>& p_val) { name = p_val; }

    DEF_GET_SET(one_finger)
    DEF_GET_SET(two_fingers)
    DEF_GET_SET(three_fingers)
    DEF_GET_SET(four_fingers)
    DEF_GET_SET(rotate)
    DEF_GET_SET(zoom)
    DEF_GET_SET(horizontal)
    DEF_GET_SET(vertical)
    DEF_GET_SET(both)
    #undef DEF_GET_SET
};

#endif // GUIDE_TOUCH_RENDER_STYLE_H
