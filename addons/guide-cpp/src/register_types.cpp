#include "register_types.h"

#include "guide.h"
#include "guide_action.h"
#include "guide_action_mapping.h"
#include "guide_input_mapping.h"
#include "guide_mapping_context.h"
#include "guide_reset.h"
#include "guide_set.h"
#include "guide_input_tracker.h"

#include "inputs/guide_input.h"
#include "inputs/guide_input_key.h"
#include "inputs/guide_input_mouse_button.h"
#include "inputs/guide_input_mouse_axis_1d.h"
#include "inputs/guide_input_mouse_axis_2d.h"
#include "inputs/guide_input_mouse_position.h"
#include "inputs/guide_input_joy_base.h"
#include "inputs/guide_input_joy_button.h"
#include "inputs/guide_input_joy_axis_1d.h"
#include "inputs/guide_input_joy_axis_2d.h"
#include "inputs/guide_input_any.h"
#include "inputs/guide_input_action.h"
#include "inputs/guide_input_state.h"
#include "inputs/guide_input_touch_base.h"
#include "inputs/guide_input_touch_position.h"
#include "inputs/guide_input_touch_axis_base.h"
#include "inputs/guide_input_touch_axis_1d.h"
#include "inputs/guide_input_touch_axis_2d.h"
#include "inputs/guide_input_touch_gesture.h"

#include "modifiers/guide_modifier.h"
#include "modifiers/guide_modifier_deadzone.h"
#include "modifiers/guide_modifier_negate.h"
#include "modifiers/guide_modifier_scale.h"
#include "modifiers/guide_modifier_normalize.h"
#include "modifiers/guide_modifier_magnitude.h"
#include "modifiers/guide_modifier_input_swizzle.h"
#include "modifiers/guide_modifier_map_range.h"
#include "modifiers/guide_modifier_positive_negative.h"
#include "modifiers/guide_modifier_coordinates.h"
#include "modifiers/guide_modifier_misc.h"
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
#include "triggers/guide_trigger_combo.h"
#include "triggers/guide_trigger_combo_components.h"

#include "remapping/guide_remapping_config.h"
#include "remapping/guide_remapper.h"
#include "remapping/guide_input_detector.h"

#include "ui/guide_input_formatting_options.h"
#include "ui/guide_formatting_base.h"
#include "ui/guide_input_formatter.h"
#include "ui/guide_formatting_utils.h"
#include "ui/virtual_joy/guide_virtual_joy_base.h"
#include "ui/virtual_joy/virtual_button/guide_virtual_button.h"
#include "ui/virtual_joy/virtual_stick/guide_virtual_stick.h"
#include "ui/virtual_joy/guide_virtual_joy_renderers.h"
#include "ui/virtual_joy/guide_virtual_joy_texture_renderers.h"

#include <gdextension_interface.h>
#include <godot_cpp/core/defs.hpp>
#include <godot_cpp/godot.hpp>

using namespace godot;

void initialize_libguide_module(ModuleInitializationLevel p_level) {
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
    GDREGISTER_CLASS(GUIDEInputKey);
    GDREGISTER_CLASS(GUIDEInputMouseButton);
    GDREGISTER_CLASS(GUIDEInputMouseAxis1D);
    GDREGISTER_CLASS(GUIDEInputMouseAxis2D);
    GDREGISTER_CLASS(GUIDEInputMousePosition);
    GDREGISTER_ABSTRACT_CLASS(GUIDEInputJoyBase);
    GDREGISTER_CLASS(GUIDEInputJoyButton);
    GDREGISTER_CLASS(GUIDEInputJoyAxis1D);
    GDREGISTER_CLASS(GUIDEInputJoyAxis2D);
    GDREGISTER_CLASS(GUIDEInputAny);
    GDREGISTER_CLASS(GUIDEInputAction);
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

    GDREGISTER_CLASS(GUIDERemappingConfig);
    GDREGISTER_CLASS(GUIDERemapper);
    GDREGISTER_CLASS(GUIDERemapperConfigItem);
    GDREGISTER_CLASS(GUIDEInputDetector);

    GDREGISTER_CLASS(GUIDEInputFormattingOptions);
    GDREGISTER_ABSTRACT_CLASS(GUIDETextProvider);
    GDREGISTER_ABSTRACT_CLASS(GUIDEIconRenderer);
    GDREGISTER_CLASS(GUIDEInputFormatter);
    GDREGISTER_CLASS(GUIDEInputFormatter::MaterializedInput);
    GDREGISTER_CLASS(GUIDEInputFormatter::MaterializedSimpleInput);
    GDREGISTER_CLASS(GUIDEInputFormatter::MaterializedCompositeInput);
    GDREGISTER_CLASS(GUIDEFormattingUtils);

    GDREGISTER_ABSTRACT_CLASS(GUIDEVirtualJoyBase);
    GDREGISTER_CLASS(GUIDEVirtualButton);
    GDREGISTER_CLASS(GUIDEVirtualStick);
    GDREGISTER_ABSTRACT_CLASS(GUIDEVirtualButtonRenderer);
    GDREGISTER_ABSTRACT_CLASS(GUIDEVirtualStickRenderer);
    GDREGISTER_CLASS(GUIDEVirtualButtonTextureRenderer);
    GDREGISTER_CLASS(GUIDEVirtualStickTextureRenderer);
}

void uninitialize_libguide_module(ModuleInitializationLevel p_level) {
    if (p_level != MODULE_INITIALIZATION_LEVEL_SCENE) {
        return;
    }
}

extern "C" {
// Initialization.
GDExtensionBool GDE_EXPORT libguide_library_init(GDExtensionInterfaceGetProcAddress p_get_proc_address, const GDExtensionClassLibraryPtr p_library, GDExtensionInitialization *r_initialization) {
    godot::GDExtensionBinding::InitObject init_obj(p_get_proc_address, p_library, r_initialization);

    init_obj.register_initializer(initialize_libguide_module);
    init_obj.register_terminator(uninitialize_libguide_module);
    init_obj.set_minimum_library_initialization_level(MODULE_INITIALIZATION_LEVEL_SCENE);

    return init_obj.init();
}
}
