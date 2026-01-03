#ifndef GUIDE_MODIFIER_NEGATE_H
#define GUIDE_MODIFIER_NEGATE_H

#include "guide_modifier.h"

using namespace godot;

class GUIDEModifierNegate : public GUIDEModifier {
    GDCLASS(GUIDEModifierNegate, GUIDEModifier)

public:
    GUIDEModifierNegate();
    virtual ~GUIDEModifierNegate();

    virtual bool is_same_as(const Ref<GUIDEModifier> &other) const override;
    virtual Vector3 _modify_input(Vector3 input, double delta, GUIDEAction::GUIDEActionValueType value_type) const override;
    virtual String _editor_name() const override;
    virtual String _editor_description() const override;

    bool get_x() const { return x; }
    void set_x(bool p_value) { x = p_value; _update_caches(); emit_changed(); }

    bool get_y() const { return y; }
    void set_y(bool p_value) { y = p_value; _update_caches(); emit_changed(); }

    bool get_z() const { return z; }
    void set_z(bool p_value) { z = p_value; _update_caches(); emit_changed(); }

protected:
    static void _bind_methods();

    bool x = true;
    bool y = true;
    bool z = true;

private:
    Vector3 _multiplier;
    void _update_caches();
};

#endif // GUIDE_MODIFIER_NEGATE_H