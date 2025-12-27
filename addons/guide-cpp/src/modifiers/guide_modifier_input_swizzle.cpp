#include "guide_modifier_input_swizzle.h"

using namespace godot;

void GUIDEModifierInputSwizzle::_bind_methods() {
    BIND_ENUM_CONSTANT(YXZ);
    BIND_ENUM_CONSTANT(ZYX);
    BIND_ENUM_CONSTANT(XZY);
    BIND_ENUM_CONSTANT(YZX);
    BIND_ENUM_CONSTANT(ZXY);

    ClassDB::bind_method(D_METHOD("get_order"), &GUIDEModifierInputSwizzle::get_order);
    ClassDB::bind_method(D_METHOD("set_order", "order"), &GUIDEModifierInputSwizzle::set_order);
    ADD_PROPERTY(PropertyInfo(Variant::INT, "order", PROPERTY_HINT_ENUM, "YXZ,ZYX,XZY,YZX,ZXY"), "set_order", "get_order");
}

GUIDEModifierInputSwizzle::GUIDEModifierInputSwizzle() {
}

GUIDEModifierInputSwizzle::~GUIDEModifierInputSwizzle() {
}

Vector3 GUIDEModifierInputSwizzle::_modify_input(Vector3 input, double delta, int value_type) const {
    switch (order) {
        case YXZ: return Vector3(input.y, input.x, input.z);
        case ZYX: return Vector3(input.z, input.y, input.x);
        case XZY: return Vector3(input.x, input.z, input.y);
        case YZX: return Vector3(input.y, input.z, input.x);
        case ZXY: return Vector3(input.z, input.x, input.y);
    }
    return input;
}

bool GUIDEModifierInputSwizzle::is_same_as(const Ref<GUIDEModifier> &other) const {
    Ref<GUIDEModifierInputSwizzle> o = other;
    if (o.is_null()) return false;
    return o->get_order() == (int)order;
}

String GUIDEModifierInputSwizzle::_editor_name() const {
    return "Input Swizzle";
}

String GUIDEModifierInputSwizzle::_editor_description() const {
    return "Swizzle the input vector components. Useful to map 1D input to 2D or vice versa.";
}