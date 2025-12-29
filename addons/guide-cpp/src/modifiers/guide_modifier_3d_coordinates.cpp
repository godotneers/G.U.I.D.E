#include "guide_modifier_3d_coordinates.h"
#include <godot_cpp/classes/engine.hpp>
#include <godot_cpp/classes/scene_tree.hpp>
#include <godot_cpp/classes/viewport.hpp>
#include <godot_cpp/classes/window.hpp>
#include <godot_cpp/classes/camera3d.hpp>
#include <godot_cpp/classes/world3d.hpp>
#include <godot_cpp/classes/physics_direct_space_state3d.hpp>
#include <godot_cpp/classes/physics_ray_query_parameters3d.hpp>
#include <godot_cpp/core/math.hpp>

using namespace godot;

void GUIDEModifier3DCoordinates::_bind_methods() {
    ClassDB::bind_method(D_METHOD("get_max_depth"), &GUIDEModifier3DCoordinates::get_max_depth);
    ClassDB::bind_method(D_METHOD("set_max_depth", "val"), &GUIDEModifier3DCoordinates::set_max_depth);
    ADD_PROPERTY(PropertyInfo(Variant::FLOAT, "max_depth"), "set_max_depth", "get_max_depth");

    ClassDB::bind_method(D_METHOD("get_collide_with_areas"), &GUIDEModifier3DCoordinates::get_collide_with_areas);
    ClassDB::bind_method(D_METHOD("set_collide_with_areas", "val"), &GUIDEModifier3DCoordinates::set_collide_with_areas);
    ADD_PROPERTY(PropertyInfo(Variant::BOOL, "collide_with_areas"), "set_collide_with_areas", "get_collide_with_areas");

    ClassDB::bind_method(D_METHOD("get_collision_mask"), &GUIDEModifier3DCoordinates::get_collision_mask);
    ClassDB::bind_method(D_METHOD("set_collision_mask", "val"), &GUIDEModifier3DCoordinates::set_collision_mask);
    ADD_PROPERTY(PropertyInfo(Variant::INT, "collision_mask", PROPERTY_HINT_LAYERS_3D_PHYSICS), "set_collision_mask", "get_collision_mask");
}

GUIDEModifier3DCoordinates::GUIDEModifier3DCoordinates() {
    _input = Vector3(0, 0, 0);
    _latest_update_input = Vector3(0, 0, 0);
}

GUIDEModifier3DCoordinates::~GUIDEModifier3DCoordinates() {}

void GUIDEModifier3DCoordinates::_physics_process(double delta) {
    _latest_update_input = _update_input(_input);
}

Vector3 GUIDEModifier3DCoordinates::_modify_input(Vector3 input, double delta, int value_type) const {
    _input = input;
    return _latest_update_input;
}

Vector3 GUIDEModifier3DCoordinates::_update_input(Vector3 input) const {
    if (collision_mask == 0 || !input.is_finite()) return Vector3(Math_INF, Math_INF, Math_INF);

    SceneTree *tree = Object::cast_to<SceneTree>(Engine::get_singleton()->get_main_loop());
    if (!tree) return Vector3(Math_INF, Math_INF, Math_INF);
    Viewport *viewport = tree->get_root();
    Camera3D *camera = viewport->get_camera_3d();
    if (!camera) return Vector3(Math_INF, Math_INF, Math_INF);

    Vector2 pos(input.x, input.y);
    Vector3 from = camera->project_ray_origin(pos);
    Vector3 to = from + camera->project_ray_normal(pos) * max_depth;

    Ref<PhysicsRayQueryParameters3D> query = PhysicsRayQueryParameters3D::create(from, to, collision_mask);
    query->set_collide_with_areas(collide_with_areas);

    Dictionary result = viewport->get_world_3d()->get_direct_space_state()->intersect_ray(query);
    if (result.has("position")) {
        return result["position"];
    }
    return Vector3(Math_INF, Math_INF, Math_INF);
}

bool GUIDEModifier3DCoordinates::is_same_as(const Ref<GUIDEModifier> &other) const {
    Ref<GUIDEModifier3DCoordinates> o = other;
    if (o.is_null()) return false;
    return o->get_collide_with_areas() == collide_with_areas && 
           o->get_collision_mask() == collision_mask && 
           Math::is_equal_approx(o->get_max_depth(), max_depth);
}
