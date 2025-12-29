#ifndef GUIDE_MODIFIER_NORMALIZE_H
#define GUIDE_MODIFIER_NORMALIZE_H

#include "guide_modifier.h"

using namespace godot;

class GUIDEModifierNormalize : public GUIDEModifier {
    GDCLASS(GUIDEModifierNormalize, GUIDEModifier)

public:
    GUIDEModifierNormalize() {}
    virtual ~GUIDEModifierNormalize() {}

    virtual bool is_same_as(const Ref<GUIDEModifier> &other) const override {
        Ref<GUIDEModifierNormalize> o = other;
        if (o.is_null()) return false;
        return true;
    }

    virtual Vector3 _modify_input(Vector3 input, double delta, int value_type) const override {
        if (!input.is_finite()) return Vector3(Math_INF, Math_INF, Math_INF);
        return input.normalized();
    }

    virtual String _editor_name() const override { return "Normalize"; }
    virtual String _editor_description() const override { return "Normalizes the input vector."; }

protected:
    static void _bind_methods() {}
};

#endif // GUIDE_MODIFIER_NORMALIZE_H