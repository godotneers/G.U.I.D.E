#ifndef GUIDE_VIRTUAL_BUTTON_RENDERER_H
#define GUIDE_VIRTUAL_BUTTON_RENDERER_H

#include <godot_cpp/classes/control.hpp>
#include <godot_cpp/classes/engine.hpp>
#include "guide_virtual_button.h"

using namespace godot;

class GUIDEVirtualButtonRenderer : public Control {
    GDCLASS(GUIDEVirtualButtonRenderer, Control)

public:
    GUIDEVirtualButtonRenderer() {}
    virtual ~GUIDEVirtualButtonRenderer() {}

    void _notification(int p_what) {
        if (p_what == NOTIFICATION_ENTER_TREE) {
            _button = Object::cast_to<GUIDEVirtualButton>(get_parent());
            if (_button) {
                _button->connect("configuration_changed", Callable(this, "_on_configuration_changed"));
                if (!Engine::get_singleton()->is_editor_hint()) {
                    _button->connect("changed", Callable(this, "_on_button_changed"));
                }
            } else {
                UtilityFunctions::push_error("Button renderer must be a child of GUIDEVirtualButton. Button renderer will not work.");
                return;
            }
        }
    }

    virtual void _on_configuration_changed() {}
    
    void _on_button_changed() {
        if (_button) {
            _update(_button->_is_actuated);
        }
    }

    virtual void _update(bool is_actuated) {}

    PackedStringArray _get_configuration_warnings() const override {
        PackedStringArray warnings = Control::_get_configuration_warnings();
        if (Object::cast_to<GUIDEVirtualButton>(get_parent()) == nullptr) {
            warnings.append("Button renderer must be a child of GUIDEVirtualButton");
        }
        return warnings;
    }

    bool is_button_actuated() const { return _button ? _button->_is_actuated : false; }
    double get_button_radius() const { return _button ? _button->get_button_radius() : 0.0; }

protected:
    static void _bind_methods() {
        ClassDB::bind_method(D_METHOD("_on_button_changed"), &GUIDEVirtualButtonRenderer::_on_button_changed);
        ClassDB::bind_method(D_METHOD("_on_configuration_changed"), &GUIDEVirtualButtonRenderer::_on_configuration_changed);
    }
    GUIDEVirtualButton *_button = nullptr;
};

#endif // GUIDE_VIRTUAL_BUTTON_RENDERER_H
