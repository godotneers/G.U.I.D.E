#ifndef GUIDE_INPUT_MOUSE_AXIS_1D_H
#define GUIDE_INPUT_MOUSE_AXIS_1D_H

#include "guide_input.h"

using namespace godot;

class GUIDEInputMouseAxis1D : public GUIDEInput {
    GDCLASS(GUIDEInputMouseAxis1D, GUIDEInput)

public:
    enum GUIDEInputMouseAxis {
        AXIS_X,
        AXIS_Y
    };

    GUIDEInputMouseAxis1D();
    virtual ~GUIDEInputMouseAxis1D();

    virtual bool _needs_reset() const override;
    virtual void _begin_usage() override;
    virtual void _end_usage() override;
    virtual bool is_same_as(const Ref<GUIDEInput> &other) const override;
    virtual String _editor_name() const override;
    virtual String _editor_description() const override;
    virtual GUIDEAction::GUIDEActionValueType _native_value_type() const override;
    virtual DeviceType _device_type() const override;

    void _refresh();

    GUIDEInputMouseAxis get_axis() const { return axis; }
    void set_axis(GUIDEInputMouseAxis p_axis) { axis = p_axis; emit_changed(); }

protected:
    static void _bind_methods();
    String _to_string() const;

    GUIDEInputMouseAxis axis = AXIS_X;
};

VARIANT_ENUM_CAST(GUIDEInputMouseAxis1D::GUIDEInputMouseAxis);

#endif // GUIDE_INPUT_MOUSE_AXIS_1D_H