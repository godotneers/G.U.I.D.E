#ifndef GUIDE_RESET_H
#define GUIDE_RESET_H

#include <godot_cpp/classes/node.hpp>
#include "inputs/guide_input.h"

using namespace godot;

class GUIDEReset : public Node {
    GDCLASS(GUIDEReset, Node)

public:
    GUIDEReset();
    virtual ~GUIDEReset();

    void _notification(int p_what);
    void _process(double delta) override;

    TypedArray<GUIDEInput> _inputs_to_reset;

protected:
    static void _bind_methods();
};

#endif // GUIDE_RESET_H