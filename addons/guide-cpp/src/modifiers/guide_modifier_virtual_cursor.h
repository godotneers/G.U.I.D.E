#ifndef GUIDE_MODIFIER_VIRTUAL_CURSOR_H
#define GUIDE_MODIFIER_VIRTUAL_CURSOR_H

#include "guide_modifier.h"

using namespace godot;

class GUIDEModifierVirtualCursor : public GUIDEModifier {
    GDCLASS(GUIDEModifierVirtualCursor, GUIDEModifier)

public:
    enum ScreenScale {
        SCALE_NONE = 0,
        SCALE_LONGER_AXIS = 1,
        SCALE_SHORTER_AXIS = 2
    };

    GUIDEModifierVirtualCursor();
    virtual ~GUIDEModifierVirtualCursor();

    virtual bool is_same_as(const Ref<GUIDEModifier> &other) const override;
    virtual void _begin_usage() override;
    virtual void _end_usage() override;
    virtual Vector3 _modify_input(Vector3 input, double delta, int value_type) const override;
    virtual String _editor_name() const override { return "Virtual Cursor"; }
    virtual String _editor_description() const override { return "Stateful modifier providing a virtual cursor driven by input."; }

    // Getters and Setters
    Vector2 get_initial_position() const { return initial_position; }
    void set_initial_position(Vector2 p_val) { initial_position = p_val.clamp(Vector2(0, 0), Vector2(1, 1)); emit_changed(); }

    bool get_initialize_from_mouse_position() const { return initialize_from_mouse_position; }
    void set_initialize_from_mouse_position(bool p_val) { initialize_from_mouse_position = p_val; emit_changed(); }

    bool get_apply_to_mouse_position_on_deactivation() const { return apply_to_mouse_position_on_deactivation; }
    void set_apply_to_mouse_position_on_deactivation(bool p_val) { apply_to_mouse_position_on_deactivation = p_val; emit_changed(); }

    Vector3 get_speed() const { return speed; }
    void set_speed(Vector3 p_val) { speed = p_val; emit_changed(); }

    int get_screen_scale() const { return (int)screen_scale; }
    void set_screen_scale(int p_val) { screen_scale = (ScreenScale)p_val; emit_changed(); }

    bool get_apply_delta_time() const { return apply_delta_time; }
    void set_apply_delta_time(bool p_val) { apply_delta_time = p_val; emit_changed(); }

protected:
    static void _bind_methods();

private:
    Vector2 initial_position = Vector2(0.5, 0.5);
    bool initialize_from_mouse_position = false;
    bool apply_to_mouse_position_on_deactivation = false;
    Vector3 speed = Vector3(1, 1, 1);
    ScreenScale screen_scale = SCALE_LONGER_AXIS;
    bool apply_delta_time = true;

    mutable Vector3 _offset;
    Vector2 _get_scaled_screen_size() const;
};

VARIANT_ENUM_CAST(GUIDEModifierVirtualCursor::ScreenScale);

#endif // GUIDE_MODIFIER_VIRTUAL_CURSOR_H