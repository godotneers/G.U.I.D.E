#ifndef GUIDE_MODIFIER_MAGNITUDE_H
#define GUIDE_MODIFIER_MAGNITUDE_H

#include "guide_modifier.h"

using namespace godot;

class GUIDEModifierMagnitude : public GUIDEModifier {
    GDCLASS(GUIDEModifierMagnitude, GUIDEModifier)

public:
    GUIDEModifierMagnitude() {}
    virtual ~GUIDEModifierMagnitude() {}

    virtual bool is_same_as(const Ref<GUIDEModifier> &other) const override {
        Ref<GUIDEModifierMagnitude> o = other;
        if (o.is_null()) return false;
        return true;
    }

    virtual Vector3 _modify_input(Vector3 input, double delta, GUIDEAction::GUIDEActionValueType value_type) const override {
        if (!input.is_finite()) return Vector3(Math_INF, Math_INF, Math_INF);
        return Vector3(input.length(), 0, 0);
    }

    virtual String _editor_name() const override { return "Magnitude"; }
    virtual String _editor_description() const override { return "Returns the magnitude of the input vector."; }

protected:
    static void _bind_methods() {}
};

#endif // GUIDE_MODIFIER_MAGNITUDE_H