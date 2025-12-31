
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

class RegisterInputs {
public:
    static void register_types();
};