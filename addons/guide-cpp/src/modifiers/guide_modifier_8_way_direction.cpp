#include "guide_modifier_8_way_direction.h"

using namespace godot;

void GUIDEModifier8WayDirection::_bind_methods() {
    BIND_ENUM_CONSTANT(EAST); BIND_ENUM_CONSTANT(NORTH_EAST); BIND_ENUM_CONSTANT(NORTH); BIND_ENUM_CONSTANT(NORTH_WEST);
    BIND_ENUM_CONSTANT(WEST); BIND_ENUM_CONSTANT(SOUTH_WEST); BIND_ENUM_CONSTANT(SOUTH); BIND_ENUM_CONSTANT(SOUTH_EAST);

    ClassDB::bind_method(D_METHOD("get_direction"), &GUIDEModifier8WayDirection::get_direction);
    ClassDB::bind_method(D_METHOD("set_direction", "dir"), &GUIDEModifier8WayDirection::set_direction);
    ADD_PROPERTY(PropertyInfo(Variant::INT, "direction", PROPERTY_HINT_ENUM, "EAST,NORTH_EAST,NORTH,NORTH_WEST,WEST,SOUTH_WEST,SOUTH,SOUTH_EAST"), "set_direction", "get_direction");
}

Vector3 GUIDEModifier8WayDirection::_modify_input(Vector3 input, double delta, int value_type) const {
    if (!input.is_finite()) return Vector3(Math_INF, Math_INF, Math_INF);
    if (input.is_zero_approx()) return Vector3(0, 0, 0);

    double angle = Math::atan2(-input.y, input.x);
    int octant = (int)Math::round(8.0 * angle / (2.0 * Math_PI) + 8.0) % 8;
    return (octant == direction) ? Vector3(1, 0, 0) : Vector3(0, 0, 0);
}

bool GUIDEModifier8WayDirection::is_same_as(const Ref<GUIDEModifier> &other) const {
    Ref<GUIDEModifier8WayDirection> o = other;
    if (o.is_null()) return false;
    return o->get_direction() == direction;
}
