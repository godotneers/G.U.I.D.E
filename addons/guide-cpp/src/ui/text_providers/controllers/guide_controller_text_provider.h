#ifndef GUIDE_CONTROLLER_TEXT_PROVIDER_H
#define GUIDE_CONTROLLER_TEXT_PROVIDER_H

#include "ui/guide_text_provider.h"
#include "ui/guide_formatting_utils.h"
#include "guide_controller_label_set.h"
#include "inputs/guide_input_joy_axis_1d.h"
#include "inputs/guide_input_joy_axis_2d.h"
#include "inputs/guide_input_joy_button.h"
#include <godot_cpp/classes/resource_loader.hpp>

using namespace godot;

class GUIDEControllerTextProvider : public GUIDETextProvider {
    GDCLASS(GUIDEControllerTextProvider, GUIDETextProvider)

public:
    GUIDEControllerTextProvider() {
        priority = -10;
    }
    virtual ~GUIDEControllerTextProvider() {}

    static void set_label_set(GUIDEFormattingUtils::ControllerType type, const Ref<GUIDEControllerLabelSet> &label_set) {
        if (label_set.is_null()) {
            UtilityFunctions::push_error("Label set must not be null.");
            return;
        }
        if (type == GUIDEFormattingUtils::CONTROLLER_UNKNOWN) {
            UtilityFunctions::push_error("Cannot set label set for the unknown controller. Use GUIDEInputFormattingOptions to set up how unknown controllers are rendered.");
            return;
        }
        _controller_label_sets[type] = label_set;
    }

    virtual bool supports(const Ref<GUIDEInput> &input, const Ref<GUIDEInputFormattingOptions> &options) const override {
        return GUIDEFormattingUtils::effective_controller_type(input, options) != GUIDEFormattingUtils::CONTROLLER_UNKNOWN;
    }

    virtual String get_text(const Ref<GUIDEInput> &input, const Ref<GUIDEInputFormattingOptions> &options) const override {
        GUIDEFormattingUtils::ControllerType type = GUIDEFormattingUtils::effective_controller_type(input, options);
        
        // Lazy load default label sets if empty
        if (_controller_label_sets.is_empty()) {
            _controller_label_sets[GUIDEFormattingUtils::CONTROLLER_MICROSOFT] = ResourceLoader::get_singleton()->load("res://addons/guide/ui/text_providers/controllers/label_sets/microsoft.tres");
            _controller_label_sets[GUIDEFormattingUtils::CONTROLLER_NINTENDO] = ResourceLoader::get_singleton()->load("res://addons/guide/ui/text_providers/controllers/label_sets/nintendo.tres");
            _controller_label_sets[GUIDEFormattingUtils::CONTROLLER_SONY] = ResourceLoader::get_singleton()->load("res://addons/guide/ui/text_providers/controllers/label_sets/sony.tres");
        }

        Ref<GUIDEControllerLabelSet> label_set = _controller_label_sets[type];
        if (label_set.is_null()) return _format("??");

        if (auto ja1 = Object::cast_to<GUIDEInputJoyAxis1D>(input.ptr())) {
            switch (ja1->get_axis()) {
                case JOY_AXIS_LEFT_X: return _format(tr(label_set->left_stick_horizontal_movement));
                case JOY_AXIS_LEFT_Y: return _format(tr(label_set->left_stick_vertical_movement));
                case JOY_AXIS_RIGHT_X: return _format(tr(label_set->right_stick_horizontal_movement));
                case JOY_AXIS_RIGHT_Y: return _format(tr(label_set->right_stick_vertical_movement));
                case JOY_AXIS_TRIGGER_LEFT: return _format(tr(label_set->left_trigger));
                case JOY_AXIS_TRIGGER_RIGHT: return _format(tr(label_set->right_trigger));
            }
        }

        if (auto ja2 = Object::cast_to<GUIDEInputJoyAxis2D>(input.ptr())) {
            switch (ja2->get_x_axis()) {
                case JOY_AXIS_LEFT_X: case JOY_AXIS_LEFT_Y: return _format(tr(label_set->left_stick));
                case JOY_AXIS_RIGHT_X: case JOY_AXIS_RIGHT_Y: return _format(tr(label_set->right_stick));
                default: break;
            }
        }

        if (auto jb = Object::cast_to<GUIDEInputJoyButton>(input.ptr())) {
            switch (jb->get_button()) {
                case JOY_BUTTON_A: return _format(tr(label_set->a_button));
                case JOY_BUTTON_B: return _format(tr(label_set->b_button));
                case JOY_BUTTON_X: return _format(tr(label_set->x_button));
                case JOY_BUTTON_Y: return _format(tr(label_set->y_button));
                case JOY_BUTTON_DPAD_LEFT: return _format(tr(label_set->dpad_left));
                case JOY_BUTTON_DPAD_RIGHT: return _format(tr(label_set->dpad_right));
                case JOY_BUTTON_DPAD_UP: return _format(tr(label_set->dpad_up));
                case JOY_BUTTON_DPAD_DOWN: return _format(tr(label_set->dpad_down));
                case JOY_BUTTON_LEFT_SHOULDER: return _format(tr(label_set->left_bumper));
                case JOY_BUTTON_RIGHT_SHOULDER: return _format(tr(label_set->right_bumper));
                case JOY_BUTTON_LEFT_STICK: return _format(tr(label_set->left_stick_click));
                case JOY_BUTTON_RIGHT_STICK: return _format(tr(label_set->right_stick_click));
                case JOY_BUTTON_BACK: return _format(tr(label_set->back));
                case JOY_BUTTON_MISC1: return _format(tr(label_set->misc1));
                case JOY_BUTTON_START: return _format(tr(label_set->start));
                case JOY_BUTTON_TOUCHPAD: return _format(tr(label_set->touch_pad));
            }
        }

        return _format("??");
    }

protected:
    static void _bind_methods() {
        ClassDB::bind_static_method("GUIDEControllerTextProvider", D_METHOD("set_label_set", "type", "label_set"), &GUIDEControllerTextProvider::set_label_set);
    }

private:
    static inline Dictionary _controller_label_sets;

    String _format(const String &p_input) const {
        return "[" + p_input + "]";
    }
};

#endif // GUIDE_CONTROLLER_TEXT_PROVIDER_H
