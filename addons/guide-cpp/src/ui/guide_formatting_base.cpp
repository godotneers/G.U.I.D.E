#include "guide_formatting_base.h"

using namespace godot;

void GUIDETextProvider::_bind_methods() {
    ClassDB::bind_method(D_METHOD("get_priority"), &GUIDETextProvider::get_priority);
    ClassDB::bind_method(D_METHOD("set_priority", "priority"), &GUIDETextProvider::set_priority);
    ADD_PROPERTY(PropertyInfo(Variant::INT, "priority"), "set_priority", "get_priority");
}

void GUIDEIconRenderer::_bind_methods() {
    ClassDB::bind_method(D_METHOD("get_priority"), &GUIDEIconRenderer::get_priority);
    ClassDB::bind_method(D_METHOD("set_priority", "priority"), &GUIDEIconRenderer::set_priority);
    ADD_PROPERTY(PropertyInfo(Variant::INT, "priority"), "set_priority", "get_priority");
}
