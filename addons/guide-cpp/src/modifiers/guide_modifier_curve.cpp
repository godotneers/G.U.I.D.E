#include "guide_modifier_curve.h"
#include <godot_cpp/variant/utility_functions.hpp>

using namespace godot;

void GUIDEModifierCurve::_bind_methods() {
    ClassDB::bind_method(D_METHOD("get_curve"), &GUIDEModifierCurve::get_curve);
    ClassDB::bind_method(D_METHOD("set_curve", "curve"), &GUIDEModifierCurve::set_curve);
    ADD_PROPERTY(PropertyInfo(Variant::OBJECT, "curve", PROPERTY_HINT_RESOURCE_TYPE, "Curve"), "set_curve", "get_curve");

    ClassDB::bind_method(D_METHOD("get_x"), &GUIDEModifierCurve::get_x);
    ClassDB::bind_method(D_METHOD("set_x", "val"), &GUIDEModifierCurve::set_x);
    ADD_PROPERTY(PropertyInfo(Variant::BOOL, "x"), "set_x", "get_x");

    ClassDB::bind_method(D_METHOD("get_y"), &GUIDEModifierCurve::get_y);
    ClassDB::bind_method(D_METHOD("set_y", "val"), &GUIDEModifierCurve::set_y);
    ADD_PROPERTY(PropertyInfo(Variant::BOOL, "y"), "set_y", "get_y");

    ClassDB::bind_method(D_METHOD("get_z"), &GUIDEModifierCurve::get_z);
    ClassDB::bind_method(D_METHOD("set_z", "val"), &GUIDEModifierCurve::set_z);
    ADD_PROPERTY(PropertyInfo(Variant::BOOL, "z"), "set_z", "get_z");
}

GUIDEModifierCurve::GUIDEModifierCurve() {
    curve.instantiate();
    curve->add_point(Vector2(0, 0));
    curve->add_point(Vector2(1, 1));
}

Vector3 GUIDEModifierCurve::_modify_input(Vector3 input, double delta, int value_type) const {
    if (curve.is_null()) {
        UtilityFunctions::push_error("No curve added to Curve modifier.");
        return input;
    }
    if (!input.is_finite()) return Vector3(Math_INF, Math_INF, Math_INF);
    return Vector3(
        x ? curve->sample(input.x) : input.x,
        y ? curve->sample(input.y) : input.y,
        z ? curve->sample(input.z) : input.z
    );
}

bool GUIDEModifierCurve::is_same_as(const Ref<GUIDEModifier> &other) const {
    Ref<GUIDEModifierCurve> o = other;
    if (o.is_null()) return false;
    return o->get_curve() == curve && 
           o->get_x() == x && 
           o->get_y() == y && 
           o->get_z() == z;
}
