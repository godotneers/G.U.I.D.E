#include "guide_action_mapping.h"

using namespace godot;

void GUIDEActionMapping::_bind_methods() {
    ClassDB::bind_method(D_METHOD("get_action"), &GUIDEActionMapping::get_action);
    ClassDB::bind_method(D_METHOD("set_action", "action"), &GUIDEActionMapping::set_action);
    ADD_PROPERTY(PropertyInfo(Variant::OBJECT, "action", PROPERTY_HINT_RESOURCE_TYPE, "GUIDEAction"), "set_action", "get_action");

    ClassDB::bind_method(D_METHOD("get_input_mappings"), &GUIDEActionMapping::get_input_mappings);
    ClassDB::bind_method(D_METHOD("set_input_mappings", "mappings"), &GUIDEActionMapping::set_input_mappings);
    ADD_PROPERTY(PropertyInfo(Variant::ARRAY, "input_mappings", PROPERTY_HINT_NONE, "24/17:GUIDEInputMapping", PROPERTY_USAGE_DEFAULT, "GUIDEInputMapping"), "set_input_mappings", "get_input_mappings");
}

GUIDEActionMapping::GUIDEActionMapping() {
}

GUIDEActionMapping::~GUIDEActionMapping() {
}