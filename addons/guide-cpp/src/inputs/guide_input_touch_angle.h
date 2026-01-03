#ifndef GUIDE_INPUT_TOUCH_ANGLE_H
#define GUIDE_INPUT_TOUCH_ANGLE_H

#include "guide_input.h"

using namespace godot;

class GUIDEInputTouchAngle : public GUIDEInput {
    GDCLASS(GUIDEInputTouchAngle, GUIDEInput)

public:
    enum AngleUnit {
        RADIANS = 0,
        DEGREES = 1
    };

    GUIDEInputTouchAngle();
    virtual ~GUIDEInputTouchAngle();

    virtual bool _needs_reset() const override;
    virtual void _reset() override;
    virtual void _begin_usage() override;
    virtual void _end_usage() override;
    virtual bool is_same_as(const Ref<GUIDEInput> &other) const override;
    virtual String _editor_name() const override;
    virtual String _editor_description() const override;
    virtual GUIDEAction::GUIDEActionValueType _native_value_type() const override;
    virtual DeviceType _device_type() const override;

    void _refresh();
    double _calculate_angle();

    AngleUnit get_unit() const { return unit; }
    void set_unit(AngleUnit p_unit) { unit = p_unit; emit_changed(); }

protected:
    static void _bind_methods();
    String _to_string() const;

    AngleUnit unit = RADIANS;
    double _initial_angle = Math_NAN;
};

VARIANT_ENUM_CAST(GUIDEInputTouchAngle::AngleUnit);

#endif // GUIDE_INPUT_TOUCH_ANGLE_H
