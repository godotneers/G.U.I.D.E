#ifndef GUIDE_TEXT_PROVIDER_H
#define GUIDE_TEXT_PROVIDER_H

#include <godot_cpp/core/class_db.hpp>
#include <godot_cpp/classes/ref_counted.hpp>
#include "guide_input_formatting_options.h"
#include "inputs/guide_input.h"

using namespace godot;

class GUIDETextProvider : public RefCounted {
    GDCLASS(GUIDETextProvider, RefCounted)

public:
    GUIDETextProvider() {}
    virtual ~GUIDETextProvider() {}

    virtual bool supports(const Ref<GUIDEInput> &input, const Ref<GUIDEInputFormattingOptions> &options) const { return false; }
    virtual String get_text(const Ref<GUIDEInput> &input, const Ref<GUIDEInputFormattingOptions> &options) const { return "not implemented"; }

    int get_priority() const { return priority; }
    void set_priority(int p_priority) { priority = p_priority; }

protected:
    static void _bind_methods() {
        ClassDB::bind_method(D_METHOD("get_priority"), &GUIDETextProvider::get_priority);
        ClassDB::bind_method(D_METHOD("set_priority", "priority"), &GUIDETextProvider::set_priority);
        ADD_PROPERTY(PropertyInfo(Variant::INT, "priority"), "set_priority", "get_priority");
    }
    
    int priority = 0;
};

#endif // GUIDE_TEXT_PROVIDER_H