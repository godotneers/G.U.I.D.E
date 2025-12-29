#include "guide_input_touch_axis_base.h"
#include "guide_input_state.h"
#include <godot_cpp/core/math.hpp>
#include <limits>

using namespace godot;

void GUIDEInputTouchAxisBase::_bind_methods() {
    ClassDB::bind_method(D_METHOD("_refresh"), &GUIDEInputTouchAxisBase::_refresh);
}

GUIDEInputTouchAxisBase::GUIDEInputTouchAxisBase() {
    float INF = std::numeric_limits<float>::infinity();
    _last_position = Vector2(INF, INF);
}

GUIDEInputTouchAxisBase::~GUIDEInputTouchAxisBase() {}

bool GUIDEInputTouchAxisBase::_needs_reset() const {
    return true;
}

void GUIDEInputTouchAxisBase::_reset() {
    if (_state) {
        _last_position = _state->get_finger_position(finger_index, finger_count);
        _apply_value(_calculate_value(_last_position));
    }
}

void GUIDEInputTouchAxisBase::_begin_usage() {
    if (_state) {
        _state->connect("touch_state_changed", Callable(this, "_refresh"));
        _refresh();
    }
}

void GUIDEInputTouchAxisBase::_end_usage() {
    if (_state) {
        _state->disconnect("touch_state_changed", Callable(this, "_refresh"));
    }
}

void GUIDEInputTouchAxisBase::_refresh() {
    if (_state) {
        Vector2 new_position = _state->get_finger_position(finger_index, finger_count);
        _apply_value(_calculate_value(new_position));
    }
}

Vector2 GUIDEInputTouchAxisBase::_calculate_value(Vector2 new_position) {
    if (!_last_position.is_finite() || !new_position.is_finite()) {
        return Vector2(0, 0);
    }
    return new_position - _last_position;
}
