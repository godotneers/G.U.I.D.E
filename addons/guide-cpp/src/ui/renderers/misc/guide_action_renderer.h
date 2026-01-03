#ifndef GUIDE_ACTION_RENDERER_H
#define GUIDE_ACTION_RENDERER_H

#include "ui/guide_icon_renderer.h"
#include "inputs/guide_input_action.h"
#include <godot_cpp/classes/texture_rect.hpp>

using namespace godot;

class GUIDEActionRenderer : public GUIDEIconRenderer {
    GDCLASS(GUIDEActionRenderer, GUIDEIconRenderer)

public:
    GUIDEActionRenderer() {}
    virtual ~GUIDEActionRenderer() {}

    virtual bool supports(const Ref<GUIDEInput> &input, const Ref<GUIDEInputFormattingOptions> &options) override {
        return Object::cast_to<GUIDEInputAction>(input.ptr()) != nullptr;
    }

    virtual void render(const Ref<GUIDEInput> &input, const Ref<GUIDEInputFormattingOptions> &options) override {}

    virtual String cache_key(const Ref<GUIDEInput> &input, const Ref<GUIDEInputFormattingOptions> &options) override {
        return "0ecd6608-ba3c-4fc2-83f7-ad61736f1106";
    }

protected:
    static void _bind_methods() {}
};

#endif // GUIDE_ACTION_RENDERER_H
