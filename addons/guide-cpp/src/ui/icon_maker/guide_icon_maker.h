#ifndef GUIDE_ICON_MAKER_H
#define GUIDE_ICON_MAKER_H

#include <godot_cpp/classes/node2d.hpp>
#include <godot_cpp/classes/sub_viewport.hpp>
#include <godot_cpp/classes/sprite2d.hpp>
#include <godot_cpp/classes/image.hpp>
#include <godot_cpp/classes/texture2d.hpp>
#include "guide_formatting_base.h"

using namespace godot;

class GUIDEIconMaker : public Node2D {
    GDCLASS(GUIDEIconMaker, Node2D)

public:
    class Job : public RefCounted {
        GDCLASS(Job, RefCounted)
    public:
        int height;
        Ref<GUIDEInput> input;
        GUIDEIconRenderer* renderer;
        Ref<GUIDEInputFormattingOptions> options;
        Ref<Image> result;
    protected:
        static void _bind_methods() {
            ADD_SIGNAL(MethodInfo("done"));
        }
    };

    GUIDEIconMaker();
    virtual ~GUIDEIconMaker();

    void _ready() override;
    void _process(double delta) override;

    void clear_cache();
    Ref<Texture2D> make_icon(const Ref<GUIDEInput> &input, GUIDEIconRenderer* renderer, int height_px, const Ref<GUIDEInputFormattingOptions> &options);

protected:
    static void _bind_methods();

private:
    SubViewport *_sub_viewport = nullptr;
    Node2D *_root = nullptr;
    Sprite2D *_scene_holder = nullptr;

    TypedArray<Job> _pending_requests;
    Ref<Job> _current_request;
    bool _fetch_image = false;

    static const String CACHE_DIR;
};

#endif // GUIDE_ICON_MAKER_H