#ifndef GUIDE_MODIFIER_DEADZONE_H
#define GUIDE_MODIFIER_DEADZONE_H

#include "guide_modifier.h"

using namespace godot;

class GUIDEModifierDeadzone : public GUIDEModifier {
    GDCLASS(GUIDEModifierDeadzone, GUIDEModifier)

public:
    GUIDEModifierDeadzone();
    virtual ~GUIDEModifierDeadzone();

    virtual bool is_same_as(const Ref<GUIDEModifier> &other) const override;
    virtual Vector3 _modify_input(Vector3 input, double delta, GUIDEAction::GUIDEActionValueType value_type) const override;
    virtual String _editor_name() const override;
    virtual String _editor_description() const override;

    double get_lower_threshold() const { return lower_threshold; }
    void set_lower_threshold(double p_value);

    double get_upper_threshold() const { return upper_threshold; }
    void set_upper_threshold(double p_value);

protected:
    static void _bind_methods();

    double lower_threshold = 0.2;
    double upper_threshold = 1.0;

    double _rescale(double value) const;
};

#endif // GUIDE_MODIFIER_DEADZONE_H