
#include "ui/virtual_joy/register_virtual_joy.h"

void RegisterVirtualJoy::register_types() {
    
    GDREGISTER_ABSTRACT_CLASS(GUIDEVirtualJoyBase);
    
    GDREGISTER_ABSTRACT_CLASS(GUIDEVirtualButtonRenderer);
    GDREGISTER_CLASS(GUIDEVirtualButtonTextureRenderer);
    GDREGISTER_CLASS(GUIDEVirtualButton);
    
    GDREGISTER_CLASS(GUIDEVirtualStick);
    GDREGISTER_ABSTRACT_CLASS(GUIDEVirtualStickRenderer);
    GDREGISTER_CLASS(GUIDEVirtualStickTextureRenderer);

}