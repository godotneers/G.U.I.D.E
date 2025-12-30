#ifndef GUIDE_FALLBACK_RENDERER_H
#define GUIDE_FALLBACK_RENDERER_H

#include "ui/guide_icon_renderer.h"

using namespace godot;

class GUIDEFallbackRenderer : public GUIDEIconRenderer {
    GDCLASS(GUIDEFallbackRenderer, GUIDEIconRenderer)

public:
    GUIDEFallbackRenderer() {
        priority = 100;
    }
    virtual ~GUIDEFallbackRenderer() {}

    virtual bool supports(const Ref<GUIDEInput> &input, const Ref<GUIDEInputFormattingOptions> &options) override {
        return true;
    }

    virtual void render(const Ref<GUIDEInput> &input, const Ref<GUIDEInputFormattingOptions> &options) override {}

    virtual String cache_key(const Ref<GUIDEInput> &input, const Ref<GUIDEInputFormattingOptions> &options) override {
        return "2e130e8b-d5b3-478c-af65-53415adfd6bb";
    }

protected:
    static void _bind_methods() {}
};

#endif // GUIDE_FALLBACK_RENDERER_H
