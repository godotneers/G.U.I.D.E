#ifndef GUIDE_MODIFIER_WINDOW_RELATIVE_H
#define GUIDE_MODIFIER_WINDOW_RELATIVE_H

#include "guide_modifier.h"

using namespace godot;

class GUIDEModifierWindowRelative : public GUIDEModifier {
    GDCLASS(GUIDEModifierWindowRelative, GUIDEModifier)

public:
    GUIDEModifierWindowRelative() {}
    virtual ~GUIDEModifierWindowRelative() {}

    virtual bool is_same_as(const Ref<GUIDEModifier> &other) const override { 
        Ref<GUIDEModifierWindowRelative> o = other;
        if (o.is_null()) return false;
        return true; 
    }
    virtual Vector3 _modify_input(Vector3 input, double delta, int value_type) const override;
    virtual String _editor_name() const override { return "Window relative"; }
    virtual String _editor_description() const override {
        return String("Converts the value of the input into window-relative units between 0 and 1.\n") +
			   String("E.g. if a mouse cursor moves half a screen to the right and down, then \n") +
			   String("this modifier will return (0.5, 0.5)."); 
    }

protected:
    static void _bind_methods() {}
};

#endif // GUIDE_MODIFIER_WINDOW_RELATIVE_H
