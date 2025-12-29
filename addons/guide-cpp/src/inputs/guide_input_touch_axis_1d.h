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
    virtual String _editor_name() const override;
    virtual String _editor_description() const override;
    virtual GUIDEAction::GUIDEActionValueType _native_value_type() const override;

    GUIDEInputTouchAxis get_axis() const { return axis; }
    void set_axis(GUIDEInputTouchAxis p_axis) { axis = p_axis; emit_changed(); }

protected:
    static void _bind_methods();
    String _to_string() const;

    GUIDEInputTouchAxis axis = AXIS_X;
};

VARIANT_ENUM_CAST(GUIDEInputTouchAxis1D::GUIDEInputTouchAxis);

#endif // GUIDE_INPUT_TOUCH_AXIS_1D_H