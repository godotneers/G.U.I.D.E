#ifndef GUIDE_REMAPPER_H
#define GUIDE_REMAPPER_H

#include <godot_cpp/core/class_db.hpp>
#include <godot_cpp/variant/typed_array.hpp>
#include "guide_mapping_context.h"
#include "remapping/guide_remapping_config.h"

using namespace godot;

class GUIDERemapperConfigItem : public Object {
    GDCLASS(GUIDERemapperConfigItem, Object)
public:
    GUIDERemapperConfigItem() {}
    GUIDERemapperConfigItem(const Ref<GUIDEMappingContext> &ctx, const Ref<GUIDEAction> &act, int idx, const Ref<GUIDEInputMapping> &im)
        : context(ctx), action(act), index(idx), input_mapping(im) {}

    Ref<GUIDEMappingContext> context;
    Ref<GUIDEAction> action;
    int index;
    Ref<GUIDEInputMapping> input_mapping;

    String get_display_category() const;
    String get_display_name() const;
    bool is_effectively_remappable() const;
    int get_effective_value_type() const;

    bool is_same_as(const Ref<GUIDERemapperConfigItem> &other) const;
    void _item_changed(const Ref<GUIDERemapperConfigItem> &item, const Ref<GUIDEInput> &input);

protected:
    static void _bind_methods();
};

class GUIDERemapper : public Object {
    GDCLASS(GUIDERemapper, Object)

public:
    GUIDERemapper();
    virtual ~GUIDERemapper();

    void initialize(const TypedArray<GUIDEMappingContext> &mapping_contexts, const Ref<GUIDERemappingConfig> &remapping_config);
    Ref<GUIDERemappingConfig> get_mapping_config() const;

    void set_custom_data(const Variant &key, const Variant &value);
    Variant get_custom_data(const Variant &key, const Variant &default_val = Variant()) const;
    void remove_custom_data(const Variant &key);

    TypedArray<GUIDERemapperConfigItem> get_remappable_items(const Ref<GUIDEMappingContext> &context = Ref<GUIDEMappingContext>(), const String &display_category = "", const Ref<GUIDEAction> &action = Ref<GUIDEAction>()) const;
    TypedArray<GUIDERemapperConfigItem> get_input_collisions(const Ref<GUIDERemapperConfigItem> &item, const Ref<GUIDEInput> &input) const;
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