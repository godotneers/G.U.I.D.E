#include "guide_input_mouse_position.h"
#include "guide_input_state.h"

using namespace godot;

void GUIDEInputMousePosition::_bind_methods() {
    ClassDB::bind_method(D_METHOD("_refresh"), &GUIDEInputMousePosition::_refresh);
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
    return other.is_valid() && other->get_class() == get_class();
}