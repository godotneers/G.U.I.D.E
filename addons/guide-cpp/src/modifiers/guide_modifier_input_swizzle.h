#ifndef GUIDE_MODIFIER_INPUT_SWIZZLE_H
#define GUIDE_MODIFIER_INPUT_SWIZZLE_H

#include "guide_modifier.h"

using namespace godot;

class GUIDEModifierInputSwizzle : public GUIDEModifier {
    GDCLASS(GUIDEModifierInputSwizzle, GUIDEModifier)

public:
    enum GUIDEInputSwizzleOperation {
        YXZ,
        ZYX,
        XZY,
        YZX,
        ZXY
    };

    GUIDEModifierInputSwizzle();
    virtual ~GUIDEModifierInputSwizzle();

    virtual bool is_same_as(const Ref<GUIDEModifier> &other) const override;
    virtual Vector3 _modify_input(Vector3 input, double delta, int value_type) const override;
    virtual String _editor_name() const override;
    virtual String _editor_description() const override;

    int get_order() const { return (int)order; }
    void set_order(int p_order) { order = (GUIDEInputSwizzleOperation)p_order; emit_changed(); }

protected:
    static void _bind_methods();

    GUIDEInputSwizzleOperation order = YXZ;
};

VARIANT_ENUM_CAST(GUIDEModifierInputSwizzle::GUIDEInputSwizzleOperation);

#endif // GUIDE_MODIFIER_INPUT_SWIZZLE_H