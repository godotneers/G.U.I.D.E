#include "guide_modifier.h"

using namespace godot;

void GUIDEModifier::_bind_methods() {
}

GUIDEModifier::GUIDEModifier() {
}

GUIDEModifier::~GUIDEModifier() {
}

bool GUIDEModifier::is_same_as(const Ref<GUIDEModifier> &other) const {
    return this == other.ptr();
}

void GUIDEModifier::_begin_usage() {
}

void GUIDEModifier::_end_usage() {
}

Vector3 GUIDEModifier::_modify_input(Vector3 input, double delta, GUIDEAction::GUIDEActionValueType value_type) const {
    return input;
}

String GUIDEModifier::_editor_name() const {
    return "";
}

String GUIDEModifier::_editor_description() const {
    return "";
}

bool GUIDEModifier::_needs_physics_process() const {
    return false;
}

void GUIDEModifier::_physics_process(double delta) {
}