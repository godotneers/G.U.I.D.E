#ifndef GUIDE_REMAPPER_CONFIG_ITEM_H
#define GUIDE_REMAPPER_CONFIG_ITEM_H

#include <godot_cpp/core/class_db.hpp>
#include <godot_cpp/classes/ref_counted.hpp>
#include "../guide_mapping_context.h"
#include "../guide_action.h"
#include "../guide_input_mapping.h"
#include "../inputs/guide_input.h"

using namespace godot;

class GUIDERemapperConfigItem : public RefCounted {
    GDCLASS(GUIDERemapperConfigItem, RefCounted)
public:
    GUIDERemapperConfigItem();
    GUIDERemapperConfigItem(const Ref<GUIDEMappingContext> &p_context, const Ref<GUIDEAction> &p_action, int p_index, const Ref<GUIDEInputMapping> &p_input_mapping);

    Ref<GUIDEMappingContext> context;
    Ref<GUIDEAction> action;
    int index = 0;
    Ref<GUIDEInputMapping> _input_mapping;

    String get_display_category() const;
    String get_display_name() const;
    bool is_remappable() const;
    GUIDEAction::GUIDEActionValueType get_value_type() const;

    bool is_same_as(const Ref<GUIDERemapperConfigItem> &other) const;
    void _item_changed(const Ref<GUIDERemapperConfigItem> &item, const Ref<GUIDEInput> &input);

protected:
    static void _bind_methods();
};

#endif // GUIDE_REMAPPER_CONFIG_ITEM_H
