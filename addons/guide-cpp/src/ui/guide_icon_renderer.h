#ifndef GUIDE_ICON_RENDERER_H
#define GUIDE_ICON_RENDERER_H

#include <godot_cpp/core/class_db.hpp>
#include <godot_cpp/classes/control.hpp>
#include <godot_cpp/classes/engine.hpp>
#include <godot_cpp/variant/utility_functions.hpp>
#include "guide_input_formatting_options.h"
#include "inputs/guide_input.h"
#include "../editor/guide_editor_utils.h"

using namespace godot;

class GUIDEIconRenderer : public Control {
    GDCLASS(GUIDEIconRenderer, Control)

public:
    GUIDEIconRenderer() {}
    virtual ~GUIDEIconRenderer() {}

    void _ready() override {
        if (GUIDEEditorUtils::is_node_in_edited_scene(this)) { return; }
        set_process_mode(PROCESS_MODE_ALWAYS);
    }

    virtual bool supports(const Ref<GUIDEInput> &input, const Ref<GUIDEInputFormattingOptions> &options) {
        return false;
    }

    virtual void render(const Ref<GUIDEInput> &input, const Ref<GUIDEInputFormattingOptions> &options) {
    }

    virtual String cache_key(const Ref<GUIDEInput> &input, const Ref<GUIDEInputFormattingOptions> &options) {
        UtilityFunctions::push_error("Custom renderers must override the cache_key function to ensure proper caching.");
        return "i-forgot-the-cache-key";
    }

    int get_priority() const { return priority; }
    void set_priority(int p_priority) { priority = p_priority; }

protected:
    static void _bind_methods() {
        ClassDB::bind_method(D_METHOD("get_priority"), &GUIDEIconRenderer::get_priority);
        ClassDB::bind_method(D_METHOD("set_priority", "priority"), &GUIDEIconRenderer::set_priority);
        ADD_PROPERTY(PropertyInfo(Variant::INT, "priority"), "set_priority", "get_priority");

        ClassDB::bind_method(D_METHOD("supports", "input", "options"), &GUIDEIconRenderer::supports);
        ClassDB::bind_method(D_METHOD("render", "input", "options"), &GUIDEIconRenderer::render);
        ClassDB::bind_method(D_METHOD("cache_key", "input", "options"), &GUIDEIconRenderer::cache_key);
    }
    
    int priority = 0;
};

#endif // GUIDE_ICON_RENDERER_H