#include "guide_mapping_context.h"

using namespace godot;

void GUIDEMappingContext::_bind_methods() {
    ClassDB::bind_method(D_METHOD("get_display_name"), &GUIDEMappingContext::get_display_name);
    ClassDB::bind_method(D_METHOD("set_display_name", "name"), &GUIDEMappingContext::set_display_name);
    ADD_PROPERTY(PropertyInfo(Variant::STRING, "display_name"), "set_display_name", "get_display_name");

    ClassDB::bind_method(D_METHOD("get_mappings"), &GUIDEMappingContext::get_mappings);
    ClassDB::bind_method(D_METHOD("set_mappings", "mappings"), &GUIDEMappingContext::set_mappings);
    ADD_PROPERTY(PropertyInfo(Variant::ARRAY, "mappings", PROPERTY_HINT_NONE, "24/17:GUIDEActionMapping", PROPERTY_USAGE_DEFAULT, "GUIDEActionMapping"), "set_mappings", "get_mappings");

    ADD_SIGNAL(MethodInfo("enabled"));
    ADD_SIGNAL(MethodInfo("disabled"));
}

GUIDEMappingContext::GUIDEMappingContext() {
}

GUIDEMappingContext::~GUIDEMappingContext() {
}

String GUIDEMappingContext::_editor_name() const {
    if (display_name.is_empty()) {
        return get_path().get_file();
    } else {
        return display_name;
    }
}