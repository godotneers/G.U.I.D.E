#include "guide_modifier_misc.h"
#include <godot_cpp/classes/engine.hpp>
#include <godot_cpp/classes/scene_tree.hpp>
#include <godot_cpp/classes/viewport.hpp>
#include <godot_cpp/core/math.hpp>
#include <cmath>

using namespace godot;

// --- 8-Way Direction ---

void GUIDEModifier8WayDirection::_bind_methods() {
    BIND_ENUM_CONSTANT(EAST); BIND_ENUM_CONSTANT(NORTH_EAST); BIND_ENUM_CONSTANT(NORTH); BIND_ENUM_CONSTANT(NORTH_WEST);
    BIND_ENUM_CONSTANT(WEST); BIND_ENUM_CONSTANT(SOUTH_WEST); BIND_ENUM_CONSTANT(SOUTH); BIND_ENUM_CONSTANT(SOUTH_EAST);

    ClassDB::bind_method(D_METHOD("get_direction"), &GUIDEModifier8WayDirection::get_direction);
    ClassDB::bind_method(D_METHOD("set_direction", "dir"), &GUIDEModifier8WayDirection::set_direction);
    ADD_PROPERTY(PropertyInfo(Variant::INT, "direction", PROPERTY_HINT_ENUM, "EAST,NORTH_EAST,NORTH,NORTH_WEST,WEST,SOUTH_WEST,SOUTH,SOUTH_EAST"), "set_direction", "get_direction");
}

Vector3 GUIDEModifier8WayDirection::_modify_input(Vector3 input, double delta, int value_type) const {
    if (!input.is_finite()) return Vector3(NAN, NAN, NAN);
    if (input.is_zero_approx()) return Vector3(0, 0, 0);

    double angle = Math::atan2(-input.y, input.x);
    int octant = (int)Math::round(8.0 * angle / (2.0 * Math_PI) + 8.0) % 8;
    return (octant == direction) ? Vector3(1, 0, 0) : Vector3(0, 0, 0);
}

bool GUIDEModifier8WayDirection::is_same_as(const Ref<GUIDEModifier> &other) const {
    Ref<GUIDEModifier8WayDirection> o = other;
    if (o.is_null()) return false;
    return o->get_direction() == (int)direction;
}

// --- Window Relative ---

Vector3 GUIDEModifierWindowRelative::_modify_input(Vector3 input, double delta, int value_type) const {
    if (!input.is_finite()) return Vector3(NAN, NAN, NAN);
    Viewport *viewport = SceneTree::get_singleton()->get_root();
    Vector2 size = viewport->get_screen_transform().affine_inverse() * Vector2(viewport->get_size());
    return Vector3(input.x / size.x, input.y / size.y, input.z);
}

// --- Curve ---

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
    if (curve.is_null()) return input;
    if (!input.is_finite()) return Vector3(NAN, NAN, NAN);
    return Vector3(
        x ? curve->sample(input.x) : input.x,
        y ? curve->sample(input.y) : input.y,
        z ? curve->sample(input.z) : input.z
    );
}

bool GUIDEModifierCurve::is_same_as(const Ref<GUIDEModifier> &other) const {
    Ref<GUIDEModifierCurve> o = other;
    if (o.is_null()) return false;
    return o->get_curve() == curve && o->get_x() == x && o->get_y() == y && o->get_z() == z;
}
