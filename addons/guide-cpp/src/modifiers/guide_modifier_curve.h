#ifndef GUIDE_MODIFIER_CURVE_H
#define GUIDE_MODIFIER_CURVE_H

#include "guide_modifier.h"
#include <godot_cpp/classes/curve.hpp>

using namespace godot;

class GUIDEModifierCurve : public GUIDEModifier {
    GDCLASS(GUIDEModifierCurve, GUIDEModifier)

public:
    GUIDEModifierCurve();
    virtual ~GUIDEModifierCurve() {}

    virtual bool is_same_as(const Ref<GUIDEModifier> &other) const override;
    virtual Vector3 _modify_input(Vector3 input, double delta, GUIDEAction::GUIDEActionValueType value_type) const override;
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

#endif // GUIDE_MODIFIER_CURVE_H
