
#include "ui/guide_text_provider.h"
#include "ui/guide_input_formatter.h"
#include "ui/guide_input_formatting_options.h"
#include "ui/guide_formatting_utils.h"
#include "ui/guide_icon_renderer.h"

#include "ui/renderers/controllers/guide_controller_render_style.h"
#include "ui/renderers/controllers/guide_controller_renderer.h"

#include "ui/renderers/joy/guide_joy_render_style.h"
#include "ui/renderers/joy/guide_joy_renderer.h"

#include "ui/renderers/keyboard/guide_key_render_style.h"
#include "ui/renderers/keyboard/guide_key_renderer.h"

#include "ui/renderers/mouse/guide_mouse_render_style.h"
#include "ui/renderers/mouse/guide_mouse_renderer.h"

#include "ui/renderers/touch/guide_touch_render_style.h"
#include "ui/renderers/touch/guide_touch_renderer.h"

#include "ui/renderers/misc/guide_action_renderer.h"
#include "ui/renderers/misc/guide_fallback_renderer.h"

#include "ui/icon_maker/guide_icon_maker.h"

class RegisterUI {
public:
    static void register_types();
};