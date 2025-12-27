#ifndef GUIDE_MAPPING_CONTEXT_H
#define GUIDE_MAPPING_CONTEXT_H

#include <godot_cpp/classes/resource.hpp>
#include <godot_cpp/core/class_db.hpp>
#include "guide_action_mapping.h"

using namespace godot;

class GUIDEMappingContext : public Resource {
    GDCLASS(GUIDEMappingContext, Resource)

public:
    GUIDEMappingContext();
    virtual ~GUIDEMappingContext();

    String get_display_name() const { return display_name; }
    void set_display_name(const String &p_name) { display_name = p_name; emit_changed(); }

    TypedArray<GUIDEActionMapping> get_mappings() const { return mappings; }
    void set_mappings(const TypedArray<GUIDEActionMapping> &p_mappings) { mappings = p_mappings; emit_changed(); }

    String _editor_name() const;

protected:
    static void _bind_methods();

    String display_name;
    TypedArray<GUIDEActionMapping> mappings;
};

#endif // GUIDE_MAPPING_CONTEXT_H