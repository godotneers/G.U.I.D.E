#ifndef GUIDE_INPUT_JOY_BUTTON_H
#define GUIDE_INPUT_JOY_BUTTON_H

#include "guide_input_joy_base.h"

using namespace godot;

class GUIDEInputJoyButton : public GUIDEInputJoyBase {
    GDCLASS(GUIDEInputJoyButton, GUIDEInputJoyBase)

public:
    GUIDEInputJoyButton();
    virtual ~GUIDEInputJoyButton();

    virtual void _begin_usage() override;
    virtual void _end_usage() override;
    virtual bool is_same_as(const Ref<GUIDEInput> &other) const override;
    virtual String _editor_name() const override;
    virtual String _editor_description() const override;
    virtual int _native_value_type() const override;

    void _refresh();

    int get_button() const { return button; }
    void set_button(int p_button) { button = p_button; emit_changed(); }

protected:
    static void _bind_methods();

    int button = 0;
};

#endif // GUIDE_INPUT_JOY_BUTTON_H