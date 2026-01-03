
#include "guide.h"
#include "guide_action.h"
#include "guide_action_mapping.h"
#include "guide_input_mapping.h"
#include "guide_mapping_context.h"
#include "guide_reset.h"
#include "guide_set.h"
#include "guide_input_tracker.h"

using namespace godot;

class RegisterGuide {
public:
    static void register_types();
};