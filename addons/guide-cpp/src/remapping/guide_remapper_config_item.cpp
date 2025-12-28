#include "guide_remapper_config_item.h"
#include "guide_remapper.h"

using namespace godot;

void GUIDERemapperConfigItem::_bind_methods() {
    ClassDB::bind_method(D_METHOD("get_display_category"), &GUIDERemapperConfigItem::get_display_category);
    ClassDB::bind_method(D_METHOD("get_display_name"), &GUIDERemapperConfigItem::get_display_name);
    ClassDB::bind_method(D_METHOD("is_remappable"), &GUIDERemapperConfigItem::is_remappable);
    ClassDB::bind_method(D_METHOD("get_value_type"), &GUIDERemapperConfigItem::get_value_type);
    ClassDB::bind_method(D_METHOD("is_same_as", "other"), &GUIDERemapperConfigItem::is_same_as);

    ADD_PROPERTY(PropertyInfo(Variant::STRING, "display_category"), "", "get_display_category");
    ADD_PROPERTY(PropertyInfo(Variant::STRING, "display_name"), "", "get_display_name");
    ADD_PROPERTY(PropertyInfo(Variant::BOOL, "is_remappable"), "", "is_remappable");
    ADD_PROPERTY(PropertyInfo(Variant::INT, "value_type"), "", "get_value_type");

    ADD_SIGNAL(MethodInfo("changed", PropertyInfo(Variant::OBJECT, "input", PROPERTY_HINT_RESOURCE_TYPE, "GUIDEInput")));
}

GUIDERemapperConfigItem::GUIDERemapperConfigItem() {}

GUIDERemapperConfigItem::GUIDERemapperConfigItem(const Ref<GUIDEMappingContext> &p_context, const Ref<GUIDEAction> &p_action, int p_index, const Ref<GUIDEInputMapping> &p_input_mapping)
    : context(p_context), action(p_action), index(p_index), _input_mapping(p_input_mapping) {}

String GUIDERemapperConfigItem::get_display_category() const {
    return GUIDERemapper::_get_effective_display_category(action, _input_mapping);
}

String GUIDERemapperConfigItem::get_display_name() const {
    return GUIDERemapper::_get_effective_display_name(action, _input_mapping);
}

bool GUIDERemapperConfigItem::is_remappable() const {
    return GUIDERemapper::_is_effectively_remappable(action, _input_mapping);
}

int GUIDERemapperConfigItem::get_value_type() const {
    return (int)GUIDERemapper::_get_effective_value_type(action, _input_mapping);
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
