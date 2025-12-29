#ifndef GUIDE_INPUT_JOY_AXIS_2D_H
#define GUIDE_INPUT_JOY_AXIS_2D_H

#include "guide_input_joy_base.h"

using namespace godot;

class GUIDEInputJoyAxis2D : public GUIDEInputJoyBase {
    GDCLASS(GUIDEInputJoyAxis2D, GUIDEInputJoyBase)

public:
    GUIDEInputJoyAxis2D();
    virtual ~GUIDEInputJoyAxis2D();

    virtual void _begin_usage() override;
    virtual void _end_usage() override;
    virtual bool is_same_as(const Ref<GUIDEInput> &other) const override;
    virtual String _editor_name() const override;
    virtual String _editor_description() const override;
    virtual GUIDEAction::GUIDEActionValueType _native_value_type() const override;

    void _refresh();

    JoyAxis get_x_axis() const { return x; }
    void set_x_axis(JoyAxis p_axis) { x = p_axis; emit_changed(); }

    JoyAxis get_y_axis() const { return y; }
    void set_y_axis(JoyAxis p_axis) { y = p_axis; emit_changed(); }

protected:
    static void _bind_methods();
    String _to_string() const;

    JoyAxis x = JoyAxis::JOY_AXIS_LEFT_X;
    JoyAxis y = JoyAxis::JOY_AXIS_LEFT_Y;
};

#endif // GUIDE_INPUT_JOY_AXIS_2D_H