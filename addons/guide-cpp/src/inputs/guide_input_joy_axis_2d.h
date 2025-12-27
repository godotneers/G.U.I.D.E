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
    virtual int _native_value_type() const override;

    void _refresh();

    int get_x_axis() const { return x; }
    void set_x_axis(int p_axis) { x = p_axis; emit_changed(); }

    int get_y_axis() const { return y; }
    void set_y_axis(int p_axis) { y = p_axis; emit_changed(); }

protected:
    static void _bind_methods();

    int x = 0;
    int y = 1;
};

#endif // GUIDE_INPUT_JOY_AXIS_2D_H