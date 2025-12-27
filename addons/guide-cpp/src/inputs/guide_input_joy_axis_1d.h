#ifndef GUIDE_INPUT_JOY_AXIS_1D_H
#define GUIDE_INPUT_JOY_AXIS_1D_H

#include "guide_input_joy_base.h"

using namespace godot;

class GUIDEInputJoyAxis1D : public GUIDEInputJoyBase {
    GDCLASS(GUIDEInputJoyAxis1D, GUIDEInputJoyBase)

public:
    GUIDEInputJoyAxis1D();
    virtual ~GUIDEInputJoyAxis1D();

    virtual void _begin_usage() override;
    virtual void _end_usage() override;
    virtual bool is_same_as(const Ref<GUIDEInput> &other) const override;
    virtual String _editor_name() const override;
    virtual String _editor_description() const override;
    virtual int _native_value_type() const override;

    void _refresh();

    int get_axis() const { return axis; }
    void set_axis(int p_axis) { axis = p_axis; emit_changed(); }

protected:
    static void _bind_methods();

    int axis = 0;
};

#endif // GUIDE_INPUT_JOY_AXIS_1D_H