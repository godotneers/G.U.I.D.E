#include "guide_remapper.h"
#include "guide_remapper_config_item.h"
#include <godot_cpp/variant/utility_functions.hpp>

using namespace godot;

void GUIDERemapper::_bind_methods() {
    ClassDB::bind_method(D_METHOD("initialize", "mapping_contexts", "remapping_config"), &GUIDERemapper::initialize);
    ClassDB::bind_method(D_METHOD("get_mapping_config"), &GUIDERemapper::get_mapping_config);
    ClassDB::bind_method(D_METHOD("set_custom_data", "key", "value"), &GUIDERemapper::set_custom_data);
    ClassDB::bind_method(D_METHOD("get_custom_data", "key", "default_val"), &GUIDERemapper::get_custom_data, DEFVAL(Variant()));
    ClassDB::bind_method(D_METHOD("remove_custom_data", "key"), &GUIDERemapper::remove_custom_data);
    ClassDB::bind_method(D_METHOD("get_remappable_items", "context", "display_category", "action"), &GUIDERemapper::get_remappable_items, DEFVAL(Ref<GUIDEMappingContext>()), DEFVAL(""), DEFVAL(Ref<GUIDEAction>()));
    ClassDB::bind_method(D_METHOD("get_input_collisions", "item", "input"), &GUIDERemapper::get_input_collisions);
    ClassDB::bind_method(D_METHOD("get_bound_input_or_null", "item"), &GUIDERemapper::get_bound_input_or_null);
    ClassDB::bind_method(D_METHOD("set_bound_input", "item", "input"), &GUIDERemapper::set_bound_input);
    ClassDB::bind_method(D_METHOD("get_default_input", "item"), &GUIDERemapper::get_default_input);
    ClassDB::bind_method(D_METHOD("restore_default_for", "item"), &GUIDERemapper::restore_default_for);

    ADD_SIGNAL(MethodInfo("item_changed", PropertyInfo(Variant::OBJECT, "item", PROPERTY_HINT_RESOURCE_TYPE, "GUIDERemapperConfigItem"), PropertyInfo(Variant::OBJECT, "input", PROPERTY_HINT_RESOURCE_TYPE, "GUIDEInput")));
}

GUIDERemapper::GUIDERemapper() {
}

GUIDERemapper::~GUIDERemapper() {}

void GUIDERemapper::initialize(const TypedArray<GUIDEMappingContext> &mapping_contexts, const Ref<GUIDERemappingConfig> &remapping_config) {
    if (remapping_config.is_valid()) {
        _remapping_config = remapping_config->duplicate();
    } else {
        _remapping_config.instantiate();
    }

    _mapping_contexts.clear();
    for (int i = 0; i < mapping_contexts.size(); i++) {
        Ref<GUIDEMappingContext> mc = mapping_contexts[i];
        if (mc.is_null()) {
            UtilityFunctions::push_error("Cannot add null mapping context. Ignoring.");
            continue;
        }
        _mapping_contexts.append(mc);
    }
}

Ref<GUIDERemappingConfig> GUIDERemapper::get_mapping_config() const {
    if (_remapping_config.is_valid()) return _remapping_config->duplicate();
    return Ref<GUIDERemappingConfig>();
}

void GUIDERemapper::set_custom_data(const Variant &key, const Variant &value) {
    _remapping_config->custom_data.set(key, value);
}

Variant GUIDERemapper::get_custom_data(const Variant &key, const Variant &default_val) const {
    return _remapping_config->custom_data.get(key, default_val);
}

void GUIDERemapper::remove_custom_data(const Variant &key) {
    _remapping_config->custom_data.erase(key);
}

TypedArray<GUIDERemapperConfigItem> GUIDERemapper::get_remappable_items(
    const Ref<GUIDEMappingContext> &context, 
    const String &display_category, 
    const Ref<GUIDEAction> &action
) {

    if (action.is_valid() && !action->get_is_remappable()) {
        UtilityFunctions::push_warning("Action filter was set but filtered action is not remappable.");
        return TypedArray<GUIDERemapperConfigItem>();
    }

    TypedArray<GUIDERemapperConfigItem> result;
    for (int i = 0; i < _mapping_contexts.size(); i++) {
        Ref<GUIDEMappingContext> a_context = _mapping_contexts[i];
        if (context.is_valid() && context != a_context) continue;

        TypedArray<GUIDEActionMapping> mappings = a_context->get_mappings();
        for (int j = 0; j < mappings.size(); j++) {
            Ref<GUIDEActionMapping> action_mapping = mappings[j];
            Ref<GUIDEAction> mapped_action = action_mapping->get_action();
            if (mapped_action.is_null() || !mapped_action->get_is_remappable()) continue;
            if (action.is_valid() && action != mapped_action) continue;

            TypedArray<GUIDEInputMapping> input_mappings = action_mapping->get_input_mappings();
            for (int k = 0; k < input_mappings.size(); k++) {
                Ref<GUIDEInputMapping> input_mapping = input_mappings[k];
                if (input_mapping->get_override_action_settings() && !input_mapping->get_is_remappable()) continue;

                String effective_cat = _get_effective_display_category(mapped_action, input_mapping);
                if (!display_category.is_empty() && effective_cat != display_category) continue;

                Ref<GUIDERemapperConfigItem> item;
                item.instantiate();
                item->context = a_context;
                item->action = mapped_action;
                item->index = k;
                item->_input_mapping = input_mapping;
                
                connect("item_changed", Callable(item.ptr(), "_item_changed"));
                result.append(item);
            }
        }
    }
    return result;
}

String GUIDERemapper::_get_effective_display_category(const Ref<GUIDEAction> &action, const Ref<GUIDEInputMapping> &input_mapping) {
    if (action.is_null()) return "";
    if (input_mapping.is_valid() && input_mapping->get_override_action_settings() && !input_mapping->get_display_category().is_empty()) {
        return input_mapping->get_display_category();
    }
    return action->get_display_category();
}

String GUIDERemapper::_get_effective_display_name(const Ref<GUIDEAction> &action, const Ref<GUIDEInputMapping> &input_mapping) {
    if (action.is_null()) return "";
    if (input_mapping.is_valid() && input_mapping->get_override_action_settings() && !input_mapping->get_display_name().is_empty()) {
        return input_mapping->get_display_name();
    }
    return action->get_display_name();
}

bool GUIDERemapper::_is_effectively_remappable(const Ref<GUIDEAction> &action, const Ref<GUIDEInputMapping> &input_mapping) {
    if (action.is_null()) return false;
    if (input_mapping.is_valid()) {
        return action->get_is_remappable() && (!input_mapping->get_override_action_settings() || input_mapping->get_is_remappable());
    }
    return action->get_is_remappable();
}

GUIDEAction::GUIDEActionValueType GUIDERemapper::_get_effective_value_type(const Ref<GUIDEAction> &action, const Ref<GUIDEInputMapping> &input_mapping) {
    if (action.is_null()) return GUIDEAction::BOOL;
    
    if (input_mapping.is_valid() && input_mapping->get_override_action_settings() && input_mapping->get_input().is_valid()) {
        return (GUIDEAction::GUIDEActionValueType)input_mapping->get_input()->_native_value_type();
    }
    return action->get_action_value_type();
}

TypedArray<GUIDERemapperConfigItem> GUIDERemapper::get_input_collisions(
    const Ref<GUIDERemapperConfigItem> &item, 
    const Ref<GUIDEInput> &input
) {
    if (!_check_item(item)) return TypedArray<GUIDERemapperConfigItem>();
    if (input.is_null()) return TypedArray<GUIDERemapperConfigItem>();

    TypedArray<GUIDERemapperConfigItem> result;
    for (int i = 0; i < _mapping_contexts.size(); i++) {
        Ref<GUIDEMappingContext> context = _mapping_contexts[i];
        TypedArray<GUIDEActionMapping> mappings = context->get_mappings();
        for (int j = 0; j < mappings.size(); j++) {
            Ref<GUIDEActionMapping> action_mapping = mappings[j];
            Ref<GUIDEAction> action = action_mapping->get_action();
            TypedArray<GUIDEInputMapping> input_mappings = action_mapping->get_input_mappings();
            for (int k = 0; k < input_mappings.size(); k++) {
                if (context == item->context && action == item->action && k == item->index) continue;

                Ref<GUIDEInputMapping> input_mapping = input_mappings[k];
                Ref<GUIDEInput> bound_input = input_mapping->get_input();
                if (_remapping_config->_has(context, action, k)) {
                    bound_input = _remapping_config->_get_bound_input_or_null(context, action, k);
                }

                if (bound_input.is_valid() && bound_input->is_same_as(input)) {
                    Ref<GUIDERemapperConfigItem> collision;
                    collision.instantiate();
                    collision->context = context;
                    collision->action = action;
                    collision->index = k;
                    collision->_input_mapping = input_mapping;
                    connect("item_changed", Callable(collision.ptr(), "_item_changed"));
                    result.append(collision);
                }
            }
        }
    }
    return result;
}

Ref<GUIDEInput> GUIDERemapper::get_bound_input_or_null(const Ref<GUIDERemapperConfigItem> &item) const {
    if (!_check_item(item)) return Ref<GUIDEInput>();

    if (_remapping_config->_has(item->context, item->action, item->index)) {
        return _remapping_config->_get_bound_input_or_null(item->context, item->action, item->index);
    }

    TypedArray<GUIDEActionMapping> mappings = item->context->get_mappings();
    for (int i = 0; i < mappings.size(); i++) {
        Ref<GUIDEActionMapping> am = mappings[i];
        if (am->get_action() == item->action) {
            if (am->get_input_mappings().size() > item->index) {
                return ((Ref<GUIDEInputMapping>)am->get_input_mappings()[item->index])->get_input();
            } else {
                UtilityFunctions::push_error("Action mapping does not have an index of " + String::num(item->index) + ".");
            }
        }
    }
    return Ref<GUIDEInput>();
}

void GUIDERemapper::set_bound_input(const Ref<GUIDERemapperConfigItem> &item, const Ref<GUIDEInput> &input) {
    if (!_check_item(item)) return;

    _remapping_config->_clear(item->context, item->action, item->index);
    Ref<GUIDEInput> current_bound_input = get_bound_input_or_null(item);

    if (current_bound_input.is_null() && input.is_null()) {
        emit_signal("item_changed", item, input);
        return;
    }

    if (current_bound_input.is_null() || (input.is_valid() && !current_bound_input->is_same_as(input))) {
        _remapping_config->_bind(item->context, item->action, input, item->index);
    }
    emit_signal("item_changed", item, input);
}

Ref<GUIDEInput> GUIDERemapper::get_default_input(const Ref<GUIDERemapperConfigItem> &item) const {
    if (!_check_item(item)) return Ref<GUIDEInput>();
    TypedArray<GUIDEActionMapping> mappings = item->context->get_mappings();
    for (int i = 0; i < mappings.size(); i++) {
        Ref<GUIDEActionMapping> am = mappings[i];
        if (am->get_action() == item->action) {
            return ((Ref<GUIDEInputMapping>)am->get_input_mappings()[item->index])->get_input();
        }
    }
    return Ref<GUIDEInput>();
}

void GUIDERemapper::restore_default_for(const Ref<GUIDERemapperConfigItem> &item) {
    if (!_check_item(item)) return;
    _remapping_config->_clear(item->context, item->action, item->index);
    emit_signal("item_changed", item, get_bound_input_or_null(item));
}

bool GUIDERemapper::_check_item(const Ref<GUIDERemapperConfigItem> &item) const {
    if (!_mapping_contexts.has(item->context)) {
        UtilityFunctions::push_error("Given context is not known to this mapper. Did you call initialize()?");
        return false;
    }

    bool action_found = false;
    bool size_ok = false;
    TypedArray<GUIDEActionMapping> mappings = item->context->get_mappings();
    for (int i = 0; i < mappings.size(); i++) {
        Ref<GUIDEActionMapping> am = mappings[i];
        if (am->get_action() == item->action) {
            action_found = true;
            if (am->get_input_mappings().size() > item->index && item->index >= 0) {
                size_ok = true;
            }
            break;
        }
    }

    if (!action_found) {
        UtilityFunctions::push_error("Given action does not belong to the given context.");
        return false;
    }
    if (!size_ok) {
        UtilityFunctions::push_error("Given index does not exist for the given action's input binding.");
        return false;
    }
    if (!item->action->get_is_remappable()) {
        UtilityFunctions::push_error("Given action is not remappable.");
        return false;
    }
    return true;
}