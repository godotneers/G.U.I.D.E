#include "guide_input_action.h"

using namespace godot;

void GUIDEInputAction::_bind_methods() {
    ClassDB::bind_method(D_METHOD("get_action"), &GUIDEInputAction::get_action);
    ClassDB::bind_method(D_METHOD("set_action", "action"), &GUIDEInputAction::set_action);
    ADD_PROPERTY(PropertyInfo(Variant::OBJECT, "action", PROPERTY_HINT_RESOURCE_TYPE, "GUIDEAction"), "set_action", "get_action");

    ClassDB::bind_method(D_METHOD("_on"), &GUIDEInputAction::_on);
    ClassDB::bind_method(D_METHOD("_off"), &GUIDEInputAction::_off);
}

GUIDEInputAction::GUIDEInputAction() {
}

GUIDEInputAction::~GUIDEInputAction() {
}

void GUIDEInputAction::_begin_usage() {
    if (action.is_valid()) {
        action->connect("triggered", Callable(this, "_on"));
        action->connect("completed", Callable(this, "_off"));
        action->connect("ongoing", Callable(this, "_off"));
        if (action->is_triggered()) {
            _on();
            return;
        }
    }
    _off();
}

void GUIDEInputAction::_end_usage() {
    if (action.is_valid()) {
        action->disconnect("triggered", Callable(this, "_on"));
        action->disconnect("completed", Callable(this, "_off"));
        action->disconnect("ongoing", Callable(this, "_off"));
    }
}

void GUIDEInputAction::_on() {
    if (action.is_valid()) {
        _value = action->v_get_value_axis_3d();
    }
}

void GUIDEInputAction::_off() {
    _value = Vector3(0, 0, 0);
}

bool GUIDEInputAction::is_same_as(const Ref<GUIDEInput> &other) const {
    Ref<GUIDEInputAction> o = other;
    if (o.is_null()) return false;
    return o->action == action;
}

String GUIDEInputAction::_editor_name() const {
    return "Action";
}

String GUIDEInputAction::_editor_description() const {
    return "An input that mirrors the action's value while the action is triggered.";
}

int GUIDEInputAction::_native_value_type() const {
    return 3; // AXIS_3D
}