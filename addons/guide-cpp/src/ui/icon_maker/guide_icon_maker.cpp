#include "guide_icon_maker.h"
#include <godot_cpp/classes/dir_access.hpp>
#include <godot_cpp/classes/resource_loader.hpp>
#include <godot_cpp/classes/resource_saver.hpp>
#include <godot_cpp/classes/image_texture.hpp>
#include <godot_cpp/classes/scene_tree.hpp>

namespace godot {

const String GUIDEIconMaker::CACHE_DIR = "user://_guide_cache";

void GUIDEIconMaker::_bind_methods() {
    ClassDB::bind_method(D_METHOD("clear_cache"), &GUIDEIconMaker::clear_cache);
}

GUIDEIconMaker::GUIDEIconMaker() {}
GUIDEIconMaker::~GUIDEIconMaker() {}

void GUIDEIconMaker::_ready() {
    set_process_mode(PROCESS_MODE_ALWAYS);
    if (_pending_requests.is_empty()) set_process(false);

    _sub_viewport = memnew(SubViewport);
    _sub_viewport->set_transparent_background(true);
    _sub_viewport->set_disable_input(true);
    add_child(_sub_viewport);

    _root = memnew(Node2D);
    _sub_viewport->add_child(_root);

    _scene_holder = memnew(Sprite2D);
    _scene_holder->set_visible(false);
    add_child(_scene_holder);
    // Note: ViewportTexture setup usually requires being in scene tree or handled via code
}

void GUIDEIconMaker::clear_cache() {
    Ref<DirAccess> dir = DirAccess::open(CACHE_DIR);
    if (dir.is_valid()) {
        PackedStringArray files = dir->get_files();
        for (int i = 0; i < files.size(); i++) {
            dir->remove(files[i]);
        }
    }
}

Ref<Texture2D> GUIDEIconMaker::make_icon(const Ref<GUIDEInput> &input, GUIDEIconRenderer* renderer, int height_px, const Ref<GUIDEInputFormattingOptions> &options) {
    DirAccess::make_dir_recursive_absolute(CACHE_DIR);
    String key = (String::num(height_px) + renderer->cache_key(input, options)).sha256_text();
    String path = CACHE_DIR + "/" + key + ".res";

    if (ResourceLoader::get_singleton()->exists(path)) {
        return ResourceLoader::get_singleton()->load(path, "Texture2D");
    }

    Ref<Job> job; job.instantiate();
    job->height = height_px;
    job->input = input;
    job->renderer = renderer;
    job->options = options;
    _pending_requests.append(job);
    set_process(true);

    // This method in GDScript was async. C++ GDExtension methods aren't easily async in the same way.
    // The user will have to wait for a signal or we return a placeholder.
    // For parity, we just start the process.
    return Ref<Texture2D>(); 
}

void GUIDEIconMaker::_process(double delta) {
    if (_current_request.is_null() && _pending_requests.is_empty()) {
        set_process(false);
        return;
    }

    if (_current_request.is_null()) {
        _current_request = _pending_requests.pop_front();
        _root->add_child(_current_request->renderer);
        _current_request->renderer->render(_current_request->input, _current_request->options);
        
        // Scaled rendering logic
        _fetch_image = true; // Simplified for shell
        return;
    }

    if (_fetch_image) {
        // Finalize job logic
        _root->remove_child(_current_request->renderer);
        _current_request->emit_signal("done");
        _current_request.unref();
        _fetch_image = false;
    }
}

} // namespace godot
