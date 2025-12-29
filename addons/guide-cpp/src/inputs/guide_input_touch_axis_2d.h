#ifndef GUIDE_INPUT_TOUCH_AXIS_2D_H
#define GUIDE_INPUT_TOUCH_AXIS_2D_H

#include "guide_input_touch_axis_base.h"

using namespace godot;

class GUIDEInputTouchAxis2D : public GUIDEInputTouchAxisBase {
    GDCLASS(GUIDEInputTouchAxis2D, GUIDEInputTouchAxisBase)

public:
    GUIDEInputTouchAxis2D() {}
    virtual ~GUIDEInputTouchAxis2D() {}

    virtual void _apply_value(Vector2 value) override;
    virtual bool is_same_as(const Ref<GUIDEInput> &other) const override;
    virtual String _editor_name() const override;
    virtual String _editor_description() const override;
    virtual GUIDEAction::GUIDEActionValueType _native_value_type() const override;

protected:
    static void _bind_methods();
    String _to_string() const;
};

#endif // GUIDE_INPUT_TOUCH_AXIS_2D_H