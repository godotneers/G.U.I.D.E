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

            Ref<Texture2D> result;
            // Ref<Image> result;

        protected:
            static void _bind_methods() {
                ADD_SIGNAL(MethodInfo("done"));
            }
    };

    GUIDEIconMaker() {}
    virtual ~GUIDEIconMaker() {}

    void _ready() override {
        // if (Engine::get_singleton()->is_editor_hint()) return;

        set_process_mode(PROCESS_MODE_ALWAYS);
        
        _sub_viewport = Object::cast_to<SubViewport>(get_node_or_null("%SubViewport"));
        _root = Object::cast_to<Node2D>(get_node_or_null("%Root"));
        _scene_holder = Object::cast_to<Sprite2D>(get_node_or_null("%SceneHolder"));

        if (_sub_viewport == nullptr || _root == nullptr || _scene_holder == nullptr) {
            UtilityFunctions::push_error("GUIDEIconMaker: missing required child nodes (SubViewport/Root/SceneHolder).");
            set_process(false);
            return;
        }

        Ref<ViewportTexture> vt;
        vt.instantiate();
        // Viewport path needs to be absolute or relative to the node.
        // In GDExtension, it's safer to wait until ready or use set_viewport_path_internal if available,
        // but set_viewport_path works if the node is in the tree.
        vt->set_viewport_path_in_scene(get_path_to(_sub_viewport));
        _scene_holder->set_texture(vt);
        // _scene_holder->show();

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

    Ref<Job> make_icon(const Ref<GUIDEInput> &input, GUIDEIconRenderer* renderer, int height_px, const Ref<GUIDEInputFormattingOptions> &options) {
        UtilityFunctions::print("height ", height_px);
        if (_sub_viewport == nullptr) {
            _sub_viewport = Object::cast_to<SubViewport>(get_node_or_null("SubViewport")); // Remove % if not in tree fully yet, or use find_child
            // If still null, we are in trouble.
        }
        DirAccess::make_dir_recursive_absolute("user://_guide_cache");
        String key = (String::num(height_px) + renderer->cache_key(input, options)).sha256_text();
        String path = "user://_guide_cache/" + key + ".res";

        // if (ResourceLoader::get_singleton()->exists(path)) {
        //     return ResourceLoader::get_singleton()->load(path, "Texture2D");
        // }

        if (ResourceLoader::get_singleton()->exists(path)) {
            // Create a "fake" job that is already finished
            Ref<Job> completed_job;
            completed_job.instantiate();
            completed_job->result = ResourceLoader::get_singleton()->load(path, "Texture2D");
            
            // We return it immediately. The caller will see result is valid.
            return completed_job;
        }

        Ref<Job> job;
        job.instantiate();
        job->height = height_px;
        job->input = input;
        job->renderer = renderer;
        job->options = options;
        _pending_requests.append(job);
        set_process(true);

        return job;
    }

    void _process(double delta) override {
        if (_current_request.is_null() && _pending_requests.is_empty()) {
            set_process(false);
            return;
        }

        if (_sub_viewport == nullptr || _root == nullptr || _scene_holder == nullptr) {
            UtilityFunctions::push_error("GUIDEIconMaker: processing with uninitialized nodes; aborting.");
            _pending_requests.clear();
            _current_request.unref();
            set_process(false);
            return;
        }

        if (_current_request.is_null()) {
            _current_request = _pending_requests.pop_front();
            UtilityFunctions::print(_current_request->renderer);
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
                    UtilityFunctions::print(actual_size, " | ", scale, " | ", actual_size * scale);
                    _root->set_scale(Vector2(scale, scale));
                    _sub_viewport->set_size(actual_size * scale);
                }
            }
            UtilityFunctions::print("Wait frames: ", _wait_frames);
            _wait_frames--;
            return;
        }

        // Fetch the image from the viewport texture
        Ref<Texture2D> vt = _sub_viewport->get_texture();
        if (vt.is_valid()) {
            // Get image from GPU
            Ref<Image> image = vt->get_image();
            
            if (image.is_valid() && !image->is_empty()) {
                String key = (String::num(_current_request->height) + _current_request->renderer->cache_key(_current_request->input, _current_request->options)).sha256_text();
                String path = "user://_guide_cache/" + key + ".res";
                
                Ref<ImageTexture> image_texture = ImageTexture::create_from_image(image);
                if (image_texture.is_valid()) {
                    ResourceSaver::get_singleton()->save(image_texture, path);
                    image_texture->take_over_path(path);
                    _current_request->result = image_texture;
                    // _fetch_image = true;
                    // return;
                }
            } else {
                UtilityFunctions::push_error("GUIDEIconMaker: Captured image was empty or invalid.");
            }
        } else {
            UtilityFunctions::push_error("GUIDEIconMaker: SceneHolder has no valid texture.");
        }

        // if (_fetch_image) {
            // _fetch_image = false;
            _current_request->emit_signal("done");
            
            _root->remove_child(_current_request->renderer);
            // _sub_viewport->set_update_mode(SubViewport::UPDATE_DISABLED);
            _current_request.unref();
            // return;
        // }

    }

protected:
    static void _bind_methods() {
        ClassDB::bind_method(D_METHOD("clear_cache"), &GUIDEIconMaker::clear_cache);
        ClassDB::bind_method(D_METHOD("make_icon", "input", "renderer", "height_px", "options"), &GUIDEIconMaker::make_icon);
    }

private:
    bool _fetch_image = false;
    SubViewport *_sub_viewport = nullptr;
    Node2D *_root = nullptr;
    Sprite2D *_scene_holder = nullptr;

    TypedArray<Job> _pending_requests;
    Ref<Job> _current_request;
    int _wait_frames = 0;
};

#endif // GUIDE_ICON_MAKER_H
