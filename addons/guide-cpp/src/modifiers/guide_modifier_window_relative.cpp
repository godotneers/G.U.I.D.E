#include "guide_modifier_window_relative.h"
#include <godot_cpp/classes/engine.hpp>
#include <godot_cpp/classes/scene_tree.hpp>
#include <godot_cpp/classes/viewport.hpp>
#include <godot_cpp/classes/window.hpp>

using namespace godot;

Vector3 GUIDEModifierWindowRelative::_modify_input(Vector3 input, double delta, GUIDEAction::GUIDEActionValueType value_type) const {
    if (!input.is_finite()) return Vector3(Math_INF, Math_INF, Math_INF);

    SceneTree *tree = Object::cast_to<SceneTree>(Engine::get_singleton()->get_main_loop());
    if (!tree) return Vector3(Math_INF, Math_INF, Math_INF);

    Window *window = tree->get_root();
    if (!window) return Vector3(Math_INF, Math_INF, Math_INF);

    Vector2 size = window->get_screen_transform().affine_inverse().xform(window->get_size());
    return Vector3(input.x / size.x, input.y / size.y, input.z);
}
