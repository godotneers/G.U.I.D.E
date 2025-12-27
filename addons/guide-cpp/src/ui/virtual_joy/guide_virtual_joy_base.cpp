#include "guide_virtual_joy_base.h"
#include "../../guide.h"

using namespace godot;

void GUIDEVirtualJoyBase::_bind_methods() {
    BIND_ENUM_CONSTANT(MODE_TOUCH);
    BIND_ENUM_CONSTANT(MODE_MOUSE);
    BIND_ENUM_CONSTANT(MODE_MOUSE_AND_TOUCH);

    ADD_SIGNAL(MethodInfo("changed"));
    ADD_SIGNAL(MethodInfo("configuration_changed"));
}

GUIDEVirtualJoyBase::GUIDEVirtualJoyBase() {
}

GUIDEVirtualJoyBase::~GUIDEVirtualJoyBase() {
}

void GUIDEVirtualJoyBase::_input(const Ref<InputEvent> &event) {
    Ref<InputEventMouse> mouse_event = event;
    if (mouse_event.is_valid()) {
        if (input_mode == MODE_MOUSE || input_mode == MODE_MOUSE_AND_TOUCH) {
            _handle_mouse_input(mouse_event);
        }
    }

    if (event->is_class("InputEventScreenTouch") || event->is_class("InputEventScreenDrag")) {
        if (input_mode == MODE_TOUCH || input_mode == MODE_MOUSE_AND_TOUCH) {
            _handle_touch_input(event);
        }
    }
}

void GUIDEVirtualJoyBase::_handle_mouse_input(const Ref<InputEventMouse> &event) {
}

void GUIDEVirtualJoyBase::_handle_touch_input(const Ref<InputEvent> &event) {
}

Vector2 GUIDEVirtualJoyBase::_screen_to_world(Vector2 input) const {
    return get_canvas_transform().affine_inverse() * input;
}

void GUIDEVirtualJoyBase::_reconnect() {
    if (!is_node_ready()) return;
    if (_virtual_joy_id != 0) {
        GUIDE::get_singleton()->get_input_state()->disconnect_virtual_stick(_virtual_joy_id);
    }
    _virtual_joy_id = GUIDE::get_singleton()->get_input_state()->connect_virtual_stick(virtual_device);
}