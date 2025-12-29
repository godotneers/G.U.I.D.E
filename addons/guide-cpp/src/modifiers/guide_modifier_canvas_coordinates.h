#ifndef GUIDE_MODIFIER_CANVAS_COORDINATES_H
#define GUIDE_MODIFIER_CANVAS_COORDINATES_H

#include "guide_modifier.h"

using namespace godot;

class GUIDEModifierCanvasCoordinates : public GUIDEModifier {
    GDCLASS(GUIDEModifierCanvasCoordinates, GUIDEModifier)

public:
    GUIDEModifierCanvasCoordinates() {}
    virtual ~GUIDEModifierCanvasCoordinates() {}

    virtual bool is_same_as(const Ref<GUIDEModifier> &other) const override;
    virtual Vector3 _modify_input(Vector3 input, double delta, int value_type) const override;
    virtual String _editor_name() const override { return "Canvas coordinates"; }
    virtual String _editor_description() const override { 
        return String("Converts a position input in viewport coordinates (e.g. from the mouse position input)\n") + 
               String("into canvas coordinates (e.g. 2D world coordinates). Useful to get a 2D 'world' position.");
    }

    bool get_relative_input() const { return relative_input; }
    void set_relative_input(bool p_val) { relative_input = p_val; emit_changed(); }

protected:
    static void _bind_methods();

private:
    bool relative_input = false;
};

#endif // GUIDE_MODIFIER_CANVAS_COORDINATES_H
