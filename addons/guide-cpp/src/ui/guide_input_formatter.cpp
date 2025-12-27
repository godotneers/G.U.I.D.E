#include "guide_input_formatter.h"
#include <algorithm>
#include "../guide.h"
#include "../triggers/guide_trigger_combo.h"
#include "../triggers/guide_trigger_chorded_action.h"
#include "../inputs/guide_input_action.h"
#include "../inputs/guide_input_key.h"

using namespace godot;

std::vector<GUIDEIconRenderer*> GUIDEInputFormatter::icon_renderers;
std::vector<GUIDETextProvider*> GUIDEInputFormatter::text_providers;

String GUIDEInputFormatter::mixed_input_separator = ", ";
String GUIDEInputFormatter::chorded_input_separator = " + ";
String GUIDEInputFormatter::combo_input_separator = " > ";

void GUIDEInputFormatter::_bind_methods() {
}

GUIDEInputFormatter::GUIDEInputFormatter() {
    formatting_options.instantiate();
}

GUIDEInputFormatter::GUIDEInputFormatter(int icon_size, const Callable &resolver) : _icon_size(icon_size), _action_resolver(resolver) {
    formatting_options.instantiate();
}

GUIDEInputFormatter::~GUIDEInputFormatter() {}

void GUIDEInputFormatter::add_icon_renderer(GUIDEIconRenderer *renderer) {
    icon_renderers.push_back(renderer);
    std::sort(icon_renderers.begin(), icon_renderers.end(), [](GUIDEIconRenderer *a, GUIDEIconRenderer *b) { return a->get_priority() < b->get_priority(); });
}

void GUIDEInputFormatter::remove_icon_renderer(GUIDEIconRenderer *renderer) {
    auto it = std::find(icon_renderers.begin(), icon_renderers.end(), renderer);
    if (it != icon_renderers.end()) icon_renderers.erase(it);
}

void GUIDEInputFormatter::add_text_provider(GUIDETextProvider *provider) {
    text_providers.push_back(provider);
    std::sort(text_providers.begin(), text_providers.end(), [](GUIDETextProvider *a, GUIDETextProvider *b) { return a->get_priority() < b->get_priority(); });
}

void GUIDEInputFormatter::remove_text_provider(GUIDETextProvider *provider) {
    auto it = std::find(text_providers.begin(), text_providers.end(), provider);
    if (it != text_providers.end()) text_providers.erase(it);
}

String GUIDEInputFormatter::action_as_text(const Ref<GUIDEAction> &action) {
    return _materialized_as_text(_materialize_action_input(action));
}

String GUIDEInputFormatter::input_as_text(const Ref<GUIDEInput> &input, bool materialize_actions) {
    FormattingContext ctx = { input, Ref<GUIDEInputMapping>(), Ref<GUIDEAction>() };
    return _materialized_as_text(_materialize_input(ctx, materialize_actions));
}

Ref<GUIDEInputFormatter::MaterializedInput> GUIDEInputFormatter::_materialize_action_input(const Ref<GUIDEAction> &action) {
    Ref<MaterializedCompositeInput> mixed; mixed.instantiate();
    if (action.is_null()) return mixed;

    Variant mapping_var = _action_resolver.call(action);
    Ref<GUIDEActionMapping> mapping = mapping_var;
    if (mapping.is_null()) return mixed;

    TypedArray<GUIDEInputMapping> ims = mapping->get_input_mappings();
    for (int i = 0; i < ims.size(); i++) {
        Ref<GUIDEInputMapping> im = ims[i];
        // Simplified logic for chord/combo for text purposes
        if (im->get_input().is_valid()) {
            FormattingContext ctx = { im->get_input(), im, action };
            mixed->parts.append(_materialize_input(ctx));
        }
    }
    return mixed;
}

Ref<GUIDEInputFormatter::MaterializedInput> GUIDEInputFormatter::_materialize_input(const FormattingContext &context, bool materialize_actions) {
    if (context.input.is_null()) return Ref<MaterializedInput>();

    if (auto ia = Object::cast_to<GUIDEInputAction>(context.input.ptr())) {
        if (materialize_actions) return _materialize_action_input(ia->get_action());
    }

    if (auto ik = Object::cast_to<GUIDEInputKey>(context.input.ptr())) {
        Ref<MaterializedCompositeInput> chord; chord.instantiate();
        // Simplified modifier detection for text
        if (ik->get_control()) {
            Ref<GUIDEInputKey> ctrl; ctrl.instantiate(); ctrl->set_key(KEY_CTRL);
            Ref<MaterializedSimpleInput> si; si.instantiate(); si->input = ctrl;
            chord->parts.append(si);
        }
        // ... (other modifiers)
        Ref<MaterializedSimpleInput> si; si.instantiate(); si->input = context.input;
        if (chord->parts.is_empty()) return si;
        chord->parts.append(si);
        return chord;
    }

    Ref<MaterializedSimpleInput> res; res.instantiate();
    res->input = context.input;
    return res;
}

String GUIDEInputFormatter::_materialized_as_text(const Ref<MaterializedInput> &input) {
    if (input.is_null()) return "";

    if (auto si = Object::cast_to<MaterializedSimpleInput>(input.ptr())) {
        for (auto p : text_providers) {
            if (p->supports(si->input, formatting_options)) {
                return p->get_text(si->input, formatting_options);
            }
        }
        return "";
    }

    if (auto ci = Object::cast_to<MaterializedCompositeInput>(input.ptr())) {
        String res = "";
        for (int i = 0; i < ci->parts.size(); i++) {
            if (i > 0) res += mixed_input_separator; // Defaulting to mixed for now
            res += _materialized_as_text(ci->parts[i]);
        }
        return res;
    }

    return "";
}

Ref<GUIDEInputFormatter> GUIDEInputFormatter::for_active_contexts(int icon_size) {
    Callable resolver = Callable(GUIDE::get_singleton(), "get_active_action_mapping_for_action"); // Needs proper method in GUIDE
    return Ref<GUIDEInputFormatter>(memnew(GUIDEInputFormatter(icon_size, resolver)));
}

Ref<GUIDEInputFormatter> GUIDEInputFormatter::for_context(const Ref<GUIDEMappingContext> &context, int icon_size) {
    // Simplified for now
    return Ref<GUIDEInputFormatter>(memnew(GUIDEInputFormatter(icon_size, Callable())));
}