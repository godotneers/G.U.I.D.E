#include "guide_modifier_deadzone.h"
#include "guide_action.h"
#include <godot_cpp/variant/vector2.hpp>
#include <godot_cpp/variant/utility_functions.hpp>
#include <godot_cpp/core/math.hpp>

using namespace godot;

void GUIDEModifierDeadzone::_bind_methods() {
    ClassDB::bind_method(D_METHOD("get_lower_threshold"), &GUIDEModifierDeadzone::get_lower_threshold);
    ClassDB::bind_method(D_METHOD("set_lower_threshold", "value"), &GUIDEModifierDeadzone::set_lower_threshold);
    ADD_PROPERTY(PropertyInfo(Variant::FLOAT, "lower_threshold", PROPERTY_HINT_RANGE, "0,1,0.01"), "set_lower_threshold", "get_lower_threshold");

    ClassDB::bind_method(D_METHOD("get_upper_threshold"), &GUIDEModifierDeadzone::get_upper_threshold);
    ClassDB::bind_method(D_METHOD("set_upper_threshold", "value"), &GUIDEModifierDeadzone::set_upper_threshold);
    ADD_PROPERTY(PropertyInfo(Variant::FLOAT, "upper_threshold", PROPERTY_HINT_RANGE, "0,1,0.01"), "set_upper_threshold", "get_upper_threshold");
}

GUIDEModifierDeadzone::GUIDEModifierDeadzone() {
}

GUIDEModifierDeadzone::~GUIDEModifierDeadzone() {
}

void GUIDEModifierDeadzone::set_lower_threshold(double p_value) {
    lower_threshold = Math::min(p_value, upper_threshold);
    emit_changed();
}

void GUIDEModifierDeadzone::set_upper_threshold(double p_value) {
    upper_threshold = Math::max(p_value, lower_threshold);
    emit_changed();
}

double GUIDEModifierDeadzone::_rescale(double value) const {
    double abs_val = Math::abs(value);
    double sign = (value > 0) ? 1.0 : ((value < 0) ? -1.0 : 0.0);
    return Math::min(1.0, (Math::max(0.0, abs_val - lower_threshold) / (upper_threshold - lower_threshold))) * sign;
}

Vector3 GUIDEModifierDeadzone::_modify_input(Vector3 input, double delta, int value_type) const {
    if (upper_threshold <= lower_threshold) {
        UtilityFunctions::push_warning("upper_threshold shouldnt be lower than lower_threshold");
        return input;
    }
    if (!input.is_finite()) return Vector3(Math_INF, Math_INF, Math_INF);

    switch (value_type) {
        case GUIDEAction::BOOL: // BOOL
        case GUIDEAction::AXIS_1D: // AXIS_1D
            return Vector3(_rescale(input.x), input.y, input.z);

        case GUIDEAction::AXIS_2D: { // AXIS_2D
            Vector2 v2d(input.x, input.y);
            if (v2d.is_zero_approx()) return Vector3(0, 0, input.z);
            v2d = v2d.normalized() * _rescale(v2d.length());
            return Vector3(v2d.x, v2d.y, input.z);
        }
        case GUIDEAction::AXIS_3D: { // AXIS_3D
            if (input.is_zero_approx()) return Vector3(0, 0, 0);
            return input.normalized() * _rescale(input.length());
        }
        default:
            UtilityFunctions::push_error("Unsupported value type. This is a bug. Please report it.");
            return input;
    }
    return input;
}

bool GUIDEModifierDeadzone::is_same_as(const Ref<GUIDEModifier> &other) const {
    Ref<GUIDEModifierDeadzone> o = other;
    if (o.is_null()) return false;
    return Math::is_equal_approx(lower_threshold, o->get_lower_threshold()) &&
           Math::is_equal_approx(upper_threshold, o->get_upper_threshold());
}

String GUIDEModifierDeadzone::_editor_name() const {
    return "Deadzone";
}

String GUIDEModifierDeadzone::_editor_description() const {
    return String("Inputs between the lower and upper threshold are mapped 0 -> 1.\n") +
	       String("Values outside the thresholds are clamped.");
}