#include "guide_remapper.h"

using namespace godot;

// --- GUIDERemapperConfigItem ---

void GUIDERemapperConfigItem::_bind_methods() {
    ADD_SIGNAL(MethodInfo("changed", PropertyInfo(Variant::OBJECT, "input", PROPERTY_HINT_RESOURCE_TYPE, "GUIDEInput")));
}

String GUIDERemapperConfigItem::get_display_category() const {
    String result = "";
    if (input_mapping->get_override_action_settings()) {
        result = input_mapping->get_display_category();
    }
    if (result.is_empty()) {
        result = action->get_display_category();
    }
    return result;
}

String GUIDERemapperConfigItem::get_display_name() const {
    String result = "";
    if (input_mapping->get_override_action_settings()) {
        result = input_mapping->get_display_name();
    }
    if (result.is_empty()) {
        result = action->get_display_name();
    }
    return result;
}

bool GUIDERemapperConfigItem::is_effectively_remappable() const {
    return action->get_is_remappable() && (!input_mapping->get_override_action_settings() || input_mapping->get_is_remappable());
}

int GUIDERemapperConfigItem::get_effective_value_type() const {
    if (input_mapping->get_override_action_settings() && input_mapping->get_input().is_valid()) {
        return input_mapping->get_input()->_native_value_type();
    }
    return action->get_action_value_type();
}

bool GUIDERemapperConfigItem::is_same_as(const Ref<GUIDERemapperConfigItem> &other) const {
    if (other.is_null()) return false;
    return context == other->context && action == other->action && index == other->index;
}

void GUIDERemapperConfigItem::_item_changed(const Ref<GUIDERemapperConfigItem> &item, const Ref<GUIDEInput> &input) {
    if (is_same_as(item)) {
        emit_signal("changed", input);
    }
}

// --- GUIDERemapper ---

void GUIDERemapper::_bind_methods() {
    ADD_SIGNAL(MethodInfo("item_changed", PropertyInfo(Variant::OBJECT, "item", PROPERTY_HINT_RESOURCE_TYPE, "GUIDERemapperConfigItem"), PropertyInfo(Variant::OBJECT, "input", PROPERTY_HINT_RESOURCE_TYPE, "GUIDEInput")));
}

GUIDERemapper::GUIDERemapper() {
}

GUIDERemapper::~GUIDERemapper() {
}

void GUIDERemapper::initialize(const TypedArray<GUIDEMappingContext> &mapping_contexts, const Ref<GUIDERemappingConfig> &remapping_config) {
    if (remapping_config.is_valid()) {
        _remapping_config = remapping_config->duplicate();
    } else {
        _remapping_config.instantiate();
    }
    _mapping_contexts = mapping_contexts;
}

Ref<GUIDERemappingConfig> GUIDERemapper::get_mapping_config() const {
    if (_remapping_config.is_valid()) return _remapping_config->duplicate();
    return Ref<GUIDERemappingConfig>();
}

void GUIDERemapper::set_custom_data(const Variant &key, const Variant &value) {
    if (_remapping_config.is_valid()) {
        Dictionary data = _remapping_config->get_custom_data();
        data[key] = value;
        _remapping_config->set_custom_data(data);
    }
}

Variant GUIDERemapper::get_custom_data(const Variant &key, const Variant &default_val) const {
    if (_remapping_config.is_valid()) {
        return _remapping_config->get_custom_data().get(key, default_val);
    }
    return default_val;
}

void GUIDERemapper::remove_custom_data(const Variant &key) {
    if (_remapping_config.is_valid()) {
        Dictionary data = _remapping_config->get_custom_data();
        data.erase(key);
        _remapping_config->set_custom_data(data);
    }
}

TypedArray<GUIDERemapperConfigItem> GUIDERemapper::get_remappable_items(const Ref<GUIDEMappingContext> &context, const String &display_category, const Ref<GUIDEAction> &action) const {
    TypedArray<GUIDERemapperConfigItem> result;
    for (int i = 0; i < _mapping_contexts.size(); i++) {
        Ref<GUIDEMappingContext> a_context = _mapping_contexts[i];
        if (context.is_valid() && context != a_context) continue;

        TypedArray<GUIDEActionMapping> mappings = a_context->get_mappings();
        for (int j = 0; j < mappings.size(); j++) {
            Ref<GUIDEActionMapping> action_mapping = mappings[j];
            Ref<GUIDEAction> mapped_action = action_mapping->get_action();
            if (!mapped_action->get_is_remappable()) continue;
            if (action.is_valid() && action != mapped_action) continue;

            TypedArray<GUIDEInputMapping> input_mappings = action_mapping->get_input_mappings();
            for (int k = 0; k < input_mappings.size(); k++) {
                Ref<GUIDEInputMapping> input_mapping = input_mappings[k];
                if (input_mapping->get_override_action_settings() && !input_mapping->get_is_remappable()) continue;

                Ref<GUIDERemapperConfigItem> item;
                item.instantiate();
                item->context = a_context;
                item->action = mapped_action;
                item->index = k;
                item->input_mapping = input_mapping;

                if (!display_category.is_empty() && item->get_display_category() != display_category) continue;

                connect("item_changed", Callable(item.ptr(), "_item_changed"));
                result.append(item);
            }
        }
    }
    return result;
}

TypedArray<GUIDERemapperConfigItem> GUIDERemapper::get_input_collisions(const Ref<GUIDERemapperConfigItem> &item, const Ref<GUIDEInput> &input) const {
    TypedArray<GUIDERemapperConfigItem> result;
    if (input.is_null()) return result;
    if (!_check_item(item)) return result;

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
                if (_remapping_config.is_valid() && _remapping_config->_has(context, action, k)) {
                    bound_input = _remapping_config->_get_bound_input_or_null(context, action, k);
                }

                if (bound_input.is_valid() && bound_input->is_same_as(input)) {
                    Ref<GUIDERemapperConfigItem> collision_item;
                    collision_item.instantiate();
                    collision_item->context = context;
                    collision_item->action = action;
                    collision_item->index = k;
                    collision_item->input_mapping = input_mapping;
                    connect("item_changed", Callable(collision_item.ptr(), "_item_changed"));
                    result.append(collision_item);
                }
            }
        }
    }
    return result;
}

Ref<GUIDEInput> GUIDERemapper::get_bound_input_or_null(const Ref<GUIDERemapperConfigItem> &item) const {
    if (!_check_item(item)) return Ref<GUIDEInput>();
    if (_remapping_config.is_valid() && _remapping_config->_has(item->context, item->action, item->index)) {
        return _remapping_config->_get_bound_input_or_null(item->context, item->action, item->index);
    }
    return get_default_input(item);
}

void GUIDERemapper::set_bound_input(const Ref<GUIDERemapperConfigItem> &item, const Ref<GUIDEInput> &input) {
    if (!_check_item(item)) return;
    if (_remapping_config.is_valid()) {
        _remapping_config->_clear(item->context, item->action, item->index);
        Ref<GUIDEInput> bound_input = get_bound_input_or_null(item);
        if (bound_input.is_null() && input.is_null()) {
            emit_signal("item_changed", item, input);
            return;
        }
        if (bound_input.is_valid() && input.is_valid() && bound_input->is_same_as(input)) {
            emit_signal("item_changed", item, input);
            return;
        }
        _remapping_config->_bind(item->context, item->action, input, item->index);
        emit_signal("item_changed", item, input);
    }
}

Ref<GUIDEInput> GUIDERemapper::get_default_input(const Ref<GUIDERemapperConfigItem> &item) const {
    if (!_check_item(item)) return Ref<GUIDEInput>();
    TypedArray<GUIDEActionMapping> mappings = item->context->get_mappings();
    for (int i = 0; i < mappings.size(); i++) {
        Ref<GUIDEActionMapping> mapping = mappings[i];
        if (mapping->get_action() == item->action) {
            return ((Ref<GUIDEInputMapping>)mapping->get_input_mappings()[item->index])->get_input();
        }
    }
    return Ref<GUIDEInput>();
}

void GUIDERemapper::restore_default_for(const Ref<GUIDERemapperConfigItem> &item) {
    if (!_check_item(item)) return;
    if (_remapping_config.is_valid()) {
        _remapping_config->_clear(item->context, item->action, item->index);
        emit_signal("item_changed", item, get_bound_input_or_null(item));
    }
}

bool GUIDERemapper::_check_item(const Ref<GUIDERemapperConfigItem> &item) const {
    if (item.is_null()) return false;
    bool context_found = false;
    for (int i = 0; i < _mapping_contexts.size(); i++) {
        if (_mapping_contexts[i] == item->context) {
            context_found = true;
            break;
        }
    }
    if (!context_found) return false;
    if (!item->action->get_is_remappable()) return false;
    return true;
}
