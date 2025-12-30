#ifndef GUIDE_ICON_MAKER_H
#define GUIDE_ICON_MAKER_H

#include <godot_cpp/classes/node2d.hpp>
#include <godot_cpp/classes/sub_viewport.hpp>
#include <godot_cpp/classes/sprite2d.hpp>
#include <godot_cpp/classes/image.hpp>
#include <godot_cpp/classes/texture2d.hpp>
#include <godot_cpp/classes/image_texture.hpp>
#include <godot_cpp/classes/dir_access.hpp>
#include <godot_cpp/classes/resource_loader.hpp>
#include <godot_cpp/classes/resource_saver.hpp>
#include <godot_cpp/classes/viewport_texture.hpp>
#include <godot_cpp/classes/scene_tree.hpp>
#include <godot_cpp/classes/engine.hpp>

#include "ui/guide_icon_renderer.h"

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

    GUIDEIconMaker() {}
    virtual ~GUIDEIconMaker() {}

    void _ready() override {
        if (Engine::get_singleton()->is_editor_hint()) return;

        set_process_mode(PROCESS_MODE_ALWAYS);
        
        _sub_viewport = Object::cast_to<SubViewport>(get_node_or_null("%SubViewport"));
        _root = Object::cast_to<Node2D>(get_node_or_null("%Root"));
        _scene_holder = Object::cast_to<Sprite2D>(get_node_or_null("%Sprite2D"));

        Ref<ViewportTexture> vt;
        vt.instantiate();
        // Viewport path needs to be absolute or relative to the node.
        // In GDExtension, it's safer to wait until ready or use set_viewport_path_internal if available,
        // but set_viewport_path works if the node is in the tree.
        vt->set_viewport_path_in_scene(get_path_to(_sub_viewport));
        _scene_holder->set_texture(vt);

        if (_pending_requests.is_empty()) {
            set_process(false);
        }
    }

    void clear_cache() {
        Ref<DirAccess> dir = DirAccess::open("user://_guide_cache");
        if (dir.is_valid()) {
            PackedStringArray files = dir->get_files();
            for (int i = 0; i < files.size(); i++) {
                dir->remove("user://_guide_cache/" + files[i]);
            }
        }
    }

    Ref<Texture2D> make_icon(const Ref<GUIDEInput> &input, GUIDEIconRenderer* renderer, int height_px, const Ref<GUIDEInputFormattingOptions> &options) {
        DirAccess::make_dir_recursive_absolute("user://_guide_cache");
        String key = (String::num(height_px) + renderer->cache_key(input, options)).sha256_text();
        String path = "user://_guide_cache/" + key + ".res";

        if (ResourceLoader::get_singleton()->exists(path)) {
            return ResourceLoader::get_singleton()->load(path, "Texture2D");
        }

        Ref<Job> job;
        job.instantiate();
        job->height = height_px;
        job->input = input;
        job->renderer = renderer;
        job->options = options;
        _pending_requests.append(job);
        set_process(true);

        return Ref<Texture2D>();
    }

    void _process(double delta) override {
        if (_current_request.is_null() && _pending_requests.is_empty()) {
            set_process(false);
            return;
        }

        if (_current_request.is_null()) {
            _current_request = _pending_requests.pop_front();
            _root->add_child(_current_request->renderer);
            _current_request->renderer->render(_current_request->input, _current_request->options);
            
            _wait_frames = 4; // Matches the 3 frame delay in GDScript + 1 for initial render
            _sub_viewport->set_update_mode(SubViewport::UPDATE_ALWAYS);
            return;
        }

        if (_wait_frames > 0) {
            if (_wait_frames == 4) {
                // After the first frame of rendering, we can get the actual size
                Vector2 actual_size = _current_request->renderer->get_rect().size;
                if (actual_size.y > 0) {
                    float scale = (float)_current_request->height / actual_size.y;
                    _root->set_scale(Vector2(scale, scale));
                    _sub_viewport->set_size(actual_size * scale);
                }
            }
            _wait_frames--;
            return;
        }

        // Fetch the image from the viewport texture
        Ref<Texture2D> vt = _scene_holder->get_texture();
        if (vt.is_valid()) {
            Ref<Image> image = vt->get_image();
            _current_request->result = image;
            
            // Save to cache
            String key = (String::num(_current_request->height) + _current_request->renderer->cache_key(_current_request->input, _current_request->options)).sha256_text();
            String path = "user://_guide_cache/" + key + ".res";
            
            Ref<ImageTexture> image_texture = ImageTexture::create_from_image(image);
            ResourceSaver::get_singleton()->save(image_texture, path);
            image_texture->take_over_path(path);
        }

        _current_request->emit_signal("done");
        
        _root->remove_child(_current_request->renderer);
        _sub_viewport->set_update_mode(SubViewport::UPDATE_DISABLED);
        _current_request.unref();
    }

protected:
    static void _bind_methods() {
        ClassDB::bind_method(D_METHOD("clear_cache"), &GUIDEIconMaker::clear_cache);
        ClassDB::bind_method(D_METHOD("make_icon", "input", "renderer", "height_px", "options"), &GUIDEIconMaker::make_icon);
    }

private:
    SubViewport *_sub_viewport = nullptr;
    Node2D *_root = nullptr;
    Sprite2D *_scene_holder = nullptr;

    TypedArray<Job> _pending_requests;
    Ref<Job> _current_request;
    int _wait_frames = 0;
};

#endif // GUIDE_ICON_MAKER_H
