
#include "triggers/register_triggers.h"

void RegisterTriggers::register_types() {
    GDREGISTER_ABSTRACT_CLASS(GUIDETrigger);
    GDREGISTER_CLASS(GUIDETriggerChordedAction);
    GDREGISTER_CLASS(GUIDETriggerComboCancelAction);
    GDREGISTER_CLASS(GUIDETriggerComboStep);
    GDREGISTER_CLASS(GUIDETriggerCombo);
    GDREGISTER_CLASS(GUIDETriggerDown);
    GDREGISTER_CLASS(GUIDETriggerHold);
    GDREGISTER_CLASS(GUIDETriggerPressed);
    GDREGISTER_CLASS(GUIDETriggerPulse);
    GDREGISTER_CLASS(GUIDETriggerReleased);
    GDREGISTER_CLASS(GUIDETriggerStability);
    GDREGISTER_CLASS(GUIDETriggerTap);
}