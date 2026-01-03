#ifndef GUIDE_INPUT_TRACKER_H
#define GUIDE_INPUT_TRACKER_H

#include <godot_cpp/classes/node.hpp>
#include <godot_cpp/classes/viewport.hpp>
#include <godot_cpp/classes/control.hpp>
#include <godot_cpp/core/class_db.hpp>

using namespace godot;

class GUIDEInputTracker : public Node {
    GDCLASS(GUIDEInputTracker, Node)

public:
    GUIDEInputTracker();
    virtual ~GUIDEInputTracker();

    static void _instrument(Viewport *viewport);
    void _unhandled_input(const Ref<InputEvent> &event) override;
    void _control_focused(Control *control);

protected:
    static void _bind_methods();
};

#endif // GUIDE_INPUT_TRACKER_H