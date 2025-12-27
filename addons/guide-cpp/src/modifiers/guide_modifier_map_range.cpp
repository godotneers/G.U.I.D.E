#include "guide_modifier_map_range.h"
#include <godot_cpp/core/math.hpp>
#include <algorithm>
#include <cmath>

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

static inline double remap_helper(double value, double i_min, double i_max, double o_min, double o_max) {
    return o_min + (value - i_min) * (o_max - o_min) / (i_max - i_min);
}

static inline double clamp_helper(double value, double min_val, double max_val) {
    if (value < min_val) return min_val;
    if (value > max_val) return max_val;
    return value;
}

Vector3 GUIDEModifierMapRange::_modify_input(Vector3 input, double delta, int value_type) const {
    if (!input.is_finite()) return Vector3(NAN, NAN, NAN);

    double xv = remap_helper(input.x, input_min, input_max, output_min, output_max);
    double yv = remap_helper(input.y, input_min, input_max, output_min, output_max);
    double zv = remap_helper(input.z, input_min, input_max, output_min, output_max);

    if (apply_clamp) {
        xv = clamp_helper(xv, _omin, _omax);
        yv = clamp_helper(yv, _omin, _omax);
        zv = clamp_helper(zv, _omin, _omax);
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
    return o->get_apply_clamp() == apply_clamp && o->get_x() == x && o->get_y() == y && o->get_z() == z &&
           Math::abs(o->get_input_min() - input_min) < 0.00001 &&
           Math::abs(o->get_input_max() - input_max) < 0.00001 &&
           Math::abs(o->get_output_min() - output_min) < 0.00001 &&
           Math::abs(o->get_output_max() - output_max) < 0.00001;
}

String GUIDEModifierMapRange::_editor_name() const {
    return "Map Range";
}

String GUIDEModifierMapRange::_editor_description() const {
    return "Maps an input range to an output range and optionally clamps the output";
}
