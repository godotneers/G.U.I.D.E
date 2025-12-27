#ifndef GUIDE_MODIFIER_SCALE_H
#define GUIDE_MODIFIER_SCALE_H

#include "guide_modifier.h"

using namespace godot;

class GUIDEModifierScale : public GUIDEModifier {
    GDCLASS(GUIDEModifierScale, GUIDEModifier)

public:
    GUIDEModifierScale();
    virtual ~GUIDEModifierScale();

    virtual bool is_same_as(const Ref<GUIDEModifier> &other) const override;
    virtual Vector3 _modify_input(Vector3 input, double delta, int value_type) const override;
    virtual String _editor_name() const override;
    virtual String _editor_description() const override;

    Vector3 get_scale() const { return scale; }
    void set_scale(const Vector3 &p_value) { scale = p_value; emit_changed(); }

    bool get_apply_delta_time() const { return apply_delta_time; }
    void set_apply_delta_time(bool p_value) { apply_delta_time = p_value; emit_changed(); }

protected:
    static void _bind_methods();

    Vector3 scale = Vector3(1, 1, 1);
    bool apply_delta_time = false;
};

#endif // GUIDE_MODIFIER_SCALE_H