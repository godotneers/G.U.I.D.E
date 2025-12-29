#include "guide_modifier_negate.h"

using namespace godot;

void GUIDEModifierNegate::_bind_methods() {
    ClassDB::bind_method(D_METHOD("get_x"), &GUIDEModifierNegate::get_x);
    ClassDB::bind_method(D_METHOD("set_x", "value"), &GUIDEModifierNegate::set_x);
    ADD_PROPERTY(PropertyInfo(Variant::BOOL, "x"), "set_x", "get_x");

    ClassDB::bind_method(D_METHOD("get_y"), &GUIDEModifierNegate::get_y);
    ClassDB::bind_method(D_METHOD("set_y", "value"), &GUIDEModifierNegate::set_y);
    ADD_PROPERTY(PropertyInfo(Variant::BOOL, "y"), "set_y", "get_y");

    ClassDB::bind_method(D_METHOD("get_z"), &GUIDEModifierNegate::get_z);
    ClassDB::bind_method(D_METHOD("set_z", "value"), &GUIDEModifierNegate::set_z);
    ADD_PROPERTY(PropertyInfo(Variant::BOOL, "z"), "set_z", "get_z");
}

GUIDEModifierNegate::GUIDEModifierNegate() {
    _update_caches();
}

GUIDEModifierNegate::~GUIDEModifierNegate() {
}

void GUIDEModifierNegate::_update_caches() {
    _multiplier.x = x ? -1.0 : 1.0;
    _multiplier.y = y ? -1.0 : 1.0;
    _multiplier.z = z ? -1.0 : 1.0;
}

Vector3 GUIDEModifierNegate::_modify_input(Vector3 input, double delta, int value_type) const {
    if (!input.is_finite()) return Vector3(Math_INF, Math_INF, Math_INF);
    return input * _multiplier;
}

bool GUIDEModifierNegate::is_same_as(const Ref<GUIDEModifier> &other) const {
    Ref<GUIDEModifierNegate> o = other;
    if (o.is_null()) return false;
    return o->get_x() == x && 
           o->get_y() == y &&
           o->get_z() == z;
}

String GUIDEModifierNegate::_editor_name() const {
    return "Negate";
}

String GUIDEModifierNegate::_editor_description() const {
    return "Inverts input per axis.";
}