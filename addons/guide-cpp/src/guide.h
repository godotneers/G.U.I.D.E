#ifndef GUIDE_H
#define GUIDE_H

#include <godot_cpp/classes/node.hpp>
#include <godot_cpp/classes/window.hpp>
#include <godot_cpp/classes/input_event.hpp>
#include <godot_cpp/variant/dictionary.hpp>
#include <godot_cpp/variant/typed_array.hpp>
#include <godot_cpp/core/class_db.hpp>

#include "guide_mapping_context.h"
#include "remapping/guide_remapping_config.h"
#include "inputs/guide_input.h"
#include "guide_reset.h"
#include "guide_set.h"
#include "inputs/guide_input_state.h"

using namespace godot;

class GUIDE : public Node {
    GDCLASS(GUIDE, Node)

public:
    static GUIDE* get_singleton();

    GUIDE();
    virtual ~GUIDE();

    void _deferred_instrument_setup();

    void _ready() override;
    void _physics_process(double delta) override;
    void _process(double delta) override;

    void inject_input(const Ref<InputEvent> &event);
    void set_remapping_config(const Ref<GUIDERemappingConfig> &config);
    void enable_mapping_context(const Ref<GUIDEMappingContext> &context, bool disable_others = false, int priority = 0);
    void disable_mapping_context(const Ref<GUIDEMappingContext> &context);
    bool is_mapping_context_enabled(const Ref<GUIDEMappingContext> &context) const;
    TypedArray<GUIDEMappingContext> get_enabled_mapping_contexts() const;

    void _update_caches();
    void _update_caches_on_joy(int p_id, bool p_connected) { _update_caches(); }
    static bool _is_same_action_mapping(const Ref<GUIDEActionMapping> &a, const Ref<GUIDEActionMapping> &b);

    static void _mark_used(Object *p_object, bool p_value);
    static bool _is_used(const Object *p_object);
    static void _copy_meta(const Object *p_source, Object *p_target);

    GUIDEInputState* get_input_state() const { return _input_state; }
    void set_input_state(GUIDEInputState* p_state) { _input_state = p_state;}

    // Internal access for debugger etc.
    Array get_active_action_mappings() const { return _active_action_mappings; };
    Ref<GUIDESet> get_active_inputs() const { return _active_inputs; };
    Dictionary get_actions_sharing_input() const { return _actions_sharing_input; };

    Dictionary get_active_contexts() const { return _active_contexts; };
    void set_active_contexts(const Dictionary &p_contexts) { _active_contexts = p_contexts; };

protected:
    static void _bind_methods();

private:
    static GUIDE *singleton;

    Dictionary _active_contexts; // GUIDEMappingContext -> priority
    TypedArray<GUIDEActionMapping> _active_action_mappings;
    Ref<GUIDERemappingConfig> _active_remapping_config;
    Ref<GUIDESet> _active_inputs; // GUIDEInput -> GUIDEInput (set)
    Ref<GUIDESet> _active_modifiers; // GUIDEModifier -> GUIDEModifier (set)
    Dictionary _actions_sharing_input; // GUIDEAction -> Array[GUIDEAction]

    GUIDEReset *_reset_node = nullptr;
    GUIDEInputState *_input_state = nullptr;
    bool _locked = false;

    void _on_node_added(Node *node);
};

#endif // GUIDE_H