
#include "modifiers/register_modifiers.h"

void RegisterModifiers::register_types() {
    GDREGISTER_ABSTRACT_CLASS(GUIDEModifier);
    GDREGISTER_CLASS(GUIDEModifier3DCoordinates);
    GDREGISTER_CLASS(GUIDEModifier8WayDirection);
    GDREGISTER_CLASS(GUIDEModifierCanvasCoordinates);
    GDREGISTER_CLASS(GUIDEModifierCurve);
    GDREGISTER_CLASS(GUIDEModifierDeadzone);
    GDREGISTER_CLASS(GUIDEModifierInputSwizzle);
    GDREGISTER_CLASS(GUIDEModifierMagnitude);
    GDREGISTER_CLASS(GUIDEModifierMapRange);
    GDREGISTER_CLASS(GUIDEModifierNegate);
    GDREGISTER_CLASS(GUIDEModifierNormalize);
    GDREGISTER_CLASS(GUIDEModifierPositiveNegative);
    GDREGISTER_CLASS(GUIDEModifierScale);
    GDREGISTER_CLASS(GUIDEModifierVirtualCursor);
    GDREGISTER_CLASS(GUIDEModifierWindowRelative);
}