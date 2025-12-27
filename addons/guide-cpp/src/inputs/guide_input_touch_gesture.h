#ifndef GUIDE_INPUT_TOUCH_GESTURE_H
#define GUIDE_INPUT_TOUCH_GESTURE_H

#include "guide_input.h"

using namespace godot;

class GUIDEInputTouchDistance : public GUIDEInput {
    GDCLASS(GUIDEInputTouchDistance, GUIDEInput)

public:
    GUIDEInputTouchDistance();
    virtual ~GUIDEInputTouchDistance();

    virtual bool _needs_reset() const override { return true; }
    virtual void _reset() override;
    virtual void _begin_usage() override;
    virtual void _end_usage() override;
    virtual bool is_same_as(const Ref<GUIDEInput> &other) const override;
    virtual String _editor_name() const override { return "Touch Distance"; }
    virtual String _editor_description() const override { return "Distance of two touching fingers."; }
    virtual int _native_value_type() const override { return 1; /* AXIS_1D */ }
    virtual DeviceType _device_type() const override { return DEVICE_TOUCH; }

    void _refresh();
    double _calculate_distance();

protected:
    static void _bind_methods();

    double _initial_distance = NAN;
};

class GUIDEInputTouchAngle : public GUIDEInput {
    GDCLASS(GUIDEInputTouchAngle, GUIDEInput)

public:
    enum AngleUnit {
        RADIANS = 0,
        DEGREES = 1
    };

    GUIDEInputTouchAngle();
    virtual ~GUIDEInputTouchAngle();

    virtual bool _needs_reset() const override { return true; }
    virtual void _reset() override;
    virtual void _begin_usage() override;
    virtual void _end_usage() override;
    virtual bool is_same_as(const Ref<GUIDEInput> &other) const override;
    virtual String _editor_name() const override { return "Touch Angle"; }
    virtual String _editor_description() const override { return "Angle changes of two touching fingers."; }
    virtual int _native_value_type() const override { return 1; /* AXIS_1D */ }
    virtual DeviceType _device_type() const override { return DEVICE_TOUCH; }

    void _refresh();
    double _calculate_angle();

    int get_unit() const { return (int)unit; }
    void set_unit(int p_unit) { unit = (AngleUnit)p_unit; emit_changed(); }

protected:
    static void _bind_methods();

    AngleUnit unit = RADIANS;
    double _initial_angle = NAN;
};

VARIANT_ENUM_CAST(GUIDEInputTouchAngle::AngleUnit);

#endif // GUIDE_INPUT_TOUCH_GESTURE_H