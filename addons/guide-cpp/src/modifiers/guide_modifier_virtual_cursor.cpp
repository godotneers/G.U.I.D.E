#include "guide_modifier_virtual_cursor.h"
#include <godot_cpp/classes/engine.hpp>
#include <godot_cpp/classes/scene_tree.hpp>
#include <godot_cpp/classes/viewport.hpp>
#include <godot_cpp/classes/input.hpp>
#include <godot_cpp/classes/input_event_mouse_motion.hpp>
#include <godot_cpp/classes/window.hpp>
#include <godot_cpp/variant/utility_functions.hpp>
#include <godot_cpp/core/math.hpp>
#include "guide.h"

using namespace godot;

void GUIDEModifierVirtualCursor::_bind_methods() {
    BIND_ENUM_CONSTANT(NONE);
    BIND_ENUM_CONSTANT(LONGER_AXIS);
    BIND_ENUM_CONSTANT(SHORTER_AXIS);

    ClassDB::bind_method(D_METHOD("get_initial_position"), &GUIDEModifierVirtualCursor::get_initial_position);
    ClassDB::bind_method(D_METHOD("set_initial_position", "val"), &GUIDEModifierVirtualCursor::set_initial_position);
    ADD_PROPERTY(PropertyInfo(Variant::VECTOR2, "initial_position"), "set_initial_position", "get_initial_position");

    ClassDB::bind_method(D_METHOD("get_initialize_from_mouse_position"), &GUIDEModifierVirtualCursor::get_initialize_from_mouse_position);
    ClassDB::bind_method(D_METHOD("set_initialize_from_mouse_position", "val"), &GUIDEModifierVirtualCursor::set_initialize_from_mouse_position);
    ADD_PROPERTY(PropertyInfo(Variant::BOOL, "initialize_from_mouse_position"), "set_initialize_from_mouse_position", "get_initialize_from_mouse_position");

    ClassDB::bind_method(D_METHOD("get_apply_to_mouse_position_on_deactivation"), &GUIDEModifierVirtualCursor::get_apply_to_mouse_position_on_deactivation);
    ClassDB::bind_method(D_METHOD("set_apply_to_mouse_position_on_deactivation", "val"), &GUIDEModifierVirtualCursor::set_apply_to_mouse_position_on_deactivation);
    ADD_PROPERTY(PropertyInfo(Variant::BOOL, "apply_to_mouse_position_on_deactivation"), "set_apply_to_mouse_position_on_deactivation", "get_apply_to_mouse_position_on_deactivation");

    ClassDB::bind_method(D_METHOD("get_speed"), &GUIDEModifierVirtualCursor::get_speed);
    ClassDB::bind_method(D_METHOD("set_speed", "val"), &GUIDEModifierVirtualCursor::set_speed);
    ADD_PROPERTY(PropertyInfo(Variant::VECTOR3, "speed"), "set_speed", "get_speed");

    ClassDB::bind_method(D_METHOD("get_screen_scale"), &GUIDEModifierVirtualCursor::get_screen_scale);
    ClassDB::bind_method(D_METHOD("set_screen_scale", "val"), &GUIDEModifierVirtualCursor::set_screen_scale);
    ADD_PROPERTY(PropertyInfo(Variant::INT, "screen_scale", PROPERTY_HINT_ENUM, "NONE,LONGER_AXIS,SHORTER_AXIS"), "set_screen_scale", "get_screen_scale");

    ClassDB::bind_method(D_METHOD("get_apply_delta_time"), &GUIDEModifierVirtualCursor::get_apply_delta_time);
    ClassDB::bind_method(D_METHOD("set_apply_delta_time", "val"), &GUIDEModifierVirtualCursor::set_apply_delta_time);
    ADD_PROPERTY(PropertyInfo(Variant::BOOL, "apply_delta_time"), "set_apply_delta_time", "get_apply_delta_time");
}

GUIDEModifierVirtualCursor::GUIDEModifierVirtualCursor() {
    _offset = Vector3(0, 0, 0);
}

GUIDEModifierVirtualCursor::~GUIDEModifierVirtualCursor() {}

Vector2 GUIDEModifierVirtualCursor::_get_scaled_screen_size() const {
    SceneTree *tree = Object::cast_to<SceneTree>(Engine::get_singleton()->get_main_loop());
    Window *window = tree->get_root();
    return window->get_screen_transform().affine_inverse().xform(Vector2(window->get_size()));
}

void GUIDEModifierVirtualCursor::_begin_usage() {
    Vector2 size = _get_scaled_screen_size();
    if (initialize_from_mouse_position) {
        if (Input::get_singleton()->get_mouse_mode() == Input::MOUSE_MODE_CAPTURED) {
            UtilityFunctions::push_warning("Mouse mode is captured. In this mode the mouse cursor is fixed to center of the screen. Use one of the other mouse modes instead.");
        }
        SceneTree *tree = Object::cast_to<SceneTree>(Engine::get_singleton()->get_main_loop());
        Window *window = tree->get_root();
        Vector2 pos = window->get_mouse_position();
        _offset = Vector3(pos.x, pos.y, 0);
    } else {
        _offset = Vector3(size.x * initial_position.x, size.y * initial_position.y, 0);
    }
}

void GUIDEModifierVirtualCursor::_end_usage() {
    if (apply_to_mouse_position_on_deactivation) {
        if (Input::get_singleton()->get_mouse_mode() == Input::MOUSE_MODE_CAPTURED) {
            UtilityFunctions::push_warning("Mouse mode is captured. In this mode the mouse cursor cannot be moved. Use one of the other mouse modes instead.");
            return;
        }
        SceneTree *tree = Object::cast_to<SceneTree>(Engine::get_singleton()->get_main_loop());
        Window *window = tree->get_root();
        Vector2 pos = window->get_mouse_position();
        Vector2 diff = Vector2(_offset.x, _offset.y) - pos;
        window->warp_mouse(Vector2(_offset.x, _offset.y));
        
        Ref<InputEventMouseMotion> mm;
        mm.instantiate();
        mm->set_relative(diff);
        GUIDE::get_singleton()->inject_input(mm);
    }
}

Vector3 GUIDEModifierVirtualCursor::_modify_input(Vector3 input, double delta, GUIDEAction::GUIDEActionValueType value_type) const {
    if (!input.is_finite()) return _offset;

    Vector2 size = _get_scaled_screen_size();
    input *= speed;
    if (apply_delta_time) input *= delta;

    double factor = 1.0;
    if (screen_scale == LONGER_AXIS) factor = Math::max(size.x, size.y);
    else if (screen_scale == SHORTER_AXIS) factor = Math::min(size.x, size.y);
    input *= factor;

    _offset = (_offset + input).clamp(Vector3(0, 0, 0), Vector3(size.x, size.y, 0));
    return _offset;
}

bool GUIDEModifierVirtualCursor::is_same_as(const Ref<GUIDEModifier> &other) const {
    Ref<GUIDEModifierVirtualCursor> o = other;
    if (o.is_null()) return false;
    return o->get_screen_scale() == screen_scale && 
           o->get_apply_delta_time() == apply_delta_time &&
           o->get_initial_position().is_equal_approx(initial_position) &&
           o->get_speed().is_equal_approx(speed);
}