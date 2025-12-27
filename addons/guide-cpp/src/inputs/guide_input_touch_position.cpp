#include "guide_input_touch_position.h"
#include "guide_input_state.h"
#include <godot_cpp/core/math.hpp>
#include <cmath>

using namespace godot;

void GUIDEInputTouchPosition::_bind_methods() {
    ClassDB::bind_method(D_METHOD("_refresh"), &GUIDEInputTouchPosition::_refresh);
}

void GUIDEInputTouchPosition::_begin_usage() {
    if (_state) {
        _state->connect("touch_state_changed", Callable(this, "_refresh"));
        _refresh();
    }
}

void GUIDEInputTouchPosition::_end_usage() {
    if (_state) {
        _state->disconnect("touch_state_changed", Callable(this, "_refresh"));
    }
}

void GUIDEInputTouchPosition::_refresh() {
    if (_state) {
        Vector2 pos = _state->get_finger_position(finger_index, finger_count);
        if (Math::is_nan(pos.x)) {
            _value = Vector3(NAN, NAN, NAN);
        } else {
            _value = Vector3(pos.x, pos.y, 0);
        }
    }
}

bool GUIDEInputTouchPosition::is_same_as(const Ref<GUIDEInput> &other) const {
    Ref<GUIDEInputTouchPosition> o = other;
    if (o.is_null()) return false;
    return o->get_finger_count() == finger_count && o->get_finger_index() == finger_index;
}
