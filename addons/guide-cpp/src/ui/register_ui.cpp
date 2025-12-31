
#include "ui/register_ui.h"

void RegisterUI::register_types() {
    
    GDREGISTER_CLASS(GUIDEFormattingUtils);
    GDREGISTER_ABSTRACT_CLASS(GUIDEIconRenderer);
    GDREGISTER_CLASS(GUIDEInputFormatter);
    GDREGISTER_CLASS(GUIDEInputFormattingOptions);
    GDREGISTER_ABSTRACT_CLASS(GUIDETextProvider);

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

    GDREGISTER_CLASS(GUIDEIconMaker)

    GDREGISTER_CLASS(GUIDEControllerTextProvider)
    GDREGISTER_CLASS(GUIDEControllerLabelSet)
    GDREGISTER_CLASS(GUIDETextProviderDefault)
}