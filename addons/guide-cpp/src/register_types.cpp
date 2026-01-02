#include "register_types.h"

#include <gdextension_interface.h>
#include <godot_cpp/core/defs.hpp>
#include <godot_cpp/godot.hpp>

#include "register_guide.h"
#include "inputs/register_inputs.h"
#include "modifiers/register_modifiers.h"
#include "remapping/register_remapping.h" 
#include "triggers/register_triggers.h"
#include "editor/register_editor.h"
#include "ui/register_ui.h"
#include "ui/virtual_joy/register_virtual_joy.h"

using namespace godot;

void initialize_libguide_module(ModuleInitializationLevel p_level) {
    if (p_level != MODULE_INITIALIZATION_LEVEL_SCENE) {
        return;
    }

    RegisterGuide::register_types();
    RegisterEditor::register_types();
    RegisterInputs::register_types();
    RegisterModifiers::register_types();
    RegisterTriggers::register_types();
    RegisterRemapping::register_types();
    RegisterUI::register_types();
    RegisterVirtualJoy::register_types();
}

void uninitialize_libguide_module(ModuleInitializationLevel p_level) {
    if (p_level != MODULE_INITIALIZATION_LEVEL_SCENE) {
        return;
    }
}

extern "C" {
GDExtensionBool GDE_EXPORT libguide_init(GDExtensionInterfaceGetProcAddress p_get_proc_address, const GDExtensionClassLibraryPtr p_library, GDExtensionInitialization *r_initialization) {
    godot::GDExtensionBinding::InitObject init_obj(p_get_proc_address, p_library, r_initialization);

    init_obj.register_initializer(initialize_libguide_module);
    init_obj.register_terminator(uninitialize_libguide_module);
    init_obj.set_minimum_library_initialization_level(MODULE_INITIALIZATION_LEVEL_SCENE);

    return init_obj.init();
}
}
