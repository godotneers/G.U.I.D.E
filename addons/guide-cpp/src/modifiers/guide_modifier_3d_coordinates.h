#ifndef GUIDE_MODIFIER_3D_COORDINATES_H
#define GUIDE_MODIFIER_3D_COORDINATES_H

#include "guide_modifier.h"

using namespace godot;

class GUIDEModifier3DCoordinates : public GUIDEModifier {
    GDCLASS(GUIDEModifier3DCoordinates, GUIDEModifier)

public:
    GUIDEModifier3DCoordinates();
    virtual ~GUIDEModifier3DCoordinates();

    virtual bool is_same_as(const Ref<GUIDEModifier> &other) const override;
    virtual bool _needs_physics_process() const override { return true; }
    virtual void _physics_process(double delta) override;
    virtual Vector3 _modify_input(Vector3 input, double delta, int value_type) const override;
    virtual String _editor_name() const override { return "3D coordinates"; }
    virtual String _editor_description() const override { return "Converts a position input in viewport coordinates into 3D world coordinates."; }

    double get_max_depth() const { return max_depth; }
    void set_max_depth(double p_val) { max_depth = p_val; emit_changed(); }

    bool get_collide_with_areas() const { return collide_with_areas; }
    void set_collide_with_areas(bool p_val) { collide_with_areas = p_val; emit_changed(); }

    uint32_t get_collision_mask() const { return collision_mask; }
    void set_collision_mask(uint32_t p_val) { collision_mask = p_val; emit_changed(); }

protected:
    static void _bind_methods();

private:
    double max_depth = 1000.0;
    bool collide_with_areas = false;
    uint32_t collision_mask = 1;

    mutable Vector3 _input;
    Vector3 _latest_update_input;
    Vector3 _update_input(Vector3 input) const;
};

#endif // GUIDE_MODIFIER_3D_COORDINATES_H
