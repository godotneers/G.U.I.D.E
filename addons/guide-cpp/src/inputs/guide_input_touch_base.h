#ifndef GUIDE_INPUT_TOUCH_BASE_H
#define GUIDE_INPUT_TOUCH_BASE_H

#include "guide_input.h"
#include <godot_cpp/core/math.hpp>

using namespace godot;

class GUIDEInputTouchBase : public GUIDEInput {
    GDCLASS(GUIDEInputTouchBase, GUIDEInput)

public:
    GUIDEInputTouchBase();
    virtual ~GUIDEInputTouchBase();

    virtual DeviceType _device_type() const override { return TOUCH; }

    int get_finger_count() const { return finger_count; }
    void set_finger_count(int p_count) { finger_count = Math::max(1, p_count); emit_changed(); }

    int get_finger_index() const { return finger_index; }
    void set_finger_index(int p_index) { finger_index = Math::max(-1, p_index); emit_changed(); }

protected:
    static void _bind_methods();

    int finger_count = 1;
    int finger_index = 0;
};

#endif // GUIDE_INPUT_TOUCH_BASE_H
