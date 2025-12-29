#include "guide_modifier_map_range.h"
#include <godot_cpp/core/math.hpp>

using namespace godot;

void GUIDEModifierMapRange::_bind_methods() {
    ClassDB::bind_method(D_METHOD("get_apply_clamp"), &GUIDEModifierMapRange::get_apply_clamp);
    ClassDB::bind_method(D_METHOD("set_apply_clamp", "val"), &GUIDEModifierMapRange::set_apply_clamp);
    ADD_PROPERTY(PropertyInfo(Variant::BOOL, "apply_clamp"), "set_apply_clamp", "get_apply_clamp");

    ClassDB::bind_method(D_METHOD("get_input_min"), &GUIDEModifierMapRange::get_input_min);
    ClassDB::bind_method(D_METHOD("set_input_min", "val"), &GUIDEModifierMapRange::set_input_min);
    ADD_PROPERTY(PropertyInfo(Variant::FLOAT, "input_min"), "set_input_min", "get_input_min");

    ClassDB::bind_method(D_METHOD("get_input_max"), &GUIDEModifierMapRange::get_input_max);
    ClassDB::bind_method(D_METHOD("set_input_max", "val"), &GUIDEModifierMapRange::set_input_max);
    ADD_PROPERTY(PropertyInfo(Variant::FLOAT, "input_max"), "set_input_max", "get_input_max");

    ClassDB::bind_method(D_METHOD("get_output_min"), &GUIDEModifierMapRange::get_output_min);
    ClassDB::bind_method(D_METHOD("set_output_min", "val"), &GUIDEModifierMapRange::set_output_min);
    ADD_PROPERTY(PropertyInfo(Variant::FLOAT, "output_min"), "set_output_min", "get_output_min");

    ClassDB::bind_method(D_METHOD("get_output_max"), &GUIDEModifierMapRange::get_output_max);
    ClassDB::bind_method(D_METHOD("set_output_max", "val"), &GUIDEModifierMapRange::set_output_max);
    ADD_PROPERTY(PropertyInfo(Variant::FLOAT, "output_max"), "set_output_max", "get_output_max");

    ClassDB::bind_method(D_METHOD("get_x"), &GUIDEModifierMapRange::get_x);
    ClassDB::bind_method(D_METHOD("set_x", "val"), &GUIDEModifierMapRange::set_x);
    ADD_PROPERTY(PropertyInfo(Variant::BOOL, "x"), "set_x", "get_x");

    ClassDB::bind_method(D_METHOD("get_y"), &GUIDEModifierMapRange::get_y);
    ClassDB::bind_method(D_METHOD("set_y", "val"), &GUIDEModifierMapRange::set_y);
    ADD_PROPERTY(PropertyInfo(Variant::BOOL, "y"), "set_y", "get_y");

    ClassDB::bind_method(D_METHOD("get_z"), &GUIDEModifierMapRange::get_z);
    ClassDB::bind_method(D_METHOD("set_z", "val"), &GUIDEModifierMapRange::set_z);
    ADD_PROPERTY(PropertyInfo(Variant::BOOL, "z"), "set_z", "get_z");
}

GUIDEModifierMapRange::GUIDEModifierMapRange() {
}

GUIDEModifierMapRange::~GUIDEModifierMapRange() {
}

void GUIDEModifierMapRange::_begin_usage() {
    _omin = Math::min(output_min, output_max);
    _omax = Math::max(output_min, output_max);
}

Vector3 GUIDEModifierMapRange::_modify_input(Vector3 input, double delta, GUIDEAction::GUIDEActionValueType value_type) const {
    if (!input.is_finite()) return Vector3(Math_INF, Math_INF, Math_INF);

    double xv = Math::remap((double)input.x, input_min, input_max, output_min, output_max);
    double yv = Math::remap((double)input.y, input_min, input_max, output_min, output_max);
    double zv = Math::remap((double)input.z, input_min, input_max, output_min, output_max);

    if (apply_clamp) {
        xv = Math::clamp(xv, _omin, _omax);
        yv = Math::clamp(yv, _omin, _omax);
        zv = Math::clamp(zv, _omin, _omax);
    }

    return Vector3(
        x ? xv : input.x,
        y ? yv : input.y,
        z ? zv : input.z
    );
}

bool GUIDEModifierMapRange::is_same_as(const Ref<GUIDEModifier> &other) const {
    Ref<GUIDEModifierMapRange> o = other;
    if (o.is_null()) return false;
    return o->get_apply_clamp() == apply_clamp && 
           o->get_x() == x && 
           o->get_y() == y && 
           o->get_z() == z &&
           Math::is_equal_approx(input_min, o->get_input_min()) &&
           Math::is_equal_approx(input_max, o->get_input_max()) &&
           Math::is_equal_approx(output_min, o->get_output_min()) &&
           Math::is_equal_approx(output_max, o->get_output_max());
}

String GUIDEModifierMapRange::_editor_name() const {
    return "Map Range";
}

String GUIDEModifierMapRange::_editor_description() const {
    return "Maps an input range to an output range and optionally clamps the output";
}
