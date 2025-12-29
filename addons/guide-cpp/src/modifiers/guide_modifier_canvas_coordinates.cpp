#include "guide_modifier_canvas_coordinates.h"
#include <godot_cpp/classes/engine.hpp>
#include <godot_cpp/classes/scene_tree.hpp>
#include <godot_cpp/classes/viewport.hpp>
#include <godot_cpp/classes/window.hpp>
#include <godot_cpp/core/math.hpp>

using namespace godot;

void GUIDEModifierCanvasCoordinates::_bind_methods() {
    ClassDB::bind_method(D_METHOD("get_relative_input"), &GUIDEModifierCanvasCoordinates::get_relative_input);
    ClassDB::bind_method(D_METHOD("set_relative_input", "val"), &GUIDEModifierCanvasCoordinates::set_relative_input);
    ADD_PROPERTY(PropertyInfo(Variant::BOOL, "relative_input"), "set_relative_input", "get_relative_input");
}

Vector3 GUIDEModifierCanvasCoordinates::_modify_input(Vector3 input, double delta, int value_type) const {
    if (!input.is_finite()) return Vector3(Math_INF, Math_INF, Math_INF);

    SceneTree *tree =  Object::cast_to<SceneTree>(Engine::get_singleton()->get_main_loop());
    if (!tree) return Vector3(Math_INF, Math_INF, Math_INF);
    Viewport *viewport = tree->get_root();
    Transform2D xform = viewport->get_canvas_transform().affine_inverse();
    Vector2 coords = xform.xform(Vector2(input.x, input.y));

    if (relative_input) {
        Vector2 origin = xform.xform(Vector2(0, 0));
        coords -= origin;
    }

    return Vector3(coords.x, coords.y, input.z);
}

bool GUIDEModifierCanvasCoordinates::is_same_as(const Ref<GUIDEModifier> &other) const {
    Ref<GUIDEModifierCanvasCoordinates> o = other;
    if (o.is_null()) return false;
    return o->get_relative_input() == relative_input;
}
