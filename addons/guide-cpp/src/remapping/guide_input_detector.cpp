#include "guide_input_detector.h"
#include <godot_cpp/classes/engine.hpp>
#include <godot_cpp/classes/input.hpp>
#include <godot_cpp/classes/input_event_key.hpp>
#include <godot_cpp/classes/input_event_mouse_button.hpp>
#include <godot_cpp/classes/input_event_mouse_motion.hpp>
#include <godot_cpp/classes/input_event_joypad_button.hpp>
#include <godot_cpp/classes/input_event_joypad_motion.hpp>
#include <godot_cpp/classes/viewport.hpp>
#include <godot_cpp/variant/utility_functions.hpp>
#include <godot_cpp/core/math.hpp>
#include "../guide.h"
#include "../inputs/guide_input_key.h"
#include "../inputs/guide_input_mouse_button.h"
#include "../inputs/guide_input_mouse_axis_1d.h"
#include "../inputs/guide_input_mouse_axis_2d.h"
#include "../inputs/guide_input_joy_button.h"
#include "../inputs/guide_input_joy_axis_1d.h"
#include "../inputs/guide_input_joy_axis_2d.h"

using namespace godot;

void GUIDEInputDetector::_bind_methods() {
    BIND_ENUM_CONSTANT(ANY);
    BIND_ENUM_CONSTANT(DETECTED);

    BIND_ENUM_CONSTANT(IDLE);
    BIND_ENUM_CONSTANT(COUNTDOWN);
    BIND_ENUM_CONSTANT(INPUT_PRE_CLEAR);
    BIND_ENUM_CONSTANT(DETECTING);
    BIND_ENUM_CONSTANT(INPUT_POST_CLEAR);

    ClassDB::bind_method(D_METHOD("get_detection_countdown_seconds"), &GUIDEInputDetector::get_detection_countdown_seconds);
    ClassDB::bind_method(D_METHOD("set_detection_countdown_seconds", "val"), &GUIDEInputDetector::set_detection_countdown_seconds);
    ADD_PROPERTY(PropertyInfo(Variant::FLOAT, "detection_countdown_seconds"), "set_detection_countdown_seconds", "get_detection_countdown_seconds");

    ClassDB::bind_method(D_METHOD("get_minimum_axis_amplitude"), &GUIDEInputDetector::get_minimum_axis_amplitude);
    ClassDB::bind_method(D_METHOD("set_minimum_axis_amplitude", "val"), &GUIDEInputDetector::set_minimum_axis_amplitude);
    ADD_PROPERTY(PropertyInfo(Variant::FLOAT, "minimum_axis_amplitude"), "set_minimum_axis_amplitude", "get_minimum_axis_amplitude");

    ClassDB::bind_method(D_METHOD("get_abort_detection_on"), &GUIDEInputDetector::get_abort_detection_on);
    ClassDB::bind_method(D_METHOD("set_abort_detection_on", "val"), &GUIDEInputDetector::set_abort_detection_on);
    ADD_PROPERTY(PropertyInfo(Variant::ARRAY, "abort_detection_on", PROPERTY_HINT_NONE, "24/17:GUIDEInput", PROPERTY_USAGE_DEFAULT, "GUIDEInput"), "set_abort_detection_on", "get_abort_detection_on");

    ClassDB::bind_method(D_METHOD("get_use_joy_index"), &GUIDEInputDetector::get_use_joy_index);
    ClassDB::bind_method(D_METHOD("set_use_joy_index", "val"), &GUIDEInputDetector::set_use_joy_index);
    ADD_PROPERTY(PropertyInfo(Variant::INT, "use_joy_index", PROPERTY_HINT_ENUM, "ANY,DETECTED"), "set_use_joy_index", "get_use_joy_index");

    ClassDB::bind_method(D_METHOD("get_allow_triggers_for_boolean_actions"), &GUIDEInputDetector::get_allow_triggers_for_boolean_actions);
    ClassDB::bind_method(D_METHOD("set_allow_triggers_for_boolean_actions", "val"), &GUIDEInputDetector::set_allow_triggers_for_boolean_actions);
    ADD_PROPERTY(PropertyInfo(Variant::BOOL, "allow_triggers_for_boolean_actions"), "set_allow_triggers_for_boolean_actions", "get_allow_triggers_for_boolean_actions");

    ClassDB::bind_method(D_METHOD("detect_bool", "device_types"), &GUIDEInputDetector::detect_bool, DEFVAL(TypedArray<int>()));
    ClassDB::bind_method(D_METHOD("detect_axis_1d", "device_types"), &GUIDEInputDetector::detect_axis_1d, DEFVAL(TypedArray<int>()));
    ClassDB::bind_method(D_METHOD("detect_axis_2d", "device_types"), &GUIDEInputDetector::detect_axis_2d, DEFVAL(TypedArray<int>()));
    ClassDB::bind_method(D_METHOD("detect_axis_3d", "device_types"), &GUIDEInputDetector::detect_axis_3d, DEFVAL(TypedArray<int>()));
    ClassDB::bind_method(D_METHOD("detect", "value_type", "device_types"), &GUIDEInputDetector::detect, DEFVAL(TypedArray<int>()));
    ClassDB::bind_method(D_METHOD("abort_detection"), &GUIDEInputDetector::abort_detection);
    ClassDB::bind_method(D_METHOD("_begin_detection"), &GUIDEInputDetector::_begin_detection);

    ADD_SIGNAL(MethodInfo("detection_started"));
    ADD_SIGNAL(MethodInfo("input_detected", PropertyInfo(Variant::OBJECT, "input", PROPERTY_HINT_RESOURCE_TYPE, "GUIDEInput")));
}

GUIDEInputDetector::GUIDEInputDetector() {}
GUIDEInputDetector::~GUIDEInputDetector() {}

void GUIDEInputDetector::_ready() {
    set_process(false);
    _timer = memnew(Timer);
    _timer->set_one_shot(true);
    add_child(_timer);
    _timer->connect("timeout", Callable(this, "_begin_detection"));
}

void GUIDEInputDetector::detect_bool(const TypedArray<int> &device_types) {
    detect(GUIDEAction::GUIDEActionValueType::BOOL, device_types);
}

void GUIDEInputDetector::detect_axis_1d(const TypedArray<int> &device_types) {
    detect(GUIDEAction::GUIDEActionValueType::AXIS_1D, device_types);
}

void GUIDEInputDetector::detect_axis_2d(const TypedArray<int> &device_types) {
    detect(GUIDEAction::GUIDEActionValueType::AXIS_2D, device_types);
}

void GUIDEInputDetector::detect_axis_3d(const TypedArray<int> &device_types) {
    detect(GUIDEAction::GUIDEActionValueType::AXIS_3D, device_types);
}

void GUIDEInputDetector::detect(GUIDEAction::GUIDEActionValueType value_type, const TypedArray<int> &device_types) {
    // if (device_types == TypedArray<int>()) {
    //     UtilityFunctions::push_error("Device types must not be null. Supply an empty array if you want to detect input from all devices.");
    //     return;
    // }
    if (device_types.has(GUIDEInput::TOUCH)) {
        UtilityFunctions::push_error("Detecting touch events is not supported.");
    }

    if (_status == INPUT_PRE_CLEAR || _status == INPUT_POST_CLEAR || _status == DETECTING) {
        for (int i = 0; i < abort_detection_on.size(); i++) {
            Ref<GUIDEInput> input = abort_detection_on[i];
            input->_end_usage();
        }
    }

    _status = COUNTDOWN;
    _value_type = value_type;
    _device_types = device_types;
    _timer->stop();

    if (detection_countdown_seconds > 0) {
        _timer->start(detection_countdown_seconds);
    } else {
        call_deferred("_begin_detection");
    }
}

void GUIDEInputDetector::_begin_detection() {
    _status = INPUT_PRE_CLEAR;
    for (int i = 0; i < abort_detection_on.size(); i++) {
        Ref<GUIDEInput> in = abort_detection_on[i];
        in->set_state(GUIDECpp::get_singleton()->get_input_state());
        in->_begin_usage();
    }

    if (!Engine::get_singleton()->is_editor_hint()) {
        _saved_mapping_contexts = GUIDECpp::get_singleton()->get_enabled_mapping_contexts();
        for (int i = 0; i < _saved_mapping_contexts.size(); i++) {
            GUIDECpp::get_singleton()->disable_mapping_context(_saved_mapping_contexts[i]);
        }
    }
    set_process(true);
}

void GUIDEInputDetector::abort_detection() {
    _timer->stop();
    if (_status == DETECTING) {
        _deliver(Ref<GUIDEInput>());
    }
}

void GUIDEInputDetector::_process(double delta) {
    if (_status != INPUT_PRE_CLEAR && _status != INPUT_POST_CLEAR) {
        set_process(false);
        return;
    }

    for (int i = 0; i < abort_detection_on.size(); i++) {
        Ref<GUIDEInput> in = abort_detection_on[i];
        if (in->get_value().is_finite() && in->get_value().length() > 0) return;
    }

    if (_status == INPUT_PRE_CLEAR) {
        _status = DETECTING;
        set_process(false);
        emit_signal("detection_started");
        return;
    }

    for (int i = 0; i < abort_detection_on.size(); i++) {
        ((Ref<GUIDEInput>)abort_detection_on[i])->_end_usage();
    }

    if (!Engine::get_singleton()->is_editor_hint()) {
        for (int i = 0; i < _saved_mapping_contexts.size(); i++) {
            GUIDECpp::get_singleton()->enable_mapping_context(_saved_mapping_contexts[i]);
        }
    }

    _status = IDLE;
    emit_signal("input_detected", _last_detected_input);
}

void GUIDEInputDetector::_input(const Ref<InputEvent> &event) {
    if (_status == IDLE) return;

    get_viewport()->set_input_as_handled();
    if (!Engine::get_singleton()->is_editor_hint()) {
        GUIDECpp::get_singleton()->inject_input(event);
    }

    if (_status == DETECTING) {
        for (int i = 0; i < abort_detection_on.size(); i++) {
            Ref<GUIDEInput> in = abort_detection_on[i];
            if (in->get_value().is_finite() && in->get_value().length() > 0) {
                abort_detection();
                return;
            }
        }

        if (!_matches_device_types(event)) return;

        switch (_value_type) {
            case GUIDEAction::GUIDEActionValueType::BOOL: _try_detect_bool(event); break;
            case GUIDEAction::GUIDEActionValueType::AXIS_1D: _try_detect_axis_1d(event); break;
            case GUIDEAction::GUIDEActionValueType::AXIS_2D: _try_detect_axis_2d(event); break;
            case GUIDEAction::GUIDEActionValueType::AXIS_3D: _try_detect_axis_3d(event); break;
        }
    }
}

bool GUIDEInputDetector::_matches_device_types(const Ref<InputEvent> &event) const {
    if (_device_types.is_empty()) return true;
    if (Object::cast_to<InputEventKey>(event.ptr())) return _device_types.has(GUIDEInput::KEYBOARD);
    if (Object::cast_to<InputEventMouse>(event.ptr())) return _device_types.has(GUIDEInput::MOUSE);
    if (Object::cast_to<InputEventJoypadButton>(event.ptr()) || Object::cast_to<InputEventJoypadMotion>(event.ptr())) return _device_types.has(GUIDEInput::JOY);
    return false;
}

void GUIDEInputDetector::_try_detect_bool(const Ref<InputEvent> &event) {
    Ref<InputEventKey> k = event;
    if (k.is_valid() && !k->is_pressed()) {
        Ref<GUIDEInputKey> res; res.instantiate();
        res->set_key(k->get_physical_keycode());
        res->set_shift(k->is_shift_pressed());
        res->set_control(k->is_ctrl_pressed());
        res->set_meta(k->is_meta_pressed());
        res->set_alt(k->is_alt_pressed());
        _deliver(res);
        return;
    }

    Ref<InputEventMouseButton> mb = event;
    if (mb.is_valid() && !mb->is_pressed()) {
        Ref<GUIDEInputMouseButton> res; res.instantiate();
        res->set_button(mb->get_button_index());
        _deliver(res);
        return;
    }

    Ref<InputEventJoypadButton> jb = event;
    if (jb.is_valid() && !jb->is_pressed()) {
        Ref<GUIDEInputJoyButton> res; res.instantiate();
        res->set_button(jb->get_button_index());
        res->set_joy_index(_find_joy_index(jb->get_device()));
        _deliver(res);
        return;
    }

    if (allow_triggers_for_boolean_actions) {
        Ref<InputEventJoypadMotion> jm = event;
        if (jm.is_valid() && (jm->get_axis() == JOY_AXIS_TRIGGER_LEFT || jm->get_axis() == JOY_AXIS_TRIGGER_RIGHT)) {
            Ref<GUIDEInputJoyAxis1D> res; res.instantiate();
            res->set_axis(jm->get_axis());
            res->set_joy_index(_find_joy_index(jm->get_device()));
            _deliver(res);
        }
    }
}

void GUIDEInputDetector::_try_detect_axis_1d(const Ref<InputEvent> &event) {
    Ref<InputEventMouseMotion> mm = event;
    if (mm.is_valid() && mm->get_relative().length_squared() > 0) {
        Ref<GUIDEInputMouseAxis1D> res; res.instantiate();
        if (Math::abs(mm->get_relative().x) > Math::abs(mm->get_relative().y)) res->set_axis(GUIDEInputMouseAxis1D::AXIS_X);
        else res->set_axis(GUIDEInputMouseAxis1D::AXIS_Y);
        _deliver(res);
        return;
    }

    Ref<InputEventJoypadMotion> jm = event;
    if (jm.is_valid() && Math::abs(jm->get_axis_value()) >= minimum_axis_amplitude) {
        Ref<GUIDEInputJoyAxis1D> res; res.instantiate();
        res->set_axis(jm->get_axis());
        res->set_joy_index(_find_joy_index(jm->get_device()));
        _deliver(res);
    }
}

void GUIDEInputDetector::_try_detect_axis_2d(const Ref<InputEvent> &event) {
    if (event->is_class("InputEventMouseMotion")) {
        Ref<GUIDEInputMouseAxis2D> res; res.instantiate();
        _deliver(res);
        return;
    }

    Ref<InputEventJoypadMotion> jm = event;
    if (jm.is_valid() && Math::abs(jm->get_axis_value()) >= minimum_axis_amplitude) {
        Ref<GUIDEInputJoyAxis2D> res; res.instantiate();
        switch (jm->get_axis()) {
            case JOY_AXIS_LEFT_X:
            case JOY_AXIS_LEFT_Y:
                res->set_x_axis(JOY_AXIS_LEFT_X);
                res->set_y_axis(JOY_AXIS_LEFT_Y);
                break;
            case JOY_AXIS_RIGHT_X:
            case JOY_AXIS_RIGHT_Y:
                res->set_x_axis(JOY_AXIS_RIGHT_X);
                res->set_y_axis(JOY_AXIS_RIGHT_Y);
                break;
            default:
                return;
        }
        res->set_joy_index(_find_joy_index(jm->get_device()));
        _deliver(res);
    }
}

void GUIDEInputDetector::_try_detect_axis_3d(const Ref<InputEvent> &event) {
    // Placeholder implementation for 3D axis detection
    // This would handle 3D joystick movements or similar inputs
    // For now, we just return without doing anything
    return;
}

int GUIDEInputDetector::_find_joy_index(int device_id) const {
    if (use_joy_index == ANY) return -1;
    Array pads = Input::get_singleton()->get_connected_joypads();
    for (int i = 0; i < pads.size(); i++) {
        if ((int)pads[i] == device_id) return i;
    }
    return -1;
}

void GUIDEInputDetector::_deliver(const Ref<GUIDEInput> &input) {
    _last_detected_input = input;
    _status = INPUT_POST_CLEAR;
    set_process(true);
}
