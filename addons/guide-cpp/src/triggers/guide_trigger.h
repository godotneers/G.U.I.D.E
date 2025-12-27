#ifndef GUIDE_TRIGGER_H
#define GUIDE_TRIGGER_H

#include <godot_cpp/classes/resource.hpp>
#include <godot_cpp/variant/vector3.hpp>
#include <godot_cpp/core/class_db.hpp>

using namespace godot;

class GUIDETrigger : public Resource {
    GDCLASS(GUIDETrigger, Resource)

public:
    enum GUIDETriggerState {
        NONE,
        ONGOING,
        TRIGGERED
    };

    enum GUIDETriggerType {
        EXPLICIT = 1,
        IMPLICIT = 2,
        BLOCKING = 3
    };

    GUIDETrigger();
    virtual ~GUIDETrigger();

    virtual bool is_same_as(const Ref<GUIDETrigger> &other) const;
    virtual GUIDETriggerType _get_trigger_type() const;
    virtual GUIDETriggerState _update_state(Vector3 input, double delta, int value_type);
    
    bool _is_actuated(Vector3 input, int value_type) const;
    bool _is_axis1d_actuated(Vector3 input) const;
    bool _is_axis2d_actuated(Vector3 input) const;
    bool _is_axis3d_actuated(Vector3 input) const;

    virtual String _editor_name() const;
    virtual String _editor_description() const;

    double get_actuation_threshold() const { return actuation_threshold; }
    void set_actuation_threshold(double p_threshold) { actuation_threshold = p_threshold; }

    Vector3 get_last_value() const { return _last_value; }
    void set_last_value(const Vector3 &p_value) { _last_value = p_value; }

protected:
    static void _bind_methods();

    double actuation_threshold = 0.5;
    Vector3 _last_value;
};

VARIANT_ENUM_CAST(GUIDETrigger::GUIDETriggerState);
VARIANT_ENUM_CAST(GUIDETrigger::GUIDETriggerType);

#endif // GUIDE_TRIGGER_H