#ifndef GUIDE_REMAPPER_H
#define GUIDE_REMAPPER_H

#include <godot_cpp/core/class_db.hpp>
#include <godot_cpp/classes/ref_counted.hpp>
#include <godot_cpp/variant/typed_array.hpp>
#include "../guide_mapping_context.h"
#include "../guide_action.h"
#include "../guide_input_mapping.h"
#include "guide_remapping_config.h"

using namespace godot;

// Forward declaration
class GUIDERemapperConfigItem;

class GUIDERemapper : public RefCounted {
    GDCLASS(GUIDERemapper, RefCounted)

public:
    GUIDERemapper();
    virtual ~GUIDERemapper();

    void initialize(const TypedArray<GUIDEMappingContext> &mapping_contexts, const Ref<GUIDERemappingConfig> &remapping_config);
    Ref<GUIDERemappingConfig> get_mapping_config() const;

    void set_custom_data(const Variant &key, const Variant &value);
    Variant get_custom_data(const Variant &key, const Variant &default_val = Variant()) const;
    void remove_custom_data(const Variant &key);

    TypedArray<GUIDERemapperConfigItem> get_remappable_items(const Ref<GUIDEMappingContext> &context = Ref<GUIDEMappingContext>(), const String &display_category = "", const Ref<GUIDEAction> &action = Ref<GUIDEAction>());
    
    static String _get_effective_display_category(const Ref<GUIDEAction> &action, const Ref<GUIDEInputMapping> &input_mapping);
    static String _get_effective_display_name(const Ref<GUIDEAction> &action, const Ref<GUIDEInputMapping> &input_mapping);
    static bool _is_effectively_remappable(const Ref<GUIDEAction> &action, const Ref<GUIDEInputMapping> &input_mapping);
    static GUIDEAction::GUIDEActionValueType _get_effective_value_type(const Ref<GUIDEAction> &action, const Ref<GUIDEInputMapping> &input_mapping);

    TypedArray<GUIDERemapperConfigItem> get_input_collisions(const Ref<GUIDERemapperConfigItem> &item, const Ref<GUIDEInput> &input);
    Ref<GUIDEInput> get_bound_input_or_null(const Ref<GUIDERemapperConfigItem> &item) const;
    void set_bound_input(const Ref<GUIDERemapperConfigItem> &item, const Ref<GUIDEInput> &input);
    Ref<GUIDEInput> get_default_input(const Ref<GUIDERemapperConfigItem> &item) const;
    void restore_default_for(const Ref<GUIDERemapperConfigItem> &item);

protected:
    static void _bind_methods();

private:
    Ref<GUIDERemappingConfig> _remapping_config;
    TypedArray<GUIDEMappingContext> _mapping_contexts;

    bool _check_item(const Ref<GUIDERemapperConfigItem> &item) const;
};

#endif // GUIDE_REMAPPER_H
