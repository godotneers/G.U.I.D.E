#include "guide_modifier_positive_negative.h"
#include <godot_cpp/core/math.hpp>
#include <algorithm>

using namespace godot;

void GUIDEModifierPositiveNegative::_bind_methods() {
    BIND_ENUM_CONSTANT(POSITIVE);
    BIND_ENUM_CONSTANT(NEGATIVE);

    ClassDB::bind_method(D_METHOD("get_range"), &GUIDEModifierPositiveNegative::get_range);
    ClassDB::bind_method(D_METHOD("set_range", "range"), &GUIDEModifierPositiveNegative::set_range);
    ADD_PROPERTY(PropertyInfo(Variant::INT, "range", PROPERTY_HINT_ENUM, "POSITIVE:1,NEGATIVE:2"), "set_range", "get_range");

    ClassDB::bind_method(D_METHOD("get_x"), &GUIDEModifierPositiveNegative::get_x);
    ClassDB::bind_method(D_METHOD("set_x", "val"), &GUIDEModifierPositiveNegative::set_x);
    ADD_PROPERTY(PropertyInfo(Variant::BOOL, "x"), "set_x", "get_x");

    ClassDB::bind_method(D_METHOD("get_y"), &GUIDEModifierPositiveNegative::get_y);
    ClassDB::bind_method(D_METHOD("set_y", "val"), &GUIDEModifierPositiveNegative::set_y);
    ADD_PROPERTY(PropertyInfo(Variant::BOOL, "y"), "set_y", "get_y");

    ClassDB::bind_method(D_METHOD("get_z"), &GUIDEModifierPositiveNegative::get_z);
    ClassDB::bind_method(D_METHOD("set_z", "val"), &GUIDEModifierPositiveNegative::set_z);
    ADD_PROPERTY(PropertyInfo(Variant::BOOL, "z"), "set_z", "get_z");
}

GUIDEModifierPositiveNegative::GUIDEModifierPositiveNegative() {
}

GUIDEModifierPositiveNegative::~GUIDEModifierPositiveNegative() {
}

Vector3 GUIDEModifierPositiveNegative::_modify_input(Vector3 input, double delta, int value_type) const {
    if (!input.is_finite()) return Vector3(NAN, NAN, NAN);

    if (range == POSITIVE) {
        return Vector3(
            x ? Math::max(0.0, input.x) : input.x,
            y ? Math::max(0.0, input.y) : input.y,
            z ? Math::max(0.0, input.z) : input.z
        );
    } else {
        return Vector3(
            x ? Math::min(0.0, input.x) : input.x,
            y ? Math::min(0.0, input.y) : input.y,
            z ? Math::min(0.0, input.z) : input.z
        );
    }
}

bool GUIDEModifierPositiveNegative::is_same_as(const Ref<GUIDEModifier> &other) const {
    Ref<GUIDEModifierPositiveNegative> o = other;
    if (o.is_null()) return false;
    return o->get_range() == (int)range && o->get_x() == x && o->get_y() == y && o->get_z() == z;
}

String GUIDEModifierPositiveNegative::_editor_name() const {
    return "Positive/Negative";
}

String GUIDEModifierPositiveNegative::_editor_description() const {
    return "Clamps the input to positive or negative values.";
}
