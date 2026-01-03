#include "guide_modifier_scale.h"

using namespace godot;

void GUIDEModifierScale::_bind_methods() {
    ClassDB::bind_method(D_METHOD("get_scale"), &GUIDEModifierScale::get_scale);
    ClassDB::bind_method(D_METHOD("set_scale", "value"), &GUIDEModifierScale::set_scale);
    ADD_PROPERTY(PropertyInfo(Variant::VECTOR3, "scale"), "set_scale", "get_scale");

    ClassDB::bind_method(D_METHOD("get_apply_delta_time"), &GUIDEModifierScale::get_apply_delta_time);
    ClassDB::bind_method(D_METHOD("set_apply_delta_time", "value"), &GUIDEModifierScale::set_apply_delta_time);
    ADD_PROPERTY(PropertyInfo(Variant::BOOL, "apply_delta_time"), "set_apply_delta_time", "get_apply_delta_time");
}

GUIDEModifierScale::GUIDEModifierScale() {
}

GUIDEModifierScale::~GUIDEModifierScale() {
}

Vector3 GUIDEModifierScale::_modify_input(Vector3 input, double delta, GUIDEAction::GUIDEActionValueType value_type) const {
    if (!input.is_finite()) return Vector3(Math_INF, Math_INF, Math_INF);
    if (apply_delta_time) {
        return input * scale * delta;
    } else {
        return input * scale;
    }
}

bool GUIDEModifierScale::is_same_as(const Ref<GUIDEModifier> &other) const {
    Ref<GUIDEModifierScale> o = other;
    if (o.is_null()) return false;
    return o->get_scale().is_equal_approx(scale) &&
           o->get_apply_delta_time() == apply_delta_time;
}

String GUIDEModifierScale::_editor_name() const {
    return "Scale";
}

String GUIDEModifierScale::_editor_description() const {
    return "Scales the input by the given value and optionally, delta time.";
}