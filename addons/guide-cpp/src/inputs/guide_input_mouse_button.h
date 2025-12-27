#ifndef GUIDE_INPUT_MOUSE_BUTTON_H
#define GUIDE_INPUT_MOUSE_BUTTON_H

#include "guide_input.h"

using namespace godot;

class GUIDEInputMouseButton : public GUIDEInput {
    GDCLASS(GUIDEInputMouseButton, GUIDEInput)

public:
    GUIDEInputMouseButton();
    virtual ~GUIDEInputMouseButton();

    virtual bool _needs_reset() const override;
    virtual void _reset() override;
    virtual void _begin_usage() override;
    virtual void _end_usage() override;
    virtual bool is_same_as(const Ref<GUIDEInput> &other) const override;
    virtual String _editor_name() const override;
    virtual String _editor_description() const override;
    virtual int _native_value_type() const override;
    virtual DeviceType _device_type() const override;

    void _refresh();

    int get_button() const { return (int)button; }
    void set_button(int p_button) { button = (MouseButton)p_button; emit_changed(); }

protected:
    static void _bind_methods();

    MouseButton button = MOUSE_BUTTON_LEFT;
    Vector3 _reset_to;
    bool _was_pressed_this_frame = false;
};

#endif // GUIDE_INPUT_MOUSE_BUTTON_H