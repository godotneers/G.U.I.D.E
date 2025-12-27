#include "guide_action.h"
#include <godot_cpp/classes/input.hpp>
#include <godot_cpp/classes/input_event_action.hpp>
#include <godot_cpp/core/math.hpp>
#include <cmath>

using namespace godot;

void GUIDEAction::_bind_methods() {
    BIND_ENUM_CONSTANT(BOOL);
    BIND_ENUM_CONSTANT(AXIS_1D);
    BIND_ENUM_CONSTANT(AXIS_2D);
    BIND_ENUM_CONSTANT(AXIS_3D);

    BIND_ENUM_CONSTANT(TRIGGERED);
    BIND_ENUM_CONSTANT(ONGOING);
    BIND_ENUM_CONSTANT(COMPLETED);

    ClassDB::bind_method(D_METHOD("get_action_name"), &GUIDEAction::get_action_name);
    ClassDB::bind_method(D_METHOD("set_action_name", "name"), &GUIDEAction::set_action_name);
    ADD_PROPERTY(PropertyInfo(Variant::STRING_NAME, "name"), "set_action_name", "get_action_name");

    ClassDB::bind_method(D_METHOD("get_action_value_type"), &GUIDEAction::get_action_value_type);
    ClassDB::bind_method(D_METHOD("set_action_value_type", "type"), &GUIDEAction::set_action_value_type);
    ADD_PROPERTY(PropertyInfo(Variant::INT, "action_value_type", PROPERTY_HINT_ENUM, "BOOL,AXIS_1D,AXIS_2D,AXIS_3D"), "set_action_value_type", "get_action_value_type");

    ClassDB::bind_method(D_METHOD("get_block_lower_priority_actions"), &GUIDEAction::get_block_lower_priority_actions);
    ClassDB::bind_method(D_METHOD("set_block_lower_priority_actions", "block"), &GUIDEAction::set_block_lower_priority_actions);
    ADD_PROPERTY(PropertyInfo(Variant::BOOL, "block_lower_priority_actions"), "set_block_lower_priority_actions", "get_block_lower_priority_actions");

    ClassDB::bind_method(D_METHOD("get_emit_as_godot_actions"), &GUIDEAction::get_emit_as_godot_actions);
    ClassDB::bind_method(D_METHOD("set_emit_as_godot_actions", "emit"), &GUIDEAction::set_emit_as_godot_actions);
    ADD_PROPERTY(PropertyInfo(Variant::BOOL, "emit_as_godot_actions"), "set_emit_as_godot_actions", "get_emit_as_godot_actions");

    ClassDB::bind_method(D_METHOD("get_is_remappable"), &GUIDEAction::get_is_remappable);
    ClassDB::bind_method(D_METHOD("set_is_remappable", "remappable"), &GUIDEAction::set_is_remappable);
    ADD_PROPERTY(PropertyInfo(Variant::BOOL, "is_remappable"), "set_is_remappable", "get_is_remappable");

    ClassDB::bind_method(D_METHOD("get_display_name"), &GUIDEAction::get_display_name);
    ClassDB::bind_method(D_METHOD("set_display_name", "display_name"), &GUIDEAction::set_display_name);
    ADD_PROPERTY(PropertyInfo(Variant::STRING, "display_name"), "set_display_name", "get_display_name");

    ClassDB::bind_method(D_METHOD("get_display_category"), &GUIDEAction::get_display_category);
    ClassDB::bind_method(D_METHOD("set_display_category", "display_category"), &GUIDEAction::set_display_category);
    ADD_PROPERTY(PropertyInfo(Variant::STRING, "display_category"), "set_display_category", "get_display_category");

    ADD_SIGNAL(MethodInfo("triggered"));
    ADD_SIGNAL(MethodInfo("started"));
    ADD_SIGNAL(MethodInfo("ongoing"));
    ADD_SIGNAL(MethodInfo("completed"));
    ADD_SIGNAL(MethodInfo("cancelled"));

    ClassDB::bind_method(D_METHOD("is_triggered"), &GUIDEAction::is_triggered);
    ClassDB::bind_method(D_METHOD("is_completed"), &GUIDEAction::is_completed);
    ClassDB::bind_method(D_METHOD("is_ongoing"), &GUIDEAction::is_ongoing);
    ClassDB::bind_method(D_METHOD("get_value_bool"), &GUIDEAction::get_value_bool);
    ClassDB::bind_method(D_METHOD("get_value_axis_1d"), &GUIDEAction::get_value_axis_1d);
    ClassDB::bind_method(D_METHOD("get_value_axis_2d"), &GUIDEAction::get_value_axis_2d);
    ClassDB::bind_method(D_METHOD("get_value_axis_3d"), &GUIDEAction::get_value_axis_3d);
}

GUIDEAction::GUIDEAction() {
}

GUIDEAction::~GUIDEAction() {
}

void GUIDEAction::_triggered(Vector3 value, double delta) {
    _triggered_seconds += delta;
    _elapsed_ratio = 1.0;
    _update_value(value);
    _last_state = TRIGGERED;
    emit_signal("triggered");
    _emit_godot_action_maybe(true);
}

void GUIDEAction::_started(Vector3 value) {
    _elapsed_ratio = 0.0;
    _update_value(value);
    _last_state = ONGOING;
    emit_signal("started");
    emit_signal("ongoing");
}

void GUIDEAction::_ongoing(Vector3 value, double delta) {
    _elapsed_seconds += delta;
    if (_trigger_hold_threshold > 0) {
        _elapsed_ratio = _elapsed_seconds / _trigger_hold_threshold;
    }
    _update_value(value);
    bool was_triggered = _last_state == TRIGGERED;
    _last_state = ONGOING;
    emit_signal("ongoing");
    if (was_triggered) {
        _emit_godot_action_maybe(false);
    }
}

void GUIDEAction::_cancelled(Vector3 value) {
    _elapsed_seconds = 0;
    _elapsed_ratio = 0;
    _update_value(value);
    _last_state = COMPLETED;
    emit_signal("cancelled");
    emit_signal("completed");
}

void GUIDEAction::_completed(Vector3 value) {
    _elapsed_seconds = 0;
    _elapsed_ratio = 0;
    _triggered_seconds = 0;
    _update_value(value);
    _last_state = COMPLETED;
    emit_signal("completed");
    _emit_godot_action_maybe(false);
}

void GUIDEAction::_emit_godot_action_maybe(bool pressed) {
    if (!emit_as_godot_actions) {
        return;
    }
    if (name.is_empty()) {
        return;
    }
    Ref<InputEventAction> godot_action;
    godot_action.instantiate();
    godot_action->set_action(name);
    godot_action->set_strength(_value.x);
    godot_action->set_pressed(pressed);
    Input::get_singleton()->parse_input_event(godot_action);
}

void GUIDEAction::_update_value(Vector3 value) {
    switch (action_value_type) {
        case BOOL:
        case AXIS_1D:
            _value_bool = Math::abs(value.x) > 0;
            _value_axis_2d = Vector2(Math::abs(value.x), 0);
            _value = Vector3(value.x, 0, 0);
            break;
        case AXIS_2D:
            _value_bool = Math::abs(value.x) > 0;
            _value_axis_2d = Vector2(value.x, value.y);
            _value = Vector3(value.x, value.y, 0);
            break;
        case AXIS_3D:
            _value_bool = Math::abs(value.x) > 0;
            _value_axis_2d = Vector2(value.x, value.y);
            _value = value;
            break;
    }
}

bool GUIDEAction::is_triggered() const {
    return _last_state == TRIGGERED;
}

bool GUIDEAction::is_completed() const {
    return _last_state == COMPLETED;
}

bool GUIDEAction::is_ongoing() const {
    return _last_state == ONGOING;
}

String GUIDEAction::_editor_name() const {
    if (!display_name.is_empty()) {
        return display_name;
    }
    if (!name.is_empty()) {
        return name;
    }
    return get_path().get_file().replace(".tres", "");
}