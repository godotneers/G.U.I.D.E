#ifndef GUIDE_MODIFIER_POSITIVE_NEGATIVE_H
#define GUIDE_MODIFIER_POSITIVE_NEGATIVE_H

#include "guide_modifier.h"

using namespace godot;

class GUIDEModifierPositiveNegative : public GUIDEModifier {
    GDCLASS(GUIDEModifierPositiveNegative, GUIDEModifier)

public:
    enum LimitRange {
        POSITIVE = 1,
        NEGATIVE = 2
    };

    GUIDEModifierPositiveNegative();
    virtual ~GUIDEModifierPositiveNegative();

    virtual bool is_same_as(const Ref<GUIDEModifier> &other) const override;
    virtual Vector3 _modify_input(Vector3 input, double delta, int value_type) const override;
    virtual String _editor_name() const override;
    virtual String _editor_description() const override;

    LimitRange get_range() const { return range; }
    void set_range(LimitRange p_range) { range = p_range; emit_changed(); }

    bool get_x() const { return x; }
    void set_x(bool p_val) { x = p_val; emit_changed(); }

    bool get_y() const { return y; }
    void set_y(bool p_val) { y = p_val; emit_changed(); }

    bool get_z() const { return z; }
    void set_z(bool p_val) { z = p_val; emit_changed(); }

protected:
    static void _bind_methods();

    LimitRange range = POSITIVE;
    bool x = true;
    bool y = true;
    bool z = true;
};

VARIANT_ENUM_CAST(GUIDEModifierPositiveNegative::LimitRange);

#endif // GUIDE_MODIFIER_POSITIVE_NEGATIVE_H