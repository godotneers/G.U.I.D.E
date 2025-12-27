#ifndef GUIDE_INPUT_TOUCH_AXIS_2D_H
#define GUIDE_INPUT_TOUCH_AXIS_2D_H

#include "guide_input_touch_axis_base.h"

using namespace godot;

class GUIDEInputTouchAxis2D : public GUIDEInputTouchAxisBase {
    GDCLASS(GUIDEInputTouchAxis2D, GUIDEInputTouchAxisBase)

public:
    GUIDEInputTouchAxis2D() {}
    virtual ~GUIDEInputTouchAxis2D() {}

    virtual void _apply_value(Vector2 value) override { _value = Vector3(value.x, value.y, 0); }
    virtual bool is_same_as(const Ref<GUIDEInput> &other) const override;
    virtual String _editor_name() const override { return "Touch Axis2D"; }
    virtual String _editor_description() const override { return "2D relative movement of a touching finger."; }
    virtual int _native_value_type() const override { return 2; /* AXIS_2D */ }

protected:
    static void _bind_methods() {}
};

#endif // GUIDE_INPUT_TOUCH_AXIS_2D_H