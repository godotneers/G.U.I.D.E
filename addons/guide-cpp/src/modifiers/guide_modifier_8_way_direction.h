#ifndef GUIDE_MODIFIER_8_WAY_DIRECTION_H
#define GUIDE_MODIFIER_8_WAY_DIRECTION_H

#include "guide_modifier.h"

using namespace godot;

class GUIDEModifier8WayDirection : public GUIDEModifier {
    GDCLASS(GUIDEModifier8WayDirection, GUIDEModifier)

public:
    enum GUIDEDirection {
        EAST = 0, NORTH_EAST = 1, NORTH = 2, NORTH_WEST = 3,
        WEST = 4, SOUTH_WEST = 5, SOUTH = 6, SOUTH_EAST = 7
    };

    GUIDEModifier8WayDirection() {}
    virtual ~GUIDEModifier8WayDirection() {}

    virtual bool is_same_as(const Ref<GUIDEModifier> &other) const override;
    virtual Vector3 _modify_input(Vector3 input, double delta, GUIDEAction::GUIDEActionValueType value_type) const override;
    virtual String _editor_name() const override { return "8-way direction"; }
    virtual String _editor_description() const override { 
        return String("Converts a 2D input into a boolean that is true when the\n") +
               String("input direction matches the selected direction. Note, that north is negative Y,\n") +
               String("because in Godot negative Y is up.");
    }

    GUIDEDirection get_direction() const { return direction; }
    void set_direction(GUIDEDirection p_dir) { direction = p_dir; emit_changed(); }

protected:
    static void _bind_methods();

private:
    GUIDEDirection direction = EAST;
};

VARIANT_ENUM_CAST(GUIDEModifier8WayDirection::GUIDEDirection);

#endif // GUIDE_MODIFIER_8_WAY_DIRECTION_H
