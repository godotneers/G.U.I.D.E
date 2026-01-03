#ifndef GUIDE_VIRTUAL_STICK_RENDERER_H
#define GUIDE_VIRTUAL_STICK_RENDERER_H

#include <godot_cpp/classes/control.hpp>
#include <godot_cpp/classes/engine.hpp>
#include "guide_virtual_stick.h"

using namespace godot;

class GUIDEVirtualStickRenderer : public Control {
    GDCLASS(GUIDEVirtualStickRenderer, Control)

public:
    GUIDEVirtualStickRenderer() {}
    virtual ~GUIDEVirtualStickRenderer() {}

    void _notification(int p_what) {
        if (p_what == NOTIFICATION_ENTER_TREE) {
            _stick = Object::cast_to<GUIDEVirtualStick>(get_parent());
            if (_stick) {
                _stick->connect("configuration_changed", Callable(this, "_on_configuration_changed"));
                if (!Engine::get_singleton()->is_editor_hint()) {
                    _stick->connect("changed", Callable(this, "_on_stick_changed"));
                }
            } else {
                UtilityFunctions::push_error("Stick renderer must be a child of GUIDEVirtualStick. Stick renderer will not work.");
            }
        }
    }

    virtual void _on_configuration_changed() {}
    
    void _on_stick_changed() {
        if (!_stick) return;
        Vector2 direction(0, 0);
        if (!_stick->_start_pos.is_equal_approx(_stick->_current_pos)) {
            direction = _stick->_start_pos.direction_to(_stick->_current_pos);
        }
        double distance = _stick->_start_pos.distance_to(_stick->_current_pos);
        Vector2 offset = direction * (distance / _stick->get_max_actuation_radius());

        if(_stick->_is_actuated && !_was_actuated) { _was_actuated = true; }
        if(!_stick->_is_actuated && _was_actuated) { _was_actuated = false; }

        _update(_stick->_current_pos - get_global_position(), offset, _stick->_is_actuated);
    }

    virtual void _update(Vector2 joy_position, Vector2 joy_offset, bool is_actuated) {}

    PackedStringArray _get_configuration_warnings() const override {
        PackedStringArray warnings = Control::_get_configuration_warnings();
        if (Object::cast_to<GUIDEVirtualStick>(get_parent()) == nullptr) {
            warnings.append("Stick renderer must be a child of GUIDEVirtualStick");
        }
        return warnings;
    }

    double get_stick_radius() const { return _stick ? _stick->get_stick_radius() : 0.0; }
    double get_max_actuation_radius() const { return _stick ? _stick->get_max_actuation_radius() : 0.0; }
    double get_interaction_zone_radius() const { return _stick ? _stick->get_interaction_zone_radius() : 0.0; }
    Vector2 get_stick_position() const { return _stick ? _stick->get_stick_relative_position() : Vector2(0, 0); }
    bool is_stick_actuated() const { return _stick ? _stick->_is_actuated : false; }

protected:
    static void _bind_methods() {
        ClassDB::bind_method(D_METHOD("_on_stick_changed"), &GUIDEVirtualStickRenderer::_on_stick_changed);
        ClassDB::bind_method(D_METHOD("_on_configuration_changed"), &GUIDEVirtualStickRenderer::_on_configuration_changed);
    }
    GUIDEVirtualStick *_stick = nullptr;
    bool _was_actuated = false;
};

#endif // GUIDE_VIRTUAL_STICK_RENDERER_H
