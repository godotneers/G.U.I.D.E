#ifndef GUIDE_INPUT_JOY_BASE_H
#define GUIDE_INPUT_JOY_BASE_H

#include "guide_input.h"

using namespace godot;

class GUIDEInputJoyBase : public GUIDEInput {
    GDCLASS(GUIDEInputJoyBase, GUIDEInput)

public:
    GUIDEInputJoyBase();
    virtual ~GUIDEInputJoyBase();

    virtual DeviceType _device_type() const override;

    int get_joy_index() const { return joy_index; }
    void set_joy_index(int p_index) { joy_index = p_index; emit_changed(); }

protected:
    static void _bind_methods();

    int joy_index = -1;
};

#endif // GUIDE_INPUT_JOY_BASE_H