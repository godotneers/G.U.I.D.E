
#include "ui/virtual_joy/guide_virtual_joy_base.h"

#include "ui/virtual_joy/virtual_button/guide_virtual_button.h"
#include "ui/virtual_joy/virtual_button/guide_virtual_button_renderer.h"
#include "ui/virtual_joy/virtual_button/texture_renderer/guide_virtual_button_texture_renderer.h"

#include "ui/virtual_joy/virtual_stick/guide_virtual_stick.h"
#include "ui/virtual_joy/virtual_stick/guide_virtual_stick_renderer.h"
#include "ui/virtual_joy/virtual_stick/texture_renderer/guide_virtual_stick_texture_renderer.h"

class RegisterVirtualJoy {
public:
    static void register_types();
};