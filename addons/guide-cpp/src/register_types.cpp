#include "register_types.h"

#include <gdextension_interface.h>
#include <godot_cpp/core/defs.hpp>
#include <godot_cpp/godot.hpp>

#include "guide.h"
#include "guide_action.h"
#include "guide_action_mapping.h"
#include "guide_input_mapping.h"
#include "guide_mapping_context.h"
#include "guide_reset.h"
#include "guide_set.h"
#include "guide_input_tracker.h"

#include "inputs/guide_input.h"
#include "inputs/guide_input_action.h"
#include "inputs/guide_input_any.h"
#include "inputs/guide_input_joy_axis_1d.h"
#include "inputs/guide_input_joy_axis_2d.h"
#include "inputs/guide_input_joy_base.h"
#include "inputs/guide_input_joy_button.h"
#include "inputs/guide_input_key.h"
#include "inputs/guide_input_mouse_axis_1d.h"
#include "inputs/guide_input_mouse_axis_2d.h"
#include "inputs/guide_input_mouse_button.h"
#include "inputs/guide_input_mouse_position.h"
#include "inputs/guide_input_state.h"
#include "inputs/guide_input_touch_angle.h"
#include "inputs/guide_input_touch_axis_1d.h"
#include "inputs/guide_input_touch_axis_2d.h"
#include "inputs/guide_input_touch_axis_base.h"
#include "inputs/guide_input_touch_base.h"
#include "inputs/guide_input_touch_distance.h"
#include "inputs/guide_input_touch_position.h"

#include "modifiers/guide_modifier.h"
#include "modifiers/guide_modifier_deadzone.h"
#include "modifiers/guide_modifier_negate.h"
#include "modifiers/guide_modifier_scale.h"
#include "modifiers/guide_modifier_normalize.h"
#include "modifiers/guide_modifier_magnitude.h"
#include "modifiers/guide_modifier_input_swizzle.h"
#include "modifiers/guide_modifier_map_range.h"
#include "modifiers/guide_modifier_positive_negative.h"
#include "modifiers/guide_modifier_3d_coordinates.h"
#include "modifiers/guide_modifier_canvas_coordinates.h"
#include "modifiers/guide_modifier_8_way_direction.h"
#include "modifiers/guide_modifier_window_relative.h"
#include "modifiers/guide_modifier_curve.h"
#include "modifiers/guide_modifier_deadzone.h"
#include "modifiers/guide_modifier_virtual_cursor.h"

#include "triggers/guide_trigger.h"
#include "triggers/guide_trigger_down.h"
#include "triggers/guide_trigger_hold.h"
#include "triggers/guide_trigger_pressed.h"
#include "triggers/guide_trigger_released.h"
#include "triggers/guide_trigger_tap.h"
#include "triggers/guide_trigger_chorded_action.h"
#include "triggers/guide_trigger_pulse.h"
#include "triggers/guide_trigger_stability.h"
#include "triggers/guide_trigger_combo_step.h"
#include "triggers/guide_trigger_combo_cancel_action.h"
#include "triggers/guide_trigger_combo.h"

#include "remapping/guide_remapper.h"
#include "remapping/guide_remapper_config_item.h"
#include "remapping/guide_remapping_config.h"
#include "remapping/guide_input_detector.h"

#include "editor/guide_editor_utils.h"
#include "ui/guide_text_provider.h"
#include "ui/guide_input_formatter.h"
#include "ui/guide_input_formatting_options.h"
#include "ui/guide_formatting_utils.h"
#include "ui/guide_icon_renderer.h"
#include "ui/renderers/controllers/guide_controller_render_style.h"
#include "ui/renderers/controllers/guide_controller_renderer.h"
#include "ui/renderers/joy/guide_joy_render_style.h"
#include "ui/renderers/joy/guide_joy_renderer.h"
#include "ui/renderers/keyboard/guide_key_render_style.h"
#include "ui/renderers/keyboard/guide_key_renderer.h"
#include "ui/renderers/mouse/guide_mouse_render_style.h"
#include "ui/renderers/mouse/guide_mouse_renderer.h"
#include "ui/renderers/touch/guide_touch_render_style.h"
#include "ui/renderers/touch/guide_touch_renderer.h"
#include "ui/renderers/misc/guide_action_renderer.h"
#include "ui/renderers/misc/guide_fallback_renderer.h"

#include "ui/virtual_joy/guide_virtual_joy_base.h"

#include "ui/virtual_joy/virtual_button/guide_virtual_button.h"
#include "ui/virtual_joy/virtual_button/guide_virtual_button_renderer.h"
#include "ui/virtual_joy/virtual_button/texture_renderer/guide_virtual_button_texture_renderer.h"

#include "ui/virtual_joy/virtual_stick/guide_virtual_stick.h"
#include "ui/virtual_joy/virtual_stick/guide_virtual_stick_renderer.h"
#include "ui/virtual_joy/virtual_stick/texture_renderer/guide_virtual_stick_texture_renderer.h"

using namespace godot;

void initialize_guide_module(ModuleInitializationLevel p_level) {
    if (p_level != MODULE_INITIALIZATION_LEVEL_SCENE) {
        return;
    }

    GDREGISTER_CLASS(GUIDE);
    GDREGISTER_CLASS(GUIDEAction);
    GDREGISTER_CLASS(GUIDEActionMapping);
    GDREGISTER_CLASS(GUIDEInputMapping);
    GDREGISTER_CLASS(GUIDEMappingContext);
    GDREGISTER_CLASS(GUIDEReset);
    GDREGISTER_CLASS(GUIDESet);
    GDREGISTER_CLASS(GUIDEInputTracker);

    GDREGISTER_ABSTRACT_CLASS(GUIDEInput);
    GDREGISTER_CLASS(GUIDEInputAction);
    GDREGISTER_CLASS(GUIDEInputAny);
    GDREGISTER_CLASS(GUIDEInputJoyAxis1D);
    GDREGISTER_CLASS(GUIDEInputJoyAxis2D);
    GDREGISTER_ABSTRACT_CLASS(GUIDEInputJoyBase);
    GDREGISTER_CLASS(GUIDEInputJoyButton);
    GDREGISTER_CLASS(GUIDEInputKey);
    GDREGISTER_CLASS(GUIDEInputMouseAxis1D);
    GDREGISTER_CLASS(GUIDEInputMouseAxis2D);
    GDREGISTER_CLASS(GUIDEInputMouseButton);
    GDREGISTER_CLASS(GUIDEInputMousePosition);
    GDREGISTER_CLASS(GUIDEInputState);
    GDREGISTER_ABSTRACT_CLASS(GUIDEInputTouchBase);
    GDREGISTER_CLASS(GUIDEInputTouchPosition);
    GDREGISTER_ABSTRACT_CLASS(GUIDEInputTouchAxisBase);
    GDREGISTER_CLASS(GUIDEInputTouchAxis1D);
    GDREGISTER_CLASS(GUIDEInputTouchAxis2D);
    GDREGISTER_CLASS(GUIDEInputTouchDistance);
    GDREGISTER_CLASS(GUIDEInputTouchAngle);

    GDREGISTER_ABSTRACT_CLASS(GUIDEModifier);
    GDREGISTER_CLASS(GUIDEModifierDeadzone);
    GDREGISTER_CLASS(GUIDEModifierNegate);
    GDREGISTER_CLASS(GUIDEModifierScale);
    GDREGISTER_CLASS(GUIDEModifierNormalize);
    GDREGISTER_CLASS(GUIDEModifierMagnitude);
    GDREGISTER_CLASS(GUIDEModifierInputSwizzle);
    GDREGISTER_CLASS(GUIDEModifierMapRange);
    GDREGISTER_CLASS(GUIDEModifierPositiveNegative);
    GDREGISTER_CLASS(GUIDEModifier3DCoordinates);
    GDREGISTER_CLASS(GUIDEModifierCanvasCoordinates);
    GDREGISTER_CLASS(GUIDEModifier8WayDirection);
    GDREGISTER_CLASS(GUIDEModifierWindowRelative);
    GDREGISTER_CLASS(GUIDEModifierCurve);
    GDREGISTER_CLASS(GUIDEModifierVirtualCursor);

    GDREGISTER_ABSTRACT_CLASS(GUIDETrigger);
    GDREGISTER_CLASS(GUIDETriggerDown);
    GDREGISTER_CLASS(GUIDETriggerHold);
    GDREGISTER_CLASS(GUIDETriggerPressed);
    GDREGISTER_CLASS(GUIDETriggerReleased);
    GDREGISTER_CLASS(GUIDETriggerTap);
    GDREGISTER_CLASS(GUIDETriggerChordedAction);
    GDREGISTER_CLASS(GUIDETriggerPulse);
    GDREGISTER_CLASS(GUIDETriggerStability);
    GDREGISTER_CLASS(GUIDETriggerCombo);
    GDREGISTER_CLASS(GUIDETriggerComboStep);
    GDREGISTER_CLASS(GUIDETriggerComboCancelAction);

    GDREGISTER_CLASS(GUIDERemapper);
    GDREGISTER_CLASS(GUIDERemapperConfigItem);
    GDREGISTER_CLASS(GUIDERemappingConfig);
    GDREGISTER_CLASS(GUIDEInputDetector);

    GDREGISTER_CLASS(GUIDEEditorUtils);

    GDREGISTER_ABSTRACT_CLASS(GUIDETextProvider);
    GDREGISTER_ABSTRACT_CLASS(GUIDEIconRenderer);
    GDREGISTER_CLASS(GUIDEControllerRenderStyle);
    GDREGISTER_CLASS(GUIDEControllerRenderer);
    GDREGISTER_CLASS(GUIDEJoyRenderStyle);
    GDREGISTER_CLASS(GUIDEJoyRenderer);
    GDREGISTER_CLASS(GUIDEKeyRenderStyle);
    GDREGISTER_CLASS(GUIDEKeyRenderer);
    GDREGISTER_CLASS(GUIDEMouseRenderStyle);
    GDREGISTER_CLASS(GUIDEMouseRenderer);
    GDREGISTER_CLASS(GUIDETouchRenderStyle);
    GDREGISTER_CLASS(GUIDETouchRenderer);
    GDREGISTER_CLASS(GUIDEActionRenderer);
    GDREGISTER_CLASS(GUIDEFallbackRenderer);
    GDREGISTER_CLASS(GUIDEInputFormatter);
    GDREGISTER_CLASS(GUIDEInputFormattingOptions);
    GDREGISTER_CLASS(GUIDEFormattingUtils);

    GDREGISTER_ABSTRACT_CLASS(GUIDEVirtualJoyBase);
    GDREGISTER_CLASS(GUIDEVirtualButton);
    GDREGISTER_CLASS(GUIDEVirtualStick);
    GDREGISTER_ABSTRACT_CLASS(GUIDEVirtualButtonRenderer);
    GDREGISTER_ABSTRACT_CLASS(GUIDEVirtualStickRenderer);
    GDREGISTER_CLASS(GUIDEVirtualButtonTextureRenderer);
    GDREGISTER_CLASS(GUIDEVirtualStickTextureRenderer);
}

void uninitialize_guide_module(ModuleInitializationLevel p_level) {
    if (p_level != MODULE_INITIALIZATION_LEVEL_SCENE) {
        return;
    }
}

extern "C" {
GDExtensionBool GDE_EXPORT guide_library_init(GDExtensionInterfaceGetProcAddress p_get_proc_address, const GDExtensionClassLibraryPtr p_library, GDExtensionInitialization *r_initialization) {
    godot::GDExtensionBinding::InitObject init_obj(p_get_proc_address, p_library, r_initialization);

    init_obj.register_initializer(initialize_guide_module);
    init_obj.register_terminator(uninitialize_guide_module);
    init_obj.set_minimum_library_initialization_level(MODULE_INITIALIZATION_LEVEL_SCENE);

    return init_obj.init();
}
}
