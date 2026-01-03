#include "guide.h"
#include "guide_set.h"  
#include "guide_input_tracker.h"
#include <godot_cpp/classes/engine.hpp>
#include <godot_cpp/classes/input.hpp>
#include <godot_cpp/classes/scene_tree.hpp>
#include <godot_cpp/classes/viewport.hpp>
#include <godot_cpp/variant/utility_functions.hpp>
#include <godot_cpp/core/math.hpp>
#include "triggers/guide_trigger_chorded_action.h"
#include "modifiers/guide_modifier.h"
#include <algorithm>
#include <vector>

using namespace godot;

GUIDECpp *GUIDECpp::singleton = nullptr;

GUIDECpp* GUIDECpp::get_singleton() {
    return singleton;
}

void GUIDECpp::_bind_methods() {
    ClassDB::bind_method(D_METHOD("inject_input", "event"), &GUIDECpp::inject_input);
    ClassDB::bind_method(D_METHOD("set_remapping_config", "config"), &GUIDECpp::set_remapping_config);
    ClassDB::bind_method(D_METHOD("enable_mapping_context", "context", "disable_others", "priority"), &GUIDECpp::enable_mapping_context, DEFVAL(false), DEFVAL(0));
    ClassDB::bind_method(D_METHOD("disable_mapping_context", "context"), &GUIDECpp::disable_mapping_context);
    ClassDB::bind_method(D_METHOD("is_mapping_context_enabled", "context"), &GUIDECpp::is_mapping_context_enabled);
    ClassDB::bind_method(D_METHOD("get_enabled_mapping_contexts"), &GUIDECpp::get_enabled_mapping_contexts);
    
    ClassDB::bind_method(D_METHOD("get_active_action_mappings"), &GUIDECpp::get_active_action_mappings);
    ClassDB::bind_method(D_METHOD("get_active_inputs"), &GUIDECpp::get_active_inputs);
    ClassDB::bind_method(D_METHOD("get_actions_sharing_input"), &GUIDECpp::get_actions_sharing_input);

    ClassDB::bind_method(D_METHOD("get_active_contexts"), &GUIDECpp::get_active_contexts);
    ClassDB::bind_method(D_METHOD("set_active_contexts", "contexts"), &GUIDECpp::set_active_contexts);
    ADD_PROPERTY(PropertyInfo(Variant::DICTIONARY, "_active_contexts"), "set_active_contexts", "get_active_contexts");

    ClassDB::bind_method(D_METHOD("get_input_state"), &GUIDECpp::get_input_state);
    ClassDB::bind_method(D_METHOD("set_input_state", "state"), &GUIDECpp::set_input_state);
    ADD_PROPERTY(PropertyInfo(Variant::OBJECT, "input_state", PROPERTY_HINT_NONE, "GUIDEInputState"), "set_input_state", "get_input_state");


    ADD_SIGNAL(MethodInfo("input_mappings_changed"));
}

GUIDECpp::GUIDECpp() {
    if (singleton == nullptr) {
        singleton = this;
    }
    _active_inputs.instantiate();
    _active_modifiers.instantiate();
}

GUIDECpp::~GUIDECpp() {
    if (singleton == this) {
        singleton = nullptr;
    }
}

void GUIDECpp::_ready() {
    set_process_mode(PROCESS_MODE_ALWAYS);
    _reset_node = memnew(GUIDEReset);
    _input_state = memnew(GUIDEInputState);
    _input_state->_reset();
    add_child(_reset_node);

    // attach to the current viewport to get input events
    GUIDEInputTracker::_instrument(get_viewport());
    
    get_tree()->connect("node_added", Callable(this, "_on_node_added"));
    Input::get_singleton()->connect("joy_connection_changed", Callable(this, "_update_caches_on_joy"));
}

void GUIDECpp::_on_node_added(Node *node) {
    Window *window = Object::cast_to<Window>(node);
    if (window) {
        GUIDEInputTracker::_instrument(window);
    }
}

void GUIDECpp::inject_input(const Ref<InputEvent> &event) {
    if (event->is_class("InputEventAction")) {
        return;
    }
    _input_state->_input(event);
}

void GUIDECpp::set_remapping_config(const Ref<GUIDERemappingConfig> &config) {
    _active_remapping_config = config;
    _update_caches();
}

void GUIDECpp::enable_mapping_context(const Ref<GUIDEMappingContext> &context, bool disable_others, int priority) {
    if (context.is_null()) {
        UtilityFunctions::push_error("Null context given. Ignoring.");
        return;
    }
    if (disable_others) {
        _active_contexts.clear();
    }
    _active_contexts[context] = priority;
    _update_caches();
    context->emit_signal("enabled");
}

void GUIDECpp::disable_mapping_context(const Ref<GUIDEMappingContext> &context) {
    if (context.is_null()){ 
        UtilityFunctions::push_error("Null context given. Ignoring.");
        return;
    }
    _active_contexts.erase(context);
    _update_caches();
    context->emit_signal("disabled");
}

bool GUIDECpp::is_mapping_context_enabled(const Ref<GUIDEMappingContext> &context) const {
    return _active_contexts.has(context);
}

TypedArray<GUIDEMappingContext> GUIDECpp::get_enabled_mapping_contexts() const {
    TypedArray<GUIDEMappingContext> result;
    Array keys = _active_contexts.keys();
    for (int i = 0; i < keys.size(); i++) {
        result.append(keys[i]);
    }
    return result;
}

void GUIDECpp::_physics_process(double delta) {
    Array modifiers = _active_modifiers->values();
    for (int i = 0; i < modifiers.size(); i++) {
        Ref<GUIDEModifier> modifier = modifiers[i];
        if (modifier.is_valid()) {
            modifier->_physics_process(delta);
        }
    }
}

void GUIDECpp::_process(double delta) {
    Ref<GUIDESet> blocked_actions;
    blocked_actions.instantiate();
    
    for (int i = 0; i < _active_action_mappings.size(); i++) {
        Ref<GUIDEActionMapping> action_mapping = _active_action_mappings[i];
        Ref<GUIDEAction> action = action_mapping->get_action();
        
        Vector3 consolidated_value = Vector3(0, 0, 0);
        int consolidated_trigger_state = GUIDETrigger::NONE;
        
        TypedArray<GUIDEInputMapping> input_mappings = action_mapping->get_input_mappings();
        
        for (int j = 0; j < input_mappings.size(); j++) {
            Ref<GUIDEInputMapping> input_mapping = input_mappings[j];

            input_mapping->_update_state(delta, action->get_action_value_type());
            consolidated_value += input_mapping->get_value();
            consolidated_trigger_state = Math::max(consolidated_trigger_state, (int)input_mapping->get_state());
        }

        if (blocked_actions->has(action)) {
            consolidated_trigger_state = GUIDETrigger::NONE;
        }

        if (action->get_block_lower_priority_actions() && consolidated_trigger_state == GUIDETrigger::TRIGGERED && _actions_sharing_input.has(action)) {
            Array sharing = _actions_sharing_input[action];
            for (int j = 0; j < sharing.size(); j++) {
                blocked_actions->add(sharing[j]);
            }
        }

        switch (action->get_last_state()) {
            case GUIDEAction::TRIGGERED:
                if (consolidated_trigger_state == GUIDETrigger::NONE) action->_completed(consolidated_value);
                else if (consolidated_trigger_state == GUIDEAction::ONGOING) action->_ongoing(consolidated_value, delta);
                else if (consolidated_trigger_state == GUIDETrigger::TRIGGERED) action->_triggered(consolidated_value, delta);
                break;
            case GUIDEAction::ONGOING:
                if (consolidated_trigger_state == GUIDETrigger::NONE) action->_cancelled(consolidated_value);
                else if (consolidated_trigger_state == GUIDEAction::ONGOING) action->_ongoing(consolidated_value, delta);
                else if (consolidated_trigger_state == GUIDETrigger::TRIGGERED) action->_triggered(consolidated_value, delta);
                break;
            case GUIDEAction::COMPLETED:
                if (consolidated_trigger_state == GUIDETrigger::NONE) action->_update_value(consolidated_value);
                else if (consolidated_trigger_state == GUIDEAction::ONGOING) action->_started(consolidated_value);
                else if (consolidated_trigger_state == GUIDETrigger::TRIGGERED) action->_triggered(consolidated_value, delta);
                break;
        }
    }
}

struct ContextPriority {
    Ref<GUIDEMappingContext> context;
    int priority;
    bool operator<(const ContextPriority &other) const {
        return priority < other.priority;
    }
};

void GUIDECpp::_update_caches() {
    if (_locked) {
        UtilityFunctions::push_error("Mapping context changed again while processing a change. Ignoring to avoid endless loop.");
        return;
    }
    _locked = true;

    Array context_keys = _active_contexts.keys();
    std::vector<ContextPriority> sorted_contexts;
    for (int i = 0; i < context_keys.size(); i++) {
        Ref<GUIDEMappingContext> ctx = context_keys[i];
        sorted_contexts.push_back({ctx, (int)_active_contexts[ctx]});
    }
    std::sort(sorted_contexts.begin(), sorted_contexts.end());

    Ref<GUIDESet> processed_actions; processed_actions.instantiate();
    Ref<GUIDESet> new_inputs; new_inputs.instantiate();
    TypedArray<GUIDEActionMapping> new_action_mappings;
    Ref<GUIDESet> new_modifiers; new_modifiers.instantiate();

    // Step 0: walk over the new contexts and save over all inputs and modifiers that we
    // are going to keep.
    for (const auto &cp : sorted_contexts) {
        TypedArray<GUIDEActionMapping> mappings = cp.context->get_mappings();
        for (int i = 0; i < mappings.size(); i++) {
            Ref<GUIDEActionMapping> action_mapping = mappings[i];
            for (int j = 0; j < _active_action_mappings.size(); j++) {
                Ref<GUIDEActionMapping> existing_mapping = _active_action_mappings[j];
                if (_is_same_action_mapping(existing_mapping, action_mapping)) {
                    TypedArray<GUIDEInputMapping> input_mappings = existing_mapping->get_input_mappings();
                    for (int k = 0; k < input_mappings.size(); k++) {
                        Ref<GUIDEInputMapping> input_mapping = input_mappings[k];
                        if (input_mapping->get_input().is_valid()) {
                            new_inputs->add(input_mapping->get_input());
                        }
                        TypedArray<GUIDEModifier> mods = input_mapping->get_modifiers();
                        for (int l = 0; l < mods.size(); l++) {
                            new_modifiers->add(mods[l]);
                        }
                    }
                }
            }
        }
    }

    // Step 1: Collect all action mappings from the currently enabled contexts.
    for (const auto &cp : sorted_contexts) {
        int position = 0;
        TypedArray<GUIDEActionMapping> mappings = cp.context->get_mappings();
        for (int i = 0; i < mappings.size(); i++) {
            position++;
            Ref<GUIDEActionMapping> action_mapping = mappings[i];
            Ref<GUIDEAction> action = action_mapping->get_action();
            
            if (action.is_null()) {
                UtilityFunctions::push_warning("Mapping at position " + String::num(position) + " in context " + cp.context->get_path() + " has no action set. This mapping will be ignored.");
                continue;
            }
            
            if (processed_actions->has(action)) continue;
            processed_actions->add(action);

            bool found_existing = false;
            for (int j = 0; j < _active_action_mappings.size(); j++) {
                if (_is_same_action_mapping(_active_action_mappings[j], action_mapping)) {
                    new_action_mappings.append(_active_action_mappings[j]);
                    found_existing = true;
                    break;
                }
            }
            if (found_existing) continue;

            Ref<GUIDEActionMapping> effective_mapping;
            effective_mapping.instantiate();
            effective_mapping->set_action(action);
            _copy_meta(action_mapping.ptr(), effective_mapping.ptr());

            double trigger_hold_threshold = -1.0;
            TypedArray<GUIDEInputMapping> input_mappings = action_mapping->get_input_mappings();
            TypedArray<GUIDEInputMapping> effective_input_mappings;

            for (int j = 0; j < input_mappings.size(); j++) {
                Ref<GUIDEInputMapping> im = input_mappings[j];
                Ref<GUIDEInput> bound_input = im->get_input();

                if (_active_remapping_config.is_valid() 
                    && _active_remapping_config->_has(cp.context, action, j)
                ) {
                    bound_input = _active_remapping_config->_get_bound_input_or_null(cp.context, action, j);
                }

                Ref<GUIDEInputMapping> new_im;
                new_im.instantiate();

                if (bound_input.is_valid()) {
                    Ref<GUIDEInput> existing;
                    Array active_vals = _active_inputs->values();
                    for (int k = 0; k < active_vals.size(); k++) {
                        Ref<GUIDEInput> in = active_vals[k];
                        if (in->is_same_as(bound_input)) { existing = in; break; }
                    }
                    if (existing.is_null()) {
                        Array new_vals = new_inputs->values();
                        for (int k = 0; k < new_vals.size(); k++) {
                            Ref<GUIDEInput> in = new_vals[k];
                            if (in->is_same_as(bound_input)) { existing = in; break; }
                        }
                    }

                    if (existing.is_valid()) bound_input = existing;

                    if (!_is_used(bound_input.ptr())) {
                        bound_input->set_state(_input_state);
                        bound_input->_begin_usage();
                        _mark_used(bound_input.ptr(), true);
                    }
                    new_inputs->add(bound_input);
                }

                new_im->set_input(bound_input);
                new_im->set_display_name(im->get_display_name());
                new_im->set_display_category(im->get_display_category());
                new_im->set_override_action_settings(im->get_override_action_settings());
                new_im->set_is_remappable(im->get_is_remappable());
                _copy_meta(im.ptr(), new_im.ptr());

                new_im->set_modifiers(im->get_modifiers());
                TypedArray<GUIDEModifier> mods = new_im->get_modifiers();
                for (int k = 0; k < mods.size(); k++) {
                    Ref<GUIDEModifier> mod = mods[k];
                    new_modifiers->add(mod);
                    if (!_is_used(mod.ptr())) {
                        mod->_begin_usage();
                        _mark_used(mod.ptr(), true);
                    }
                }

                TypedArray<GUIDETrigger> triggers_copy;
                TypedArray<GUIDETrigger> orig_triggers = im->get_triggers();
                for (int k = 0; k < orig_triggers.size(); k++) {
                    Ref<GUIDETrigger> trig = orig_triggers[k];
                    triggers_copy.append(trig->duplicate());
                }
                new_im->set_triggers(triggers_copy);

                new_im->_initialize(action->get_action_value_type());
                double mapping_hold = new_im->get_trigger_hold_threshold();
                if (trigger_hold_threshold < 0 || 
                    (mapping_hold >= 0 && mapping_hold < trigger_hold_threshold)
                ) { trigger_hold_threshold = mapping_hold; }

                effective_input_mappings.append(new_im);
            }
            effective_mapping->set_input_mappings(effective_input_mappings);
            action->set_trigger_hold_threshold(trigger_hold_threshold);

            if (!effective_input_mappings.is_empty()) {
                new_action_mappings.append(effective_mapping);
            }
        }
    }

    // Cleanup
    Array old_inputs = _active_inputs->values();
    for (int i = 0; i < old_inputs.size(); i++) {
        Ref<GUIDEInput> input = old_inputs[i];
        if (!new_inputs->has(input)) {
            input->_reset();
            input->_end_usage();
            input->set_state(nullptr);
            _mark_used(input.ptr(), false);
        }
    }
    _active_inputs = new_inputs;

    _active_modifiers->clear();
    Array mod_vals = new_modifiers->values();
    for (int i = 0; i < mod_vals.size(); i++) {
        Ref<GUIDEModifier> mod = mod_vals[i];
        if (mod->_needs_physics_process()) {
            _active_modifiers->add(mod);
        }
    }
    set_physics_process(!_active_modifiers->is_empty());

    for (int i = 0; i < _active_action_mappings.size(); i++) {
        Ref<GUIDEActionMapping> mapping = _active_action_mappings[i];
        if (!new_action_mappings.has(mapping)) {
            Ref<GUIDEAction> action = mapping->get_action();
            if (action->get_last_state() == GUIDEAction::ONGOING) action->_cancelled(Vector3(0, 0, 0));
            else if (action->get_last_state() == GUIDEAction::TRIGGERED) action->_completed(Vector3(0, 0, 0));

            TypedArray<GUIDEInputMapping> ims = mapping->get_input_mappings();
            for (int j = 0; j < ims.size(); j++) {
                TypedArray<GUIDEModifier> mods = ((Ref<GUIDEInputMapping>)ims[j])->get_modifiers();
                for (int k = 0; k < mods.size(); k++) {
                    Ref<GUIDEModifier> mod = mods[k];
                    if (!new_modifiers->has(mod)) {
                        mod->_end_usage();
                        _mark_used(mod.ptr(), false);
                    }
                }
            }
        }
    }
    _active_action_mappings = new_action_mappings;

    // Action input sharing logic
    _actions_sharing_input.clear();
    for (int i = 0; i < _active_action_mappings.size(); i++) {
        Ref<GUIDEActionMapping> mapping = _active_action_mappings[i];
        Ref<GUIDEAction> action = mapping->get_action();
        if (action->get_block_lower_priority_actions()) {
            Ref<GUIDESet> chorded_actions; chorded_actions.instantiate();
            Ref<GUIDESet> inputs; inputs.instantiate();
            Ref<GUIDESet> blocked_actions; blocked_actions.instantiate();

            TypedArray<GUIDEInputMapping> ims = mapping->get_input_mappings();
            for (int j = 0; j < ims.size(); j++) {
                Ref<GUIDEInputMapping> im = ims[j];
                if (im->get_input().is_valid()) inputs->add(im->get_input());
                TypedArray<GUIDETrigger> trigs = im->get_triggers();
                for (int k = 0; k < trigs.size(); k++) {
                    Ref<GUIDETriggerChordedAction> chord = trigs[k];
                    if (chord.is_valid() && chord->get_action().is_valid()) {
                        chorded_actions->add(chord->get_action());
                    }
                }
            }

            for (int j = i + 1; j < _active_action_mappings.size(); j++) {
                Ref<GUIDEActionMapping> inner = _active_action_mappings[j];
                if (chorded_actions->has(inner->get_action())) {
                    TypedArray<GUIDEInputMapping> inner_ims = inner->get_input_mappings();
                    for (int k = 0; k < inner_ims.size(); k++) {
                        Ref<GUIDEInputMapping> inner_im = inner_ims[k];
                        if (inner_im->get_input().is_valid()) inputs->add(inner_im->get_input());
                        TypedArray<GUIDETrigger> inner_trigs = inner_im->get_triggers();
                        for (int l = 0; l < inner_trigs.size(); l++) {
                            Ref<GUIDETriggerChordedAction> inner_chord = inner_trigs[l];
                            if (inner_chord.is_valid() && inner_chord->get_action().is_valid()) {
                                chorded_actions->add(inner_chord->get_action());
                            }
                        }
                    }
                }
            }

            for (int j = i + 1; j < _active_action_mappings.size(); j++) {
                Ref<GUIDEActionMapping> inner = _active_action_mappings[j];
                if (chorded_actions->has(inner->get_action())) continue;
                bool shares = false;
                TypedArray<GUIDEInputMapping> inner_ims = inner->get_input_mappings();
                for (int k = 0; k < inner_ims.size(); k++) {
                    Ref<GUIDEInputMapping> inner_im = inner_ims[k];
                    if (inner_im->get_input().is_valid() && inputs->has(inner_im->get_input())) {
                        shares = true;
                        break;
                    }
                }
                if (shares) blocked_actions->add(inner->get_action());
            }
            if (!blocked_actions->is_empty()) _actions_sharing_input[action] = blocked_actions->values();
        }
    }

    _reset_node->_inputs_to_reset.clear();
    Array all_active_inputs = _active_inputs->values();
    for (int i = 0; i < all_active_inputs.size(); i++) {
        Ref<GUIDEInput> in = all_active_inputs[i];
        if (in->_needs_reset()) _reset_node->_inputs_to_reset.append(in);
    }

    _process(0.0);
    _locked = false;
    emit_signal("input_mappings_changed");
}

bool GUIDECpp::_is_same_action_mapping(const Ref<GUIDEActionMapping> &a, const Ref<GUIDEActionMapping> &b) {
    if (a == b) return true;
    if (a->get_action() != b->get_action()) return false;
    TypedArray<GUIDEInputMapping> ims_a = a->get_input_mappings();
    TypedArray<GUIDEInputMapping> ims_b = b->get_input_mappings();
    if (ims_a.size() != ims_b.size()) return false;

    for (int i = 0; i < ims_a.size(); i++) {
        Ref<GUIDEInputMapping> im_a = ims_a[i];
        Ref<GUIDEInputMapping> im_b = ims_b[i];
        if (im_a->get_input().is_valid() && im_b->get_input().is_valid()) {
            if (!im_a->get_input()->is_same_as(im_b->get_input())) return false;
        } else if (im_a->get_input() != im_b->get_input()) return false;

        TypedArray<GUIDEModifier> mods_a = im_a->get_modifiers();
        TypedArray<GUIDEModifier> mods_b = im_b->get_modifiers();
        if (mods_a.size() != mods_b.size()) return false;
        for (int j = 0; j < mods_a.size(); j++) {
            Ref<GUIDEModifier> m_a = mods_a[j];
            Ref<GUIDEModifier> m_b = mods_b[j];
            if (m_a.is_valid() && m_b.is_valid()) {
                if (!m_a->is_same_as(m_b)) return false;
            } else if (m_a != m_b) return false;
        }

        TypedArray<GUIDETrigger> trigs_a = im_a->get_triggers();
        TypedArray<GUIDETrigger> trigs_b = im_b->get_triggers();
        if (trigs_a.size() != trigs_b.size()) return false;
        for (int j = 0; j < trigs_a.size(); j++) {
            Ref<GUIDETrigger> t_a = trigs_a[j];
            Ref<GUIDETrigger> t_b = trigs_b[j];
            if (t_a.is_valid() && t_b.is_valid()) {
                if (!t_a->is_same_as(t_b)) return false;
            } else if (t_a != t_b) return false;
        }
    }
    return true;
}

void GUIDECpp::_mark_used(Object *p_object, bool p_value) {
    if (p_value) {
        p_object->set_meta("__guide_in_use", true);
    } else {
        p_object->remove_meta("__guide_in_use");
    }
}

bool GUIDECpp::_is_used(const Object *p_object) {
    return p_object->has_meta("__guide_in_use");
}

void GUIDECpp::_copy_meta(const Object *p_source, Object *p_target) {
    TypedArray<StringName> keys = p_source->get_meta_list();
    for (int i = 0; i < keys.size(); i++) {
        StringName key = keys[i];
        p_target->set_meta(key, p_source->get_meta(key));
    }
}
