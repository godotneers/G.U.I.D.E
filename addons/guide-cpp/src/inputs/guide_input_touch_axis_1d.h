#ifndef GUIDE_INPUT_TOUCH_AXIS_1D_H
#define GUIDE_INPUT_TOUCH_AXIS_1D_H

#include "guide_input_touch_axis_base.h"

using namespace godot;

class GUIDEInputTouchAxis1D : public GUIDEInputTouchAxisBase {
    GDCLASS(GUIDEInputTouchAxis1D, GUIDEInputTouchAxisBase)

public:
    enum GUIDEInputTouchAxis {
        AXIS_X,
        AXIS_Y
    };

    GUIDEInputTouchAxis1D();
    virtual ~GUIDEInputTouchAxis1D();

    virtual void _apply_value(Vector2 value) override;
    virtual bool is_same_as(const Ref<GUIDEInput> &other) const override;
    virtual String _editor_name() const override { return "Touch Axis1D"; }
    virtual String _editor_description() const override { return "Relative movement of a touching finger on a single axis."; }
    virtual int _native_value_type() const override { return 1; /* AXIS_1D */ }

    int get_axis() const { return (int)axis; }
    void set_axis(int p_axis) { axis = (GUIDEInputTouchAxis)p_axis; emit_changed(); }

protected:
    static void _bind_methods();

    GUIDEInputTouchAxis axis = AXIS_X;
};

VARIANT_ENUM_CAST(GUIDEInputTouchAxis1D::GUIDEInputTouchAxis);

#endif // GUIDE_INPUT_TOUCH_AXIS_1D_H