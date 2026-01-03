#ifndef GUIDE_INPUT_TOUCH_AXIS_BASE_H
#define GUIDE_INPUT_TOUCH_AXIS_BASE_H

#include "guide_input_touch_base.h"

using namespace godot;

class GUIDEInputTouchAxisBase : public GUIDEInputTouchBase {
    GDCLASS(GUIDEInputTouchAxisBase, GUIDEInputTouchBase)

public:
    GUIDEInputTouchAxisBase();
    virtual ~GUIDEInputTouchAxisBase();

    virtual bool _needs_reset() const override;
    virtual void _reset() override;
    virtual void _begin_usage() override;
    virtual void _end_usage() override;

    void _refresh();
    virtual void _apply_value(Vector2 value) {}
    Vector2 _calculate_value(Vector2 new_position);

protected:
    static void _bind_methods();

    Vector2 _last_position;
};

#endif // GUIDE_INPUT_TOUCH_AXIS_BASE_H