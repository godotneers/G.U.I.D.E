#ifndef GUIDE_INPUT_ACTION_H
#define GUIDE_INPUT_ACTION_H

#include "guide_input.h"
#include "../guide_action.h"

using namespace godot;

class GUIDEInputAction : public GUIDEInput {
    GDCLASS(GUIDEInputAction, GUIDEInput)

public:
    GUIDEInputAction();
    virtual ~GUIDEInputAction();

    virtual void _begin_usage() override;
    virtual void _end_usage() override;
    virtual bool is_same_as(const Ref<GUIDEInput> &other) const override;
    virtual String _editor_name() const override;
    virtual String _editor_description() const override;
    virtual GUIDEAction::GUIDEActionValueType _native_value_type() const override;

    void _on();
    void _off();

    Ref<GUIDEAction> get_action() const { return action; }
    void set_action(const Ref<GUIDEAction> &p_action) { action = p_action; emit_changed(); }

protected:
    static void _bind_methods();
    String _to_string() const;

    Ref<GUIDEAction> action;
};

#endif // GUIDE_INPUT_ACTION_H