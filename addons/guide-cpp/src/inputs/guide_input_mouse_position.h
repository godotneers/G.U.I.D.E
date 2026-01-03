#ifndef GUIDE_INPUT_MOUSE_POSITION_H
#define GUIDE_INPUT_MOUSE_POSITION_H

#include "guide_input.h"

using namespace godot;

class GUIDEInputMousePosition : public GUIDEInput {
    GDCLASS(GUIDEInputMousePosition, GUIDEInput)

public:
    GUIDEInputMousePosition() {}
    virtual ~GUIDEInputMousePosition() {}

    virtual void _begin_usage() override;
    virtual void _end_usage() override;
    virtual bool is_same_as(const Ref<GUIDEInput> &other) const override;
    virtual String _editor_name() const override;
    virtual String _editor_description() const override;
    virtual GUIDEAction::GUIDEActionValueType _native_value_type() const override;
    virtual DeviceType _device_type() const override;

    void _refresh();

protected:
    static void _bind_methods();
    String _to_string() const;
};

#endif // GUIDE_INPUT_MOUSE_POSITION_H