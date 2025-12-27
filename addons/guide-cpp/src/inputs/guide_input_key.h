#ifndef GUIDE_INPUT_KEY_H
#define GUIDE_INPUT_KEY_H

#include "guide_input.h"

using namespace godot;

class GUIDEInputKey : public GUIDEInput {
    GDCLASS(GUIDEInputKey, GUIDEInput)

public:
    GUIDEInputKey();
    virtual ~GUIDEInputKey();

    virtual void _begin_usage() override;
    virtual void _end_usage() override;
    virtual bool is_same_as(const Ref<GUIDEInput> &other) const override;
    virtual String _editor_name() const override;
    virtual String _editor_description() const override;
    virtual int _native_value_type() const override;
    virtual DeviceType _device_type() const override;

    void _refresh();

    // Getters and Setters
    int get_key() const { return key; }
    void set_key(int p_key) { key = p_key; emit_changed(); }

    bool get_shift() const { return shift; }
    void set_shift(bool p_shift) { shift = p_shift; emit_changed(); }

    bool get_control() const { return control; }
    void set_control(bool p_control) { control = p_control; emit_changed(); }

    bool get_alt() const { return alt; }
    void set_alt(bool p_alt) { alt = p_alt; emit_changed(); }

    bool get_meta() const { return meta; }
    void set_meta(bool p_meta) { meta = p_meta; emit_changed(); }

    bool get_allow_additional_modifiers() const { return allow_additional_modifiers; }
    void set_allow_additional_modifiers(bool p_allow) { allow_additional_modifiers = p_allow; emit_changed(); }

protected:
    static void _bind_methods();

    int key = 0;
    bool shift = false;
    bool control = false;
    bool alt = false;
    bool meta = false;
    bool allow_additional_modifiers = true;

    TypedArray<int> _must_be_pressed;
    TypedArray<int> _must_not_be_pressed;
};

#endif // GUIDE_INPUT_KEY_H