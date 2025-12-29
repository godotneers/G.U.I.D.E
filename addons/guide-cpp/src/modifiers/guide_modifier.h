#ifndef GUIDE_MODIFIER_H
#define GUIDE_MODIFIER_H

#include <godot_cpp/classes/resource.hpp>
#include <godot_cpp/variant/vector3.hpp>
#include <godot_cpp/core/class_db.hpp>
#include <godot_cpp/core/math_defs.hpp>

using namespace godot;

class GUIDEModifier : public Resource {
    GDCLASS(GUIDEModifier, Resource)

public:
    GUIDEModifier();
    virtual ~GUIDEModifier();

    virtual bool is_same_as(const Ref<GUIDEModifier> &other) const;
    virtual void _begin_usage();
    virtual void _end_usage();
    virtual Vector3 _modify_input(Vector3 input, double delta, int value_type) const;
    virtual String _editor_name() const;
    virtual String _editor_description() const;
    virtual bool _needs_physics_process() const;
    virtual void _physics_process(double delta);

protected:
    static void _bind_methods();
};

#endif // GUIDE_MODIFIER_H