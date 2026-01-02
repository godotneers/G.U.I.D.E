#include "guide_input_tracker.h"
#include "guide.h"
#include <godot_cpp/classes/option_button.hpp>
#include <godot_cpp/classes/color_picker_button.hpp>
#include <godot_cpp/classes/menu_button.hpp>
#include <godot_cpp/classes/tab_container.hpp>
#include <godot_cpp/classes/popup.hpp>
#include <godot_cpp/classes/popup_menu.hpp>
#include <godot_cpp/classes/popup_panel.hpp>

using namespace godot;

void GUIDEInputTracker::_bind_methods() {
    ClassDB::bind_method(D_METHOD("_control_focused", "control"), &GUIDEInputTracker::_control_focused);
}

GUIDEInputTracker::GUIDEInputTracker() {}
GUIDEInputTracker::~GUIDEInputTracker() {}

void GUIDEInputTracker::_instrument(Viewport *viewport) {
    if (viewport->has_meta("x-guide-instrumented")) return;
    viewport->set_meta("x-guide-instrumented", true);

    GUIDEInputTracker *tracker = memnew(GUIDEInputTracker);
    tracker->set_process_mode(PROCESS_MODE_ALWAYS);
    viewport->add_child(tracker, false, INTERNAL_MODE_BACK);
    viewport->connect("gui_focus_changed", Callable(tracker, "_control_focused"));
}

void GUIDEInputTracker::_unhandled_input(const Ref<InputEvent> &event) {
    GUIDECpp::get_singleton()->inject_input(event);
}

void GUIDEInputTracker::_control_focused(Control *control) {
    if (Object::cast_to<OptionButton>(control) || Object::cast_to<ColorPickerButton>(control) ||
        Object::cast_to<MenuButton>(control) || Object::cast_to<TabContainer>(control)) {
        
        // This is a bit tricky in C++ because we need to get the popup and it might not be a Viewport directly
        // but popups are Viewports in Godot 4.
        Window *popup = nullptr;
        if (auto ob = Object::cast_to<OptionButton>(control)) popup = ob->get_popup();
        else if (auto mb = Object::cast_to<MenuButton>(control)) popup = mb->get_popup();
        else if (auto cpb = Object::cast_to<ColorPickerButton>(control)) popup = cpb->get_popup();
        else if (auto tc = Object::cast_to<TabContainer>(control)) popup = tc->get_popup();
        
        if (popup) _instrument(popup);
    }
}