#ifndef GUIDE_VIRTUAL_JOY_RENDERERS_H
#define GUIDE_VIRTUAL_JOY_RENDERERS_H

#include <godot_cpp/classes/control.hpp>
#include <godot_cpp/classes/sprite2d.hpp>
#include "virtual_button/guide_virtual_button.h"
#include "virtual_stick/guide_virtual_stick.h"

using namespace godot;

class GUIDEVirtualButtonRenderer : public Control {
    GDCLASS(GUIDEVirtualButtonRenderer, Control)

public:
    GUIDEVirtualButtonRenderer() {}
    virtual ~GUIDEVirtualButtonRenderer() {}

    void _notification(int p_what);
    virtual void _on_configuration_changed() {}
    virtual void _update(bool is_actuated) {}

    bool is_button_actuated() const { return _button ? _button->_is_actuated : false; }
    double get_button_radius() const { return _button ? _button->get_button_radius() : 0.0; }

protected:
    static void _bind_methods();
    GUIDEVirtualButton *_button = nullptr;
};

class GUIDEVirtualStickRenderer : public Control {
    GDCLASS(GUIDEVirtualStickRenderer, Control)

public:
    GUIDEVirtualStickRenderer() {}
    virtual ~GUIDEVirtualStickRenderer() {}

    void _notification(int p_what);
    virtual void _on_configuration_changed() {}
    void _on_stick_changed();
    virtual void _update(Vector2 joy_position, Vector2 joy_offset, bool is_actuated) {}

    double get_stick_radius() const { return _stick ? _stick->get_stick_radius() : 0.0; }
    double get_max_actuation_radius() const { return _stick ? _stick->get_max_actuation_radius() : 0.0; }
    double get_interaction_zone_radius() const { return _stick ? _stick->get_interaction_zone_radius() : 0.0; }
    Vector2 get_stick_position() const { return _stick ? _stick->get_stick_relative_position() : Vector2(0, 0); }
    bool is_stick_actuated() const { return _stick ? _stick->_is_actuated : false; }

protected:
    static void _bind_methods();
    GUIDEVirtualStick *_stick = nullptr;
    bool _was_actuated = false;
};

#endif // GUIDE_VIRTUAL_JOY_RENDERERS_H