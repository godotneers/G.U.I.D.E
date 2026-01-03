#ifndef GUIDE_INPUT_FORMATTER_H
#define GUIDE_INPUT_FORMATTER_H

#include <godot_cpp/core/class_db.hpp>
#include <godot_cpp/variant/callable.hpp>
#include <godot_cpp/classes/ref_counted.hpp>
#include <godot_cpp/classes/packed_scene.hpp>
#include <godot_cpp/classes/resource_loader.hpp>
#include <godot_cpp/classes/engine.hpp>
#include <godot_cpp/classes/scene_tree.hpp>
#include <godot_cpp/classes/window.hpp>
#include <godot_cpp/variant/utility_functions.hpp>

#include "guide_text_provider.h"
#include "guide_icon_renderer.h"
#include "guide_input_formatting_options.h"
#include "guide_action.h"
#include "guide_mapping_context.h"
#include "guide.h"
#include "inputs/guide_input_action.h"
#include "inputs/guide_input_key.h"
#include "triggers/guide_trigger_combo.h"
#include "triggers/guide_trigger_chorded_action.h"
#include "icon_maker/guide_icon_maker.h"
#include "text_providers/guide_text_provider_default.h"
#include "text_providers/controllers/guide_controller_text_provider.h"

using namespace godot;

// --- Helper classes for materialized input hierarchy ---

class GUIDEMaterializedInput : public RefCounted {
    GDCLASS(GUIDEMaterializedInput, RefCounted)
protected:
    static void _bind_methods() {}
};

class GUIDEMaterializedSimpleInput : public GUIDEMaterializedInput {
    GDCLASS(GUIDEMaterializedSimpleInput, GUIDEMaterializedInput)
public:
    Ref<GUIDEInput> input;
    GUIDEMaterializedSimpleInput() {}
    GUIDEMaterializedSimpleInput(const Ref<GUIDEInput> &p_input) : input(p_input) {}
protected:
    static void _bind_methods() {}
};

class GUIDEMaterializedCompositeInput : public GUIDEMaterializedInput {
    GDCLASS(GUIDEMaterializedCompositeInput, GUIDEMaterializedInput)
public:
    TypedArray<GUIDEMaterializedInput> parts;
protected:
    static void _bind_methods() {}
};

class GUIDEMaterializedMixedInput : public GUIDEMaterializedCompositeInput {
    GDCLASS(GUIDEMaterializedMixedInput, GUIDEMaterializedCompositeInput)
protected:
    static void _bind_methods() {}
};

class GUIDEMaterializedChordedInput : public GUIDEMaterializedCompositeInput {
    GDCLASS(GUIDEMaterializedChordedInput, GUIDEMaterializedCompositeInput)
protected:
    static void _bind_methods() {}
};

class GUIDEMaterializedComboInput : public GUIDEMaterializedCompositeInput {
    GDCLASS(GUIDEMaterializedComboInput, GUIDEMaterializedCompositeInput)
protected:
    static void _bind_methods() {}
};

// --- Formatting Context ---

class GUIDEFormattingContext : public RefCounted {
    GDCLASS(GUIDEFormattingContext, RefCounted)
public:
    Ref<GUIDEInput> input;
    Ref<GUIDEInputMapping> input_mapping;
    Ref<GUIDEAction> action;

    static Ref<GUIDEFormattingContext> for_input(const Ref<GUIDEInput> &p_input) {
        Ref<GUIDEFormattingContext> res; res.instantiate();
        res->input = p_input;
        return res;
    }

    static Ref<GUIDEFormattingContext> for_action(const Ref<GUIDEInput> &p_input, const Ref<GUIDEInputMapping> &p_mapping, const Ref<GUIDEAction> &p_action) {
        Ref<GUIDEFormattingContext> res; res.instantiate();
        res->input = p_input;
        res->input_mapping = p_mapping;
        res->action = p_action;
        return res;
    }
protected:
    static void _bind_methods() {
        ClassDB::bind_static_method("GUIDEFormattingContext", D_METHOD("for_input", "input"), &GUIDEFormattingContext::for_input);
        ClassDB::bind_static_method("GUIDEFormattingContext", D_METHOD("for_action", "input", "input_mapping", "action"), &GUIDEFormattingContext::for_action);
    }
};


// --- Main Formatter Class ---

class GUIDEInputFormatter : public RefCounted {
    GDCLASS(GUIDEInputFormatter, RefCounted)

public:
    GUIDEInputFormatter() {
        formatting_options.instantiate();
    }

    GUIDEInputFormatter(int icon_size, const Callable &resolver) : _icon_size(icon_size), _action_resolver(resolver) {
        formatting_options.instantiate();
    }

    void _init(int p_icon_size, const Callable &p_resolver) {
        _icon_size = p_icon_size;
        _action_resolver = p_resolver;
    }

    virtual ~GUIDEInputFormatter() {}

    static void _ensure_readiness() {
        if (_is_ready) return;

        SceneTree *tree = Object::cast_to<SceneTree>(Engine::get_singleton()->get_main_loop());
        if (tree == nullptr) return;

        Window *root = tree->get_root();
        for (int i = 0; i < root->get_child_count(); i++) {
            if (auto maker = Object::cast_to<GUIDEIconMaker>(root->get_child(i))) {
                _icon_maker = maker;
            }
        }

        if (_icon_maker == nullptr) {
            String path = "res://addons/guide-cpp/plugin/ui/icon_maker/icon_maker.tscn";
            Ref<PackedScene> maker_scene = ResourceLoader::get_singleton()->load(path);

            if (maker_scene.is_valid()) {
                Node *inst = maker_scene->instantiate();
                _icon_maker = Object::cast_to<GUIDEIconMaker>(inst);

                if (_icon_maker) {
                    // Critical: Add to tree so _ready() runs and finds %SubViewport
                    root->add_child(_icon_maker); 
                } else {
                    UtilityFunctions::push_error("GUIDE: Failed to cast instantiated scene to GUIDEIconMaker.");
                    memdelete(inst); // Cleanup if cast failed
                }
            } else {
                UtilityFunctions::push_error("GUIDE: Could not load Icon Maker scene at: " + path);
            }
        }

        auto load_renderer = [](const String &path) {
            Ref<PackedScene> scene = ResourceLoader::get_singleton()->load(path);
            if (scene.is_valid()) add_icon_renderer(Object::cast_to<GUIDEIconRenderer>(scene->instantiate()));
        };

        load_renderer("res://addons/guide-cpp/plugin/ui/renderers/keyboard/guide_key_renderer.tscn");
        load_renderer("res://addons/guide-cpp/plugin/ui/renderers/mouse/guide_mouse_renderer.tscn");
        load_renderer("res://addons/guide-cpp/plugin/ui/renderers/touch/guide_touch_renderer.tscn");
        load_renderer("res://addons/guide-cpp/plugin/ui/renderers/misc/guide_action_renderer.tscn");
        load_renderer("res://addons/guide-cpp/plugin/ui/renderers/joy/guide_joy_renderer.tscn");
        load_renderer("res://addons/guide-cpp/plugin/ui/renderers/controllers/guide_controller_renderer.tscn");
        load_renderer("res://addons/guide-cpp/plugin/ui/renderers/misc/guide_fallback_renderer.tscn");

        Ref<GUIDETextProviderDefault> default_tp; default_tp.instantiate();
        add_text_provider(default_tp.ptr());

        Ref<GUIDEControllerTextProvider> controller_tp; controller_tp.instantiate();
        add_text_provider(controller_tp.ptr());

        _is_ready = true;
    }

    static void cleanup() {
        _is_ready = false;
        for (int i = 0; i < get_icon_renderers().size(); i++) {
            GUIDEIconRenderer* renderer = Object::cast_to<GUIDEIconRenderer>(get_icon_renderers()[i]);
            if (renderer) renderer->queue_free();
        }
        get_icon_renderers().clear();
        get_text_providers().clear();
        if (_icon_maker != nullptr) {
            _icon_maker->queue_free();
            _icon_maker = nullptr;
        }
    }

    static void add_icon_renderer(GUIDEIconRenderer *renderer) {
        if (renderer == nullptr) return;
        get_icon_renderers().append(renderer);
        // Sort by priority (low number = high priority)
        for (int i = 0; i < get_icon_renderers().size(); i++) {
            for (int j = i + 1; j < get_icon_renderers().size(); j++) {
                GUIDEIconRenderer *a = Object::cast_to<GUIDEIconRenderer>(get_icon_renderers()[i]);
                GUIDEIconRenderer *b = Object::cast_to<GUIDEIconRenderer>(get_icon_renderers()[j]);
                if (a->get_priority() > b->get_priority()) {
                    get_icon_renderers()[i] = b;
                    get_icon_renderers()[j] = a;
                }
            }
        }
    }

    static void remove_icon_renderer(GUIDEIconRenderer *renderer) {
        int idx = get_icon_renderers().find(renderer);
        if (idx != -1) get_icon_renderers().remove_at(idx);
    }

    static void add_text_provider(GUIDETextProvider *provider) {
        if (provider == nullptr) return;
        get_text_providers().append(provider);
        for (int i = 0; i < get_text_providers().size(); i++) {
            for (int j = i + 1; j < get_text_providers().size(); j++) {
                Ref<GUIDETextProvider> a = get_text_providers()[i];
                Ref<GUIDETextProvider> b = get_text_providers()[j];
                if (a->get_priority() > b->get_priority()) {
                    get_text_providers()[i] = b;
                    get_text_providers()[j] = a;
                }
            }
        }
    }

    static void remove_text_provider(GUIDETextProvider *provider) {
        int idx = get_text_providers().find(provider);
        if (idx != -1) get_text_providers().remove_at(idx);
    }

    static Ref<GUIDEInputFormatter> for_active_contexts(int icon_size = 32) {
        return Ref<GUIDEInputFormatter>(memnew(GUIDEInputFormatter(icon_size, Callable(GUIDECpp::get_singleton(), "get_active_action_mapping_for_action"))));
    }

    static Ref<GUIDEInputFormatter> for_context(const Ref<GUIDEMappingContext> &context, int icon_size = 32) {
        return Ref<GUIDEInputFormatter>(memnew(GUIDEInputFormatter(icon_size, Callable(context.ptr(), "get_action_mapping"))));
    }

    String action_as_text(const Ref<GUIDEAction> &action) {
        return _materialized_as_text(_materialize_action_input(action));
    }

    String input_as_text(const Ref<GUIDEInput> &input, bool materialize_actions = true) {
        return _materialized_as_text(_materialize_input(GUIDEFormattingContext::for_input(input), materialize_actions));
    }

    String action_as_richtext_async(const Ref<GUIDEAction> &action) {
        return _materialized_as_richtext_async(_materialize_action_input(action));
    }

    String input_as_richtext_async(const Ref<GUIDEInput> &input, bool materialize_actions = true) {
        return _materialized_as_richtext_async(_materialize_input(GUIDEFormattingContext::for_input(input), materialize_actions));
    }

    Ref<GUIDEInputFormattingOptions> get_formatting_options() const { return formatting_options; }

protected:
    static void _bind_methods() {
        ClassDB::bind_method(D_METHOD("_init", "icon_size", "action_resolver"), &GUIDEInputFormatter::_init);

        ClassDB::bind_static_method("GUIDEInputFormatter", D_METHOD("add_icon_renderer", "renderer"), &GUIDEInputFormatter::add_icon_renderer);
        ClassDB::bind_static_method("GUIDEInputFormatter", D_METHOD("remove_icon_renderer", "renderer"), &GUIDEInputFormatter::remove_icon_renderer);
        ClassDB::bind_static_method("GUIDEInputFormatter", D_METHOD("add_text_provider", "provider"), &GUIDEInputFormatter::add_text_provider);
        ClassDB::bind_static_method("GUIDEInputFormatter", D_METHOD("remove_text_provider", "provider"), &GUIDEInputFormatter::remove_text_provider);
        ClassDB::bind_static_method("GUIDEInputFormatter", D_METHOD("cleanup"), &GUIDEInputFormatter::cleanup);

        ClassDB::bind_static_method("GUIDEInputFormatter", D_METHOD("for_active_contexts", "icon_size"), &GUIDEInputFormatter::for_active_contexts, DEFVAL(32));
        ClassDB::bind_static_method("GUIDEInputFormatter", D_METHOD("for_context", "context", "icon_size"), &GUIDEInputFormatter::for_context, DEFVAL(32));

        ClassDB::bind_method(D_METHOD("action_as_text", "action"), &GUIDEInputFormatter::action_as_text);
        ClassDB::bind_method(D_METHOD("input_as_text", "input", "materialize_actions"), &GUIDEInputFormatter::input_as_text, DEFVAL(true));
        ClassDB::bind_method(D_METHOD("action_as_richtext_async", "action"), &GUIDEInputFormatter::action_as_richtext_async);
        ClassDB::bind_method(D_METHOD("input_as_richtext_async", "input", "materialize_actions"), &GUIDEInputFormatter::input_as_richtext_async, DEFVAL(true));
        ClassDB::bind_method(D_METHOD("get_formatting_options"), &GUIDEInputFormatter::get_formatting_options);

        ADD_SIGNAL(MethodInfo("formatting_changed"));
    }

private:
    static inline GUIDEIconMaker *_icon_maker = nullptr;
    static TypedArray<GUIDEIconRenderer>& get_icon_renderers() {
        // Created only on the first call, ensuring Godot is ready.
        static TypedArray<GUIDEIconRenderer> _icon_renderers;
        return _icon_renderers;
    }
    static TypedArray<GUIDETextProvider>& get_text_providers() {
        // Created only on the first call.
        static TypedArray<GUIDETextProvider> _text_providers;
        return _text_providers;
    }
    static inline bool _is_ready = false;

    int _icon_size = 32;
    Callable _action_resolver;
    Ref<GUIDEInputFormattingOptions> formatting_options;

    String _materialized_as_text(const Ref<GUIDEMaterializedInput> &input) {
        _ensure_readiness();
        if (input.is_null()) return "";

        if (auto si = Object::cast_to<GUIDEMaterializedSimpleInput>(input.ptr())) {
            for (int i = 0; i < get_text_providers().size(); i++) {
                Ref<GUIDETextProvider> p = get_text_providers()[i];
                if (p->supports(si->input, formatting_options)) {
                    return p->get_text(si->input, formatting_options);
                }
            }
            return "";
        }

        auto comp = Object::cast_to<GUIDEMaterializedCompositeInput>(input.ptr());
        String sep = _separator_for_input(input);
        if (sep == "" || comp->parts.is_empty()) return "";

        PackedStringArray res_parts;
        for (int i = 0; i < comp->parts.size(); i++) {
            String res = _materialized_as_text(comp->parts[i]);
            if (!res.is_empty()) res_parts.append(res);
        }
        return sep.join(res_parts);
    }

    void _trigger_refresh() {
        emit_signal("formatting_changed"); 
    }

    String _materialized_as_richtext_async(const Ref<GUIDEMaterializedInput> &input) {
        _ensure_readiness();

        if (_icon_maker == nullptr) {
            UtilityFunctions::push_warning("GUIDE: Icon Maker is missing. Check .tscn path.");
            return "";
        }
        if (input.is_null()) return "";

        if (auto si = Object::cast_to<GUIDEMaterializedSimpleInput>(input.ptr())) {
            for (int i = 0; i < get_icon_renderers().size(); i++) {
                GUIDEIconRenderer *r = Object::cast_to<GUIDEIconRenderer>(get_icon_renderers()[i]);
                if (r && r->supports(si->input, formatting_options)) {
                    Ref<GUIDEIconMaker::Job> job = _icon_maker->make_icon(si->input, r, _icon_size, formatting_options);

                    if (job.is_valid() && job->result.is_valid()) {
                        return "[img]" + job->result->get_path() + "[/img]";
                    }
                    if (!job->is_connected("done", callable_mp(this, &GUIDEInputFormatter::_trigger_refresh))) {
                        job->connect("done", callable_mp(this, &GUIDEInputFormatter::_trigger_refresh));
                        UtilityFunctions::print("job connection made");
                    }
                    return "";
                }
            }
            UtilityFunctions::push_warning("No renderer found for input ", input);
            return "";
        }

        auto comp = Object::cast_to<GUIDEMaterializedCompositeInput>(input.ptr());
        String sep = _separator_for_input(input);
        if (sep == "" || comp->parts.is_empty()) return "";

        PackedStringArray res_parts;
        for (int i = 0; i < comp->parts.size(); i++) {
            String res = _materialized_as_richtext_async(comp->parts[i]);
            if (!res.is_empty()) res_parts.append(res);
        }
        return sep.join(res_parts);
    }

    String _separator_for_input(const Ref<GUIDEMaterializedInput> &input) {
        if (Object::cast_to<GUIDEMaterializedMixedInput>(input.ptr())) return mixed_input_separator;
        if (Object::cast_to<GUIDEMaterializedComboInput>(input.ptr())) return combo_input_separator;
        if (Object::cast_to<GUIDEMaterializedChordedInput>(input.ptr())) return chorded_input_separator;

        UtilityFunctions::push_error("Unknown materialized input type");
        return "";
    }

    Ref<GUIDEMaterializedInput> _materialize_action_input(const Ref<GUIDEAction> &action) {
        Ref<GUIDEMaterializedMixedInput> result; result.instantiate();
        if (action.is_null()) {
            UtilityFunctions::push_warning("Trying to get inputs for a null action.");
            return result;
        }

        Variant mapping_var = _action_resolver.call(action);
        Ref<GUIDEActionMapping> mapping = mapping_var;
        if (mapping.is_null()) return result;

        TypedArray<GUIDEInputMapping> ims = mapping->get_input_mappings();
        for (int i = 0; i < ims.size(); i++) {
            Ref<GUIDEInputMapping> im = ims[i];
            TypedArray<GUIDEMaterializedInput> chorded_actions;
            TypedArray<GUIDEMaterializedInput> combos;

            TypedArray<GUIDETrigger> triggers = im->get_triggers();
            for (int j = 0; j < triggers.size(); j++) {
                if (auto combo_trigger = Object::cast_to<GUIDETriggerCombo>(triggers[j])) {
                    Ref<GUIDEMaterializedComboInput> combo; 
                    combo.instantiate();

                    TypedArray<GUIDETriggerComboStep> steps = combo_trigger->get_steps();
                    for (int k = 0; k < steps.size(); k++) {
                        Ref<GUIDETriggerComboStep> step = steps[k];
                        combo->parts.append(_materialize_action_input(step->get_action()));
                    }
                    combos.append(combo);
                }
                if (auto chord_trigger = Object::cast_to<GUIDETriggerChordedAction>(triggers[j])) {
                    chorded_actions.append(_materialize_action_input(chord_trigger->get_action()));
                }
            }

            if (!chorded_actions.is_empty()) {
                Ref<GUIDEMaterializedChordedInput> chord; chord.instantiate();
                for (int j = 0; j < chorded_actions.size(); j++) chord->parts.append(chorded_actions[j]);
                for (int j = 0; j < combos.size(); j++) chord->parts.append(combos[j]);
                if (combos.is_empty() && im->get_input().is_valid()) {
                    chord->parts.append(_materialize_input(GUIDEFormattingContext::for_action(im->get_input(), im, action)));
                }
                result->parts.append(chord);
            } else {
                for (int j = 0; j < combos.size(); j++) result->parts.append(combos[j]);
                if (combos.is_empty() && im->get_input().is_valid()) {
                    result->parts.append(_materialize_input(GUIDEFormattingContext::for_action(im->get_input(), im, action)));
                }
            }
        }
        return result;
    }

    Ref<GUIDEMaterializedInput> _materialize_input(const Ref<GUIDEFormattingContext> &context, bool materialize_actions = true) {
        if (context->input.is_null()) {
            UtilityFunctions::push_warning("Trying to materialize a null input.");
            Ref<GUIDEMaterializedMixedInput> res; res.instantiate(); return res;
        }

        if (!formatting_options->get_input_filter().call(context).operator bool()) {
            Ref<GUIDEMaterializedMixedInput> res; res.instantiate(); return res;
        }

        if (auto ia = Object::cast_to<GUIDEInputAction>(context->input.ptr())) {
            if (materialize_actions) return _materialize_action_input(ia->get_action());
            else return Ref<GUIDEMaterializedSimpleInput>(memnew(GUIDEMaterializedSimpleInput(context->input)));
        }

        if (auto ik = Object::cast_to<GUIDEInputKey>(context->input.ptr())) {
            Ref<GUIDEMaterializedChordedInput> chord; chord.instantiate();
            auto add_mod = [&](Key key) {
                Ref<GUIDEInputKey> k; k.instantiate(); k->set_key(key);
                chord->parts.append(Ref<GUIDEMaterializedSimpleInput>(memnew(GUIDEMaterializedSimpleInput(k))));
            };
            if (ik->get_control()) add_mod(KEY_CTRL);
            if (ik->get_alt()) add_mod(KEY_ALT);
            if (ik->get_shift()) add_mod(KEY_SHIFT);
            if (ik->get_meta()) add_mod(KEY_META);

            if (chord->parts.is_empty()) return Ref<GUIDEMaterializedSimpleInput>(memnew(GUIDEMaterializedSimpleInput(context->input)));
            chord->parts.append(Ref<GUIDEMaterializedSimpleInput>(memnew(GUIDEMaterializedSimpleInput(context->input))));
            return chord;
        }

        return Ref<GUIDEMaterializedSimpleInput>(memnew(GUIDEMaterializedSimpleInput(context->input)));
    }

    static constexpr const char* mixed_input_separator = ", ";
    static constexpr const char* chorded_input_separator = " + ";
    static constexpr const char* combo_input_separator = " > ";
};

#endif // GUIDE_INPUT_FORMATTER_H