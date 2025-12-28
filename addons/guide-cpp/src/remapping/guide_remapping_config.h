#ifndef GUIDE_REMAPPING_CONFIG_H
#define GUIDE_REMAPPING_CONFIG_H

#include <godot_cpp/classes/resource.hpp>
#include <godot_cpp/variant/dictionary.hpp>
#include <godot_cpp/core/class_db.hpp>
#include "guide_mapping_context.h"
#include "guide_action.h"
#include "inputs/guide_input.h"

using namespace godot;

class GUIDERemappingConfig : public Resource {
    GDCLASS(GUIDERemappingConfig, Resource)

public:
    GUIDERemappingConfig();
    virtual ~GUIDERemappingConfig();

    Dictionary custom_data;
    Dictionary remapped_inputs;

    void _bind(const Ref<GUIDEMappingContext> &mapping_context, const Ref<GUIDEAction> &action, const Ref<GUIDEInput> &input, int index = 0);
    void _unbind(const Ref<GUIDEMappingContext> &mapping_context, const Ref<GUIDEAction> &action, int index = 0);
    void _clear(const Ref<GUIDEMappingContext> &mapping_context, const Ref<GUIDEAction> &action, int index = 0);
    Ref<GUIDEInput> _get_bound_input_or_null(const Ref<GUIDEMappingContext> &mapping_context, const Ref<GUIDEAction> &action, int index = 0) const;
    bool _has(const Ref<GUIDEMappingContext> &mapping_context, const Ref<GUIDEAction> &action, int index = 0) const;

    Dictionary get_remapped_inputs() const { return remapped_inputs; }
    void set_remapped_inputs(const Dictionary &p_inputs) { remapped_inputs = p_inputs; emit_changed(); }

    Dictionary get_custom_data() const { return custom_data; }
    void set_custom_data(const Dictionary &p_data) { custom_data = p_data; emit_changed(); }

protected:
    static void _bind_methods();

};

#endif // GUIDE_REMAPPING_CONFIG_H