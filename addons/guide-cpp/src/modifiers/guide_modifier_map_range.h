#ifndef GUIDE_MODIFIER_MAP_RANGE_H
#define GUIDE_MODIFIER_MAP_RANGE_H

#include "guide_modifier.h"

using namespace godot;

class GUIDEModifierMapRange : public GUIDEModifier {
    GDCLASS(GUIDEModifierMapRange, GUIDEModifier)

public:
    GUIDEModifierMapRange();
    virtual ~GUIDEModifierMapRange();

    virtual void _begin_usage() override;
    virtual bool is_same_as(const Ref<GUIDEModifier> &other) const override;
    virtual Vector3 _modify_input(Vector3 input, double delta, GUIDEAction::GUIDEActionValueType value_type) const override;
    virtual String _editor_name() const override;
    virtual String _editor_description() const override;

    // Getters and Setters
    bool get_apply_clamp() const { return apply_clamp; }
    void set_apply_clamp(bool p_val) { apply_clamp = p_val; emit_changed(); }

    double get_input_min() const { return input_min; }
    void set_input_min(double p_val) { input_min = p_val; emit_changed(); }

    double get_input_max() const { return input_max; }
    void set_input_max(double p_val) { input_max = p_val; emit_changed(); }

    double get_output_min() const { return output_min; }
    void set_output_min(double p_val) { output_min = p_val; emit_changed(); }

    double get_output_max() const { return output_max; }
    void set_output_max(double p_val) { output_max = p_val; emit_changed(); }

    bool get_x() const { return x; }
    void set_x(bool p_val) { x = p_val; emit_changed(); }

    bool get_y() const { return y; }
    void set_y(bool p_val) { y = p_val; emit_changed(); }

    bool get_z() const { return z; }
    void set_z(bool p_val) { z = p_val; emit_changed(); }

protected:
    static void _bind_methods();

    bool apply_clamp = true;
    double input_min = 0.0;
    double input_max = 1.0;
    double output_min = 0.0;
    double output_max = 1.0;
    bool x = true;
    bool y = true;
    bool z = true;

    double _omin = 0.0;
    double _omax = 1.0;
};

#endif // GUIDE_MODIFIER_MAP_RANGE_H