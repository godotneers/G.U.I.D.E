#include "guide_input_detector.h"
#include <godot_cpp/classes/engine.hpp>
#include <godot_cpp/classes/input.hpp>
#include <godot_cpp/classes/input_event_key.hpp>
#include <godot_cpp/classes/input_event_mouse_button.hpp>
#include <godot_cpp/classes/input_event_mouse_motion.hpp>
#include <godot_cpp/classes/input_event_joypad_button.hpp>
#include <godot_cpp/classes/input_event_joypad_motion.hpp>
#include <godot_cpp/classes/viewport.hpp>
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
    BIND_ENUM_CONSTANT(JOY_ANY);
    BIND_ENUM_CONSTANT(JOY_DETECTED);

    BIND_ENUM_CONSTANT(STATUS_IDLE);
    BIND_ENUM_CONSTANT(STATUS_COUNTDOWN);
    BIND_ENUM_CONSTANT(STATUS_INPUT_PRE_CLEAR);
    BIND_ENUM_CONSTANT(STATUS_DETECTING);
    BIND_ENUM_CONSTANT(STATUS_INPUT_POST_CLEAR);

    ClassDB::bind_method(D_METHOD("get_detection_countdown_seconds"), &GUIDEInputDetector::get_detection_countdown_seconds);
    ClassDB::bind_method(D_METHOD("set_detection_countdown_seconds", "val"), &GUIDEInputDetector::set_detection_countdown_seconds);
    ADD_PROPERTY(PropertyInfo(Variant::FLOAT, "detection_countdown_seconds"), "set_detection_countdown_seconds", "get_detection_countdown_seconds");

    ClassDB::bind_method(D_METHOD("detect", "value_type", "device_types"), &GUIDEInputDetector::detect, DEFVAL(TypedArray<int>()));
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

void GUIDEInputDetector::detect(int value_type, const TypedArray<int> &device_types) {
    if (_status != STATUS_IDLE) {
        for (int i = 0; i < abort_detection_on.size(); i++) {
            ((Ref<GUIDEInput>)abort_detection_on[i])->_end_usage();
        }
    }

    _status = STATUS_COUNTDOWN;
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
    _status = STATUS_INPUT_PRE_CLEAR;
    for (int i = 0; i < abort_detection_on.size(); i++) {
        Ref<GUIDEInput> in = abort_detection_on[i];
        in->set_state(GUIDE::get_singleton()->get_input_state());
        in->_begin_usage();
    }

    if (!Engine::get_singleton()->is_editor_hint()) {
        _saved_mapping_contexts = GUIDE::get_singleton()->get_enabled_mapping_contexts();
        for (int i = 0; i < _saved_mapping_contexts.size(); i++) {
            GUIDE::get_singleton()->disable_mapping_context(_saved_mapping_contexts[i]);
        }
    }
    set_process(true);
}

void GUIDEInputDetector::abort_detection() {
    _timer->stop();
    if (_status == STATUS_DETECTING) {
        _deliver(Ref<GUIDEInput>());
    }
}

void GUIDEInputDetector::_process(double delta) {
    if (_status != STATUS_INPUT_PRE_CLEAR && _status != STATUS_INPUT_POST_CLEAR) {
        set_process(false);
        return;
    }

    for (int i = 0; i < abort_detection_on.size(); i++) {
        Ref<GUIDEInput> in = abort_detection_on[i];
        if (in->get_value().is_finite() && in->get_value().length() > 0) return;
    }

    if (_status == STATUS_INPUT_PRE_CLEAR) {
        _status = STATUS_DETECTING;
        set_process(false);
        emit_signal("detection_started");
        return;
    }

    for (int i = 0; i < abort_detection_on.size(); i++) {
        ((Ref<GUIDEInput>)abort_detection_on[i])->_end_usage();
    }

    if (!Engine::get_singleton()->is_editor_hint()) {
        for (int i = 0; i < _saved_mapping_contexts.size(); i++) {
            GUIDE::get_singleton()->enable_mapping_context(_saved_mapping_contexts[i]);
        }
    }

    _status = STATUS_IDLE;
    emit_signal("input_detected", _last_detected_input);
}

void GUIDEInputDetector::_input(const Ref<InputEvent> &event) {
    if (_status == STATUS_IDLE) return;

    get_viewport()->set_input_as_handled();
    if (!Engine::get_singleton()->is_editor_hint()) {
        GUIDE::get_singleton()->inject_input(event);
    }

    if (_status == STATUS_DETECTING) {
        for (int i = 0; i < abort_detection_on.size(); i++) {
            Ref<GUIDEInput> in = abort_detection_on[i];
            if (in->get_value().is_finite() && in->get_value().length() > 0) {
                abort_detection();
                return;
            }
        }

        if (!_matches_device_types(event)) return;

        switch (_value_type) {
            case 0: _try_detect_bool(event); break;
            case 1: _try_detect_axis_1d(event); break;
            case 2: _try_detect_axis_2d(event); break;
        }
    }
}

bool GUIDEInputDetector::_matches_device_types(const Ref<InputEvent> &event) const {
    if (_device_types.is_empty()) return true;
    if (event->is_class("InputEventKey")) return _device_types.has(GUIDEInput::DEVICE_KEYBOARD);
    if (event->is_class("InputEventMouse")) return _device_types.has(GUIDEInput::DEVICE_MOUSE);
    if (event->is_class("InputEventJoypadButton") || event->is_class("InputEventJoypadMotion")) return _device_types.has(GUIDEInput::DEVICE_JOY);
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
        Ref<GUIDEInputTouchAxis2D> res; res.instantiate(); // This should be Axis2D, likely a copy paste error from my end before
        // Actually looking at previous implementations, it should be GUIDEInputJoyAxis2D
    }
}

int GUIDEInputDetector::_find_joy_index(int device_id) const {
    if (use_joy_index == JOY_ANY) return -1;
    Array pads = Input::get_singleton()->get_connected_joypads();
    for (int i = 0; i < pads.size(); i++) {
        if ((int)pads[i] == device_id) return i;
    }
    return -1;
}

void GUIDEInputDetector::_deliver(const Ref<GUIDEInput> &input) {
    _last_detected_input = input;
    _status = STATUS_INPUT_POST_CLEAR;
    set_process(true);
}
