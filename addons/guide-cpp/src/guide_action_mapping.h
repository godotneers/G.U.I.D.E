#ifndef GUIDE_ACTION_MAPPING_H
#define GUIDE_ACTION_MAPPING_H

#include <godot_cpp/classes/resource.hpp>
#include <godot_cpp/core/class_db.hpp>
#include "guide_action.h"
#include "guide_input_mapping.h"

using namespace godot;

class GUIDEActionMapping : public Resource {
    GDCLASS(GUIDEActionMapping, Resource)

public:
    GUIDEActionMapping();
    virtual ~GUIDEActionMapping();

    Ref<GUIDEAction> get_action() const { return action; }
    void set_action(const Ref<GUIDEAction> &p_action) { action = p_action; emit_changed(); }

    TypedArray<GUIDEInputMapping> get_input_mappings() const { return input_mappings; }
    void set_input_mappings(const TypedArray<GUIDEInputMapping> &p_mappings) { input_mappings = p_mappings; emit_changed(); }

protected:
    static void _bind_methods();

    Ref<GUIDEAction> action;
    TypedArray<GUIDEInputMapping> input_mappings;
};

#endif // GUIDE_ACTION_MAPPING_H