#include "guide_remapping_config.h"

using namespace godot;

void GUIDERemappingConfig::_bind_methods() {
    ClassDB::bind_method(D_METHOD("get_remapped_inputs"), &GUIDERemappingConfig::get_remapped_inputs);
    ClassDB::bind_method(D_METHOD("set_remapped_inputs", "inputs"), &GUIDERemappingConfig::set_remapped_inputs);
    ADD_PROPERTY(PropertyInfo(Variant::DICTIONARY, "remapped_inputs"), "set_remapped_inputs", "get_remapped_inputs");

    ClassDB::bind_method(D_METHOD("get_custom_data"), &GUIDERemappingConfig::get_custom_data);
    ClassDB::bind_method(D_METHOD("set_custom_data", "data"), &GUIDERemappingConfig::set_custom_data);
    ADD_PROPERTY(PropertyInfo(Variant::DICTIONARY, "custom_data"), "set_custom_data", "get_custom_data");
}

GUIDERemappingConfig::GUIDERemappingConfig() {
}

GUIDERemappingConfig::~GUIDERemappingConfig() {
}

void GUIDERemappingConfig::_bind(const Ref<GUIDEMappingContext> &mapping_context, const Ref<GUIDEAction> &action, const Ref<GUIDEInput> &input, int index) {
    if (!remapped_inputs.has(mapping_context)) {
        remapped_inputs[mapping_context] = Dictionary();
    }
    Dictionary context_dict = remapped_inputs[mapping_context];
    if (!context_dict.has(action)) {
        context_dict[action] = Dictionary();
    }
    Dictionary action_dict = context_dict[action];
    action_dict[index] = input;
}

void GUIDERemappingConfig::_unbind(const Ref<GUIDEMappingContext> &mapping_context, const Ref<GUIDEAction> &action, int index) {
    _bind(mapping_context, action, Ref<GUIDEInput>(), index);
}

void GUIDERemappingConfig::_clear(const Ref<GUIDEMappingContext> &mapping_context, const Ref<GUIDEAction> &action, int index) {
    if (!remapped_inputs.has(mapping_context)) return;
    Dictionary context_dict = remapped_inputs[mapping_context];
    if (!context_dict.has(action)) return;
    Dictionary action_dict = context_dict[action];
    action_dict.erase(index);
    if (action_dict.is_empty()) {
        context_dict.erase(action);
    }
    if (context_dict.is_empty()) {
        remapped_inputs.erase(mapping_context);
    }
}

Ref<GUIDEInput> GUIDERemappingConfig::_get_bound_input_or_null(const Ref<GUIDEMappingContext> &mapping_context, const Ref<GUIDEAction> &action, int index) const {
    if (!remapped_inputs.has(mapping_context)) return Ref<GUIDEInput>();
    Dictionary context_dict = remapped_inputs[mapping_context];
    if (!context_dict.has(action)) return Ref<GUIDEInput>();
    Dictionary action_dict = context_dict[action];
    return action_dict.get(index, Ref<GUIDEInput>());
}

bool GUIDERemappingConfig::_has(const Ref<GUIDEMappingContext> &mapping_context, const Ref<GUIDEAction> &action, int index) const {
    if (!remapped_inputs.has(mapping_context)) return false;
    Dictionary context_dict = remapped_inputs[mapping_context];
    if (!context_dict.has(action)) return false;
    Dictionary action_dict = context_dict[action];
    return action_dict.has(index);
}