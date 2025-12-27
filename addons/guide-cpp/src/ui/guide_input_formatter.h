#ifndef GUIDE_INPUT_FORMATTER_H
#define GUIDE_INPUT_FORMATTER_H

#include <godot_cpp/core/class_db.hpp>
#include <godot_cpp/variant/callable.hpp>
#include <godot_cpp/classes/ref_counted.hpp>
#include <vector>
#include "guide_formatting_base.h"
#include "guide_input_formatting_options.h"
#include "../guide_action.h"
#include "../guide_mapping_context.h"

using namespace godot;

class GUIDEInputFormatter : public RefCounted {
    GDCLASS(GUIDEInputFormatter, RefCounted)

public:
    class MaterializedInput : public RefCounted {
        GDCLASS(MaterializedInput, RefCounted)
    protected:
        static void _bind_methods() {}
    };

    class MaterializedSimpleInput : public MaterializedInput {
        GDCLASS(MaterializedSimpleInput, MaterializedInput)
    public:
        Ref<GUIDEInput> input;
    protected:
        static void _bind_methods() {}
    };

    class MaterializedCompositeInput : public MaterializedInput {
        GDCLASS(MaterializedCompositeInput, MaterializedInput)
    public:
        TypedArray<MaterializedInput> parts;
    protected:
        static void _bind_methods() {}
    };

    struct FormattingContext {
        Ref<GUIDEInput> input;
        Ref<GUIDEInputMapping> input_mapping;
        Ref<GUIDEAction> action;
    };

    GUIDEInputFormatter();
    GUIDEInputFormatter(int icon_size, const Callable &resolver);
    virtual ~GUIDEInputFormatter();

    static void add_icon_renderer(GUIDEIconRenderer *renderer);
    static void remove_icon_renderer(GUIDEIconRenderer *renderer);
    static void add_text_provider(GUIDETextProvider *provider);
    static void remove_text_provider(GUIDETextProvider *provider);

    static Ref<GUIDEInputFormatter> for_active_contexts(int icon_size = 32);
    static Ref<GUIDEInputFormatter> for_context(const Ref<GUIDEMappingContext> &context, int icon_size = 32);

    String action_as_text(const Ref<GUIDEAction> &action);
    String input_as_text(const Ref<GUIDEInput> &input, bool materialize_actions = true);

    Ref<GUIDEInputFormattingOptions> get_formatting_options() const { return formatting_options; }

protected:
    static void _bind_methods();

private:
    static std::vector<GUIDEIconRenderer*> icon_renderers;
    static std::vector<GUIDETextProvider*> text_providers;

    int _icon_size = 32;
    Callable _action_resolver;
    Ref<GUIDEInputFormattingOptions> formatting_options;

    Ref<MaterializedInput> _materialize_action_input(const Ref<GUIDEAction> &action);
    Ref<MaterializedInput> _materialize_input(const FormattingContext &context, bool materialize_actions = true);
    String _materialized_as_text(const Ref<MaterializedInput> &input);

    static String mixed_input_separator;
    static String chorded_input_separator;
    static String combo_input_separator;
};

#endif // GUIDE_INPUT_FORMATTER_H