#ifndef GUIDE_MODIFIER_MISC_H
#define GUIDE_MODIFIER_MISC_H

#include "guide_modifier.h"
#include <godot_cpp/classes/curve.hpp>

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
    virtual Vector3 _modify_input(Vector3 input, double delta, int value_type) const override;
    virtual String _editor_name() const override { return "8-way direction"; }
    virtual String _editor_description() const override { return "Converts a 2D input into a boolean that is true when the direction matches."; }

    int get_direction() const { return (int)direction; }
    void set_direction(int p_dir) { direction = (GUIDEDirection)p_dir; emit_changed(); }

protected:
    static void _bind_methods();

private:
    GUIDEDirection direction = EAST;
};

class GUIDEModifierWindowRelative : public GUIDEModifier {
    GDCLASS(GUIDEModifierWindowRelative, GUIDEModifier)

public:
    GUIDEModifierWindowRelative() {}
    virtual ~GUIDEModifierWindowRelative() {}

    virtual bool is_same_as(const Ref<GUIDEModifier> &other) const override { return other.is_valid() && other->get_class() == get_class(); }
    virtual Vector3 _modify_input(Vector3 input, double delta, int value_type) const override;
    virtual String _editor_name() const override { return "Window relative"; }
    virtual String _editor_description() const override { return "Converts input into window-relative units between 0 and 1."; }

protected:
    static void _bind_methods() {}
};

class GUIDEModifierCurve : public GUIDEModifier {
    GDCLASS(GUIDEModifierCurve, GUIDEModifier)

public:
    GUIDEModifierCurve();
    virtual ~GUIDEModifierCurve() {}

    virtual bool is_same_as(const Ref<GUIDEModifier> &other) const override;
    virtual Vector3 _modify_input(Vector3 input, double delta, int value_type) const override;
    virtual String _editor_name() const override { return "Curve"; }
    virtual String _editor_description() const override { return "Applies a curve to each input axis."; }

    Ref<Curve> get_curve() const { return curve; }
    void set_curve(const Ref<Curve> &p_curve) { curve = p_curve; emit_changed(); }

    bool get_x() const { return x; }
    void set_x(bool p_val) { x = p_val; emit_changed(); }
    bool get_y() const { return y; }
    void set_y(bool p_val) { y = p_val; emit_changed(); }
    bool get_z() const { return z; }
    void set_z(bool p_val) { z = p_val; emit_changed(); }

protected:
    static void _bind_methods();

private:
    Ref<Curve> curve;
    bool x = true;
    bool y = true;
    bool z = true;
};

VARIANT_ENUM_CAST(GUIDEModifier8WayDirection::GUIDEDirection);

#endif // GUIDE_MODIFIER_MISC_H