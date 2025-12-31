
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

class RegisterTriggers {
public:
    static void register_types();
};