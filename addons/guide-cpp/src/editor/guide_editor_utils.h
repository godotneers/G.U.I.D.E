#ifndef GUIDE_EDITOR_UTILS_H
#define GUIDE_EDITOR_UTILS_H

#include <godot_cpp/classes/node.hpp>
#include <godot_cpp/classes/resource.hpp>
#include <godot_cpp/classes/engine.hpp>
#include <godot_cpp/classes/editor_interface.hpp>
#include <godot_cpp/core/class_db.hpp>

using namespace godot;

class GUIDEEditorUtils : public Object {
    GDCLASS(GUIDEEditorUtils, Object)

public:
    static void clear(Node *p_node) {
        if (p_node == nullptr) {
            return;
        }
        TypedArray<Node> children = p_node->get_children();
        for (int i = 0; i < children.size(); i++) {
            Node *child = Object::cast_to<Node>(children[i]);
            p_node->remove_child(child);
            child->queue_free();
        }
    }

    static Ref<Resource> duplicate_if_inline(const Ref<Resource> &p_resource) {
        if (is_inline(p_resource)) {
            return p_resource->duplicate();
        }
        return p_resource;
    }

    static bool is_inline(const Ref<Resource> &p_resource) {
        if (p_resource.is_null()) {
            return false;
        }
        return p_resource->get_path().contains("::") || p_resource->get_path() == "";
    }

    static bool is_node_in_edited_scene(Node *p_node) {
        if (!Engine::get_singleton()->is_editor_hint()) {
            return false;
        }

        if (p_node == nullptr) {
            return false;
        }

        EditorInterface *ei = EditorInterface::get_singleton();
        if (ei == nullptr) {
            return false;
        }
        
        Node *scene_root = ei->get_edited_scene_root();
        if (scene_root == nullptr) {
            return false;
        }

        return (p_node == scene_root) || scene_root->is_ancestor_of(p_node);
    }

protected:
    static void _bind_methods() {
        ClassDB::bind_static_method("GUIDEEditorUtils", D_METHOD("clear", "node"), &GUIDEEditorUtils::clear);
        ClassDB::bind_static_method("GUIDEEditorUtils", D_METHOD("duplicate_if_inline", "resource"), &GUIDEEditorUtils::duplicate_if_inline);
        ClassDB::bind_static_method("GUIDEEditorUtils", D_METHOD("is_inline", "resource"), &GUIDEEditorUtils::is_inline);
        ClassDB::bind_static_method("GUIDEEditorUtils", D_METHOD("is_node_in_edited_scene", "node"), &GUIDEEditorUtils::is_node_in_edited_scene);
    }
};

#endif // GUIDE_EDITOR_UTILS_H
