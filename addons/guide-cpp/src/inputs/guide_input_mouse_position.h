#ifndef GUIDE_INPUT_MOUSE_POSITION_H
#define GUIDE_INPUT_MOUSE_POSITION_H

#include "guide_input.h"

using namespace godot;

class GUIDEInputMousePosition : public GUIDEInput {
    GDCLASS(GUIDEInputMousePosition, GUIDEInput)

public:
    GUIDEInputMousePosition() {}
    virtual ~GUIDEInputMousePosition() {}

    virtual void _begin_usage() override;
    virtual void _end_usage() override;
    virtual bool is_same_as(const Ref<GUIDEInput> &other) const override;
    virtual String _editor_name() const override { return "Mouse Position"; }
    virtual String _editor_description() const override { return "Position of the mouse in the main viewport."; }
    virtual int _native_value_type() const override { return 2; /* AXIS_2D */ }
    virtual DeviceType _device_type() const override { return DEVICE_MOUSE; }

    void _refresh();

protected:
    static void _bind_methods();
};

#endif // GUIDE_INPUT_MOUSE_POSITION_H