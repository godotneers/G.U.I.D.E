#include "guide_input_mouse_position.h"
#include "guide_input_state.h"

using namespace godot;

void GUIDEInputMousePosition::_bind_methods() {
    ClassDB::bind_method(D_METHOD("_refresh"), &GUIDEInputMousePosition::_refresh);
    ClassDB::bind_method(D_METHOD("_to_string"), &GUIDEInputMousePosition::_to_string);
}

void GUIDEInputMousePosition::_begin_usage() {
    if (_state) {
        _state->connect("mouse_position_changed", Callable(this, "_refresh"));
        _refresh();
    }
}

void GUIDEInputMousePosition::_end_usage() {
    if (_state) {
        _state->disconnect("mouse_position_changed", Callable(this, "_refresh"));
    }
}

void GUIDEInputMousePosition::_refresh() {
    if (_state) {
        Vector2 pos = _state->get_mouse_position();
        _value.x = pos.x;
        _value.y = pos.y;
    }
}

bool GUIDEInputMousePosition::is_same_as(const Ref<GUIDEInput> &other) const {
    Ref<GUIDEInputMousePosition> o = other;
    if(o.is_null()) return false;
    return true;
}

String GUIDEInputMousePosition::_to_string() const {
    return "(GUIDEInputMousePosition)";
}

String GUIDEInputMousePosition::_editor_name() const { 
    return "Mouse Position"; 
}

String GUIDEInputMousePosition::_editor_description() const { 
    return "Position of the mouse in the main viewport."; 
}

GUIDEAction::GUIDEActionValueType GUIDEInputMousePosition::_native_value_type() const {
    return GUIDEAction::AXIS_2D; 
}

GUIDEInput::DeviceType GUIDEInputMousePosition::_device_type() const { 
    return GUIDEInput::MOUSE; 
}
