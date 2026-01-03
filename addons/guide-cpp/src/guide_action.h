#ifndef GUIDE_ACTION_H
#define GUIDE_ACTION_H

#include <godot_cpp/classes/resource.hpp>
#include <godot_cpp/variant/string_name.hpp>
#include <godot_cpp/variant/vector3.hpp>
#include <godot_cpp/core/class_db.hpp>

using namespace godot;

class GUIDEAction : public Resource {
    GDCLASS(GUIDEAction, Resource)

public:
    enum GUIDEActionValueType {
        BOOL = 0,
        AXIS_1D = 1,
        AXIS_2D = 2,
        AXIS_3D = 3
    };

    enum GUIDEActionState {
        TRIGGERED,
        ONGOING,
        COMPLETED
    };

    GUIDEAction();
    virtual ~GUIDEAction();

    void _triggered(Vector3 value, double delta);
    void _started(Vector3 value);
    void _ongoing(Vector3 value, double delta);
    void _cancelled(Vector3 value);
    void _completed(Vector3 value);
    void _emit_godot_action_maybe(bool pressed);
    void _update_value(Vector3 value);

    bool is_triggered() const;
    bool is_completed() const;
    bool is_ongoing() const;
    String _editor_name() const;

    // Getters and Setters for properties
    StringName get_action_name() const { return name; }
    void set_action_name(const StringName &p_name) { name = p_name; emit_changed(); }

    GUIDEActionValueType get_action_value_type() const { return action_value_type; }
    void set_action_value_type(GUIDEActionValueType p_type) { action_value_type = p_type; emit_changed(); }

    bool get_block_lower_priority_actions() const { return block_lower_priority_actions; }
    void set_block_lower_priority_actions(bool p_block) { block_lower_priority_actions = p_block; emit_changed(); }

    bool get_emit_as_godot_actions() const { return emit_as_godot_actions; }
    void set_emit_as_godot_actions(bool p_emit) { emit_as_godot_actions = p_emit; emit_changed(); }

    bool get_is_remappable() const { return is_remappable; }
    void set_is_remappable(bool p_remappable) { is_remappable = p_remappable; emit_changed(); }

    String get_display_name() const { return display_name; }
    void set_display_name(const String &p_name) { display_name = p_name; emit_changed(); }

    String get_display_category() const { return display_category; }
    void set_display_category(const String &p_category) { display_category = p_category; emit_changed(); }

    bool get_value_bool() const { return _value_bool; }
    double get_value_axis_1d() const { return _value.x; }
    Vector2 get_value_axis_2d() const { return _value_axis_2d; }
    Vector3 get_value_axis_3d() const { return _value; }

    double get_elapsed_seconds() const { return _elapsed_seconds; }
    double get_elapsed_ratio() const { return _elapsed_ratio; }
    double get_triggered_seconds() const { return _triggered_seconds; }

    GUIDEActionState get_last_state() const { return _last_state; }
    void set_last_state(GUIDEActionState p_state) { _last_state = p_state; }

    double get_trigger_hold_threshold() const { return _trigger_hold_threshold; }
    void set_trigger_hold_threshold(double p_threshold) { _trigger_hold_threshold = p_threshold; }

protected:
    static void _bind_methods();

    StringName name;
    GUIDEActionValueType action_value_type = BOOL;
    bool block_lower_priority_actions = true;
    bool emit_as_godot_actions = false;
    bool is_remappable = false;
    String display_name;
    String display_category;

    GUIDEActionState _last_state = COMPLETED;
    bool _value_bool = false;
    Vector2 _value_axis_2d = Vector2(0, 0);
    Vector3 _value = Vector3(0, 0, 0);

    double _elapsed_seconds = 0.0;
    double _elapsed_ratio = 0.0;
    double _triggered_seconds = 0.0;
    double _trigger_hold_threshold = -1.0;
};

VARIANT_ENUM_CAST(GUIDEAction::GUIDEActionValueType);
VARIANT_ENUM_CAST(GUIDEAction::GUIDEActionState);

#endif // GUIDE_ACTION_H
