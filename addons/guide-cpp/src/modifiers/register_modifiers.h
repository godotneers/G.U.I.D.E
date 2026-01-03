
#include "modifiers/guide_modifier_3d_coordinates.h"
#include "modifiers/guide_modifier_8_way_direction.h"
#include "modifiers/guide_modifier_canvas_coordinates.h"
#include "modifiers/guide_modifier_curve.h"
#include "modifiers/guide_modifier_deadzone.h"
#include "modifiers/guide_modifier_input_swizzle.h"
#include "modifiers/guide_modifier_magnitude.h"
#include "modifiers/guide_modifier_map_range.h"
#include "modifiers/guide_modifier_negate.h"
#include "modifiers/guide_modifier_normalize.h"
#include "modifiers/guide_modifier_positive_negative.h"
#include "modifiers/guide_modifier_scale.h"
#include "modifiers/guide_modifier_virtual_cursor.h"
#include "modifiers/guide_modifier_window_relative.h"
#include "modifiers/guide_modifier.h"

class RegisterModifiers {
public:
    static void register_types();
};