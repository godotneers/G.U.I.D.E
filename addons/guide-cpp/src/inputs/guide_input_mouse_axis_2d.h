#ifndef GUIDE_INPUT_MOUSE_AXIS_2D_H
#define GUIDE_INPUT_MOUSE_AXIS_2D_H

#include "guide_input.h"

using namespace godot;

class GUIDEInputMouseAxis2D : public GUIDEInput {
    GDCLASS(GUIDEInputMouseAxis2D, GUIDEInput)

public:
    GUIDEInputMouseAxis2D();
    virtual ~GUIDEInputMouseAxis2D();

    virtual bool _needs_reset() const override;
    virtual void _begin_usage() override;
    virtual void _end_usage() override;
    virtual bool is_same_as(const Ref<GUIDEInput> &other) const override;
    virtual String _editor_name() const override;
    virtual String _editor_description() const override;
    virtual int _native_value_type() const override;
    virtual DeviceType _device_type() const override;

    void _refresh();

protected:
    static void _bind_methods();
};

#endif // GUIDE_INPUT_MOUSE_AXIS_2D_H