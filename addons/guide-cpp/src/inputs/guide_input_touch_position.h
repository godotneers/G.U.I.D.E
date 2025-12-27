#ifndef GUIDE_INPUT_TOUCH_POSITION_H
#define GUIDE_INPUT_TOUCH_POSITION_H

#include "guide_input_touch_base.h"

using namespace godot;

class GUIDEInputTouchPosition : public GUIDEInputTouchBase {
    GDCLASS(GUIDEInputTouchPosition, GUIDEInputTouchBase)

public:
    GUIDEInputTouchPosition() {}
    virtual ~GUIDEInputTouchPosition() {}

    virtual void _begin_usage() override;
    virtual void _end_usage() override;
    virtual bool is_same_as(const Ref<GUIDEInput> &other) const override;
    virtual String _editor_name() const override { return "Touch Position"; }
    virtual String _editor_description() const override { return "Position of a touching finger."; }
    virtual int _native_value_type() const override { return 2; /* AXIS_2D */ }

    void _refresh();

protected:
    static void _bind_methods();
};

#endif // GUIDE_INPUT_TOUCH_POSITION_H