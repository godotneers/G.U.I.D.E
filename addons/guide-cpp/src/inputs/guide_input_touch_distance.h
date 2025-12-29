#ifndef GUIDE_INPUT_TOUCH_DISTANCE_H
#define GUIDE_INPUT_TOUCH_DISTANCE_H

#include "guide_input.h"

using namespace godot;

class GUIDEInputTouchDistance : public GUIDEInput {
    GDCLASS(GUIDEInputTouchDistance, GUIDEInput)

public:
    GUIDEInputTouchDistance();
    virtual ~GUIDEInputTouchDistance();

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
    double _calculate_distance();

protected:
    static void _bind_methods();
    String _to_string() const;

    double _initial_distance = Math_NAN;
};

#endif // GUIDE_INPUT_TOUCH_DISTANCE_H
