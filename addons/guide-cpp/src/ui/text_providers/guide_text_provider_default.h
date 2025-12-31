#ifndef GUIDE_TEXT_PROVIDER_DEFAULT_H
#define GUIDE_TEXT_PROVIDER_DEFAULT_H

#include "../guide_text_provider.h"
#include <godot_cpp/classes/os.hpp>
#include <godot_cpp/classes/display_server.hpp>
#include <godot_cpp/variant/utility_functions.hpp>
#include <godot_cpp/classes/translation_server.hpp>

#include "inputs/guide_input_key.h"
#include "inputs/guide_input_mouse_button.h"
#include "inputs/guide_input_mouse_axis_1d.h"
#include "inputs/guide_input_mouse_axis_2d.h"
#include "inputs/guide_input_mouse_position.h"
#include "inputs/guide_input_joy_button.h"
#include "inputs/guide_input_joy_axis_1d.h"
#include "inputs/guide_input_joy_axis_2d.h"
#include "inputs/guide_input_any.h"
#include "inputs/guide_input_action.h"
#include "inputs/guide_input_touch_position.h"
#include "inputs/guide_input_touch_angle.h"
#include "inputs/guide_input_touch_distance.h"
#include "inputs/guide_input_touch_axis_1d.h"
#include "inputs/guide_input_touch_axis_2d.h"

namespace godot {

class GUIDETextProviderDefault : public GUIDETextProvider {
    GDCLASS(GUIDETextProviderDefault, GUIDETextProvider)

public:
    GUIDETextProviderDefault() {
        priority = 0;
        _is_on_desktop = OS::get_singleton()->has_feature("linuxbsd") || 
                         OS::get_singleton()->has_feature("macos") || 
                         OS::get_singleton()->has_feature("windows");
    }

    virtual ~GUIDETextProviderDefault() {}

    bool supports(const Ref<GUIDEInput> &input, const Ref<GUIDEInputFormattingOptions> &options) const override {
        return true;
    }

    String get_text(const Ref<GUIDEInput> &input, const Ref<GUIDEInputFormattingOptions> &options) const override {
        if (auto ik = Object::cast_to<GUIDEInputKey>(input.ptr())) {
            Key key = ik->get_key();
            if (_is_on_desktop) {
                key = DisplayServer::get_singleton()->keyboard_get_label_from_physical(key);
            }
            return _format(OS::get_singleton()->get_keycode_string(key));
        }

        if (auto mb = Object::cast_to<GUIDEInputMouseButton>(input.ptr())) {
            switch (mb->get_button()) {
                case MOUSE_BUTTON_LEFT: return _format(tr("Left Mouse Button"));
                case MOUSE_BUTTON_RIGHT: return _format(tr("Right Mouse Button"));
                case MOUSE_BUTTON_MIDDLE: return _format(tr("Middle Mouse Button"));
                case MOUSE_BUTTON_WHEEL_UP: return _format(tr("Mouse Wheel Up"));
                case MOUSE_BUTTON_WHEEL_DOWN: return _format(tr("Mouse Wheel Down"));
                case MOUSE_BUTTON_WHEEL_LEFT: return _format(tr("Mouse Wheel Left"));
                case MOUSE_BUTTON_WHEEL_RIGHT: return _format(tr("Mouse Wheel Right"));
                case MOUSE_BUTTON_XBUTTON1: return _format(tr("Mouse Side 1"));
                case MOUSE_BUTTON_XBUTTON2: return _format(tr("Mouse Side 2"));
                default: break;
            }
        }

        if (auto ma1 = Object::cast_to<GUIDEInputMouseAxis1D>(input.ptr())) {
            return (ma1->get_axis() == GUIDEInputMouseAxis1D::AXIS_X) ? _format(tr("Mouse Left/Right")) : _format(tr("Mouse Up/Down"));
        }

        if (Object::cast_to<GUIDEInputMouseAxis2D>(input.ptr())) return _format(tr("Mouse"));
        if (Object::cast_to<GUIDEInputMousePosition>(input.ptr())) return _format(tr("Mouse Position"));

        if (auto jb = Object::cast_to<GUIDEInputJoyButton>(input.ptr())) {
            return _format(tr("Joy %d") % Array::make(jb->get_button()));
        }

        if (auto ja1 = Object::cast_to<GUIDEInputJoyAxis1D>(input.ptr())) {
            switch (ja1->get_axis()) {
                case JOY_AXIS_LEFT_X: return _format(tr("Stick 1 Horizontal"));
                case JOY_AXIS_LEFT_Y: return _format(tr("Stick 1 Vertical"));
                case JOY_AXIS_RIGHT_X: return _format(tr("Stick 2 Horizontal"));
                case JOY_AXIS_RIGHT_Y: return _format(tr("Stick 2 Vertical"));
                case JOY_AXIS_TRIGGER_LEFT: return _format(tr("Axis 3"));
                case JOY_AXIS_TRIGGER_RIGHT: return _format(tr("Axis 4"));
                default: break;
            }
        }

        if (auto ja2 = Object::cast_to<GUIDEInputJoyAxis2D>(input.ptr())) {
            switch (ja2->get_x_axis()) {
                case JOY_AXIS_LEFT_X: case JOY_AXIS_LEFT_Y: return _format(tr("Stick 1"));
                case JOY_AXIS_RIGHT_X: case JOY_AXIS_RIGHT_Y: return _format(tr("Stick 2"));
                default: break;
            }
        }

        if (auto ia = Object::cast_to<GUIDEInputAction>(input.ptr())) {
            return _format(tr("Action %s") % Array::make(ia->get_action().is_valid() ? ia->get_action()->_editor_name() : "?"));
        }

        if (auto any = Object::cast_to<GUIDEInputAny>(input.ptr())) {
            TypedArray<String> parts;
            if (any->get_joy_buttons() || any->get_joy_axes()) parts.append(tr("Joy"));
            if (any->get_mouse_buttons() || any->get_mouse_movement()) parts.append(tr("Mouse"));
            if (any->get_keyboard()) parts.append(tr("Key"));
            String joined = "";
            for(int i=0; i<parts.size(); i++) {
                if (i>0) joined += "/";
                joined += (String)parts[i];
            }
            return _format(tr("Any %s") % Array::make(joined));
        }

        if (auto tp = Object::cast_to<GUIDEInputTouchPosition>(input.ptr())) {
            return _format(tr("Touch Position %s") % Array::make(tp->get_finger_index() >= 0 ? String::num(tp->get_finger_index()) : "Average"));
        }

        if (Object::cast_to<GUIDEInputTouchAngle>(input.ptr())) return _format(tr("Touch Angle"));
        if (Object::cast_to<GUIDEInputTouchDistance>(input.ptr())) return _format(tr("Touch Distance"));

        if (auto ta1 = Object::cast_to<GUIDEInputTouchAxis1D>(input.ptr())) {
            String label = (ta1->get_axis() == GUIDEInputTouchAxis1D::AXIS_X) ? tr("Touch Left/Right") : tr("Touch Up/Down");
            return _format(label + " " + (ta1->get_finger_index() >= 0 ? String::num(ta1->get_finger_index()) : "Average"));
        }

        if (auto ta2 = Object::cast_to<GUIDEInputTouchAxis2D>(input.ptr())) {
            return _format(tr("Touch Axis 2D %s") % Array::make(ta2->get_finger_index() >= 0 ? String::num(ta2->get_finger_index()) : "Average"));
        }

        return _format("??");
    }

protected:
    static void _bind_methods() {}

private:
    bool _is_on_desktop = false;

    String _format(const String &input) const {
        return "[" + input + "]";
    }
};

} // namespace godot

#endif // GUIDE_TEXT_PROVIDER_DEFAULT_H
