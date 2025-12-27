#ifndef GUIDE_FORMATTING_BASE_H
#define GUIDE_FORMATTING_BASE_H

#include <godot_cpp/core/class_db.hpp>
#include <godot_cpp/classes/control.hpp>
#include <godot_cpp/classes/ref_counted.hpp>
#include "guide_input_formatting_options.h"
#include "../inputs/guide_input.h"

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
    static void _bind_methods();
    int priority = 0;
};

class GUIDEIconRenderer : public Control {
    GDCLASS(GUIDEIconRenderer, Control)

public:
    GUIDEIconRenderer() {}
    virtual ~GUIDEIconRenderer() {}

    virtual bool supports(const Ref<GUIDEInput> &input, const Ref<GUIDEInputFormattingOptions> &options) const { return false; }
    virtual void render(const Ref<GUIDEInput> &input, const Ref<GUIDEInputFormattingOptions> &options) {}
    virtual String cache_key(const Ref<GUIDEInput> &input, const Ref<GUIDEInputFormattingOptions> &options) const { return "i-forgot-the-cache-key"; }

    int get_priority() const { return priority; }
    void set_priority(int p_priority) { priority = p_priority; }

protected:
    static void _bind_methods();
    int priority = 0;
};

#endif // GUIDE_FORMATTING_BASE_H