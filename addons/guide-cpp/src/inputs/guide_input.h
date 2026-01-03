#ifndef GUIDE_INPUT_H
#define GUIDE_INPUT_H

#include <godot_cpp/classes/resource.hpp>
#include <godot_cpp/classes/object.hpp>
#include <godot_cpp/variant/vector3.hpp>
#include <godot_cpp/core/class_db.hpp>
#include <godot_cpp/core/math_defs.hpp>
#include "guide_action.h"

using namespace godot;

class GUIDEInputState;

class GUIDEInput : public Resource {
    GDCLASS(GUIDEInput, Resource)

public:
    enum DeviceType {
        NONE = 0,
        KEYBOARD = 1,
        MOUSE = 2,
        JOY = 4,
        TOUCH = 8,
    };

    GUIDEInput();
    virtual ~GUIDEInput();

    virtual bool _needs_reset() const;
    virtual void _reset();
    virtual bool is_same_as(const Ref<GUIDEInput> &other) const;
    virtual void _begin_usage();
    virtual void _end_usage();
    virtual String _editor_name() const;
    virtual String _editor_description() const;
    virtual GUIDEAction::GUIDEActionValueType _native_value_type() const;
    virtual DeviceType _device_type() const;

    Vector3 get_value() const { return _value; }
    void set_value(const Vector3 &p_value) { _value = p_value; }

    void set_state(GUIDEInputState *p_state) { _state = p_state; }
    GUIDEInputState* get_state() const { return _state; }

protected:
    static void _bind_methods();
    String _to_string() const;

    Vector3 _value;
    GUIDEInputState *_state = nullptr;
};

VARIANT_ENUM_CAST(GUIDEInput::DeviceType);

#endif // GUIDE_INPUT_H