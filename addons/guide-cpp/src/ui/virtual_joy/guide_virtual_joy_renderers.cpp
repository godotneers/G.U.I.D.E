#include "guide_virtual_joy_renderers.h"
#include <godot_cpp/classes/engine.hpp>

using namespace godot;

void GUIDEVirtualButtonRenderer::_bind_methods() {
}

void GUIDEVirtualButtonRenderer::_notification(int p_what) {
    if (p_what == NOTIFICATION_ENTER_TREE) {
        _button = Object::cast_to<GUIDEVirtualButton>(get_parent());
        if (_button) {
            _button->connect("configuration_changed", Callable(this, "_on_configuration_changed"));
            if (!Engine::get_singleton()->is_editor_hint()) {
                _button->connect("changed", Callable(this, "_on_button_changed"));
            }
        }
    }
}

void GUIDEVirtualButtonRenderer::_on_button_changed() {
    _update(_button->_is_actuated);
}

void GUIDEVirtualStickRenderer::_bind_methods() {
    ClassDB::bind_method(D_METHOD("_on_stick_changed"), &GUIDEVirtualStickRenderer::_on_stick_changed);
}

void GUIDEVirtualStickRenderer::_notification(int p_what) {
    if (p_what == NOTIFICATION_ENTER_TREE) {
        _stick = Object::cast_to<GUIDEVirtualStick>(get_parent());
        if (_stick) {
            _stick->connect("configuration_changed", Callable(this, "_on_configuration_changed"));
            if (!Engine::get_singleton()->is_editor_hint()) {
                _stick->connect("changed", Callable(this, "_on_stick_changed"));
            }
        }
    }
}

void GUIDEVirtualStickRenderer::_on_stick_changed() {
    if (!_stick) return;
    Vector2 direction(0, 0);
    if (!_stick->_start_pos.is_equal_approx(_stick->_current_pos)) {
        direction = _stick->_start_pos.direction_to(_stick->_current_pos);
    }
    double distance = _stick->_start_pos.distance_to(_stick->_current_pos);
    Vector2 offset = direction * (distance / _stick->get_max_actuation_radius());

    _update(_stick->_current_pos - get_global_position(), offset, _stick->_is_actuated);
}