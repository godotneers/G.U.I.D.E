---
layout: page
title: Examples
permalink: /reference/examples
description: "Examples that ship with G.U.I.D.E."
no_toc: true
---

# {{ page.title }}

G.U.I.D.E ships with quite a few small example projects that demonstrate how to use the plugin. You can find the examples in the `guide_examples` folder in the plugin's root directory. The following examples are included:

- `2d_axis_mapping` - Shows how to map 2D input from WASD keys to a 2D action so it can move a 2D character.
- `action_priority` - Shows the built-in action priority system. The example shows how to handle actions with overlapping input. In the example players have two spell quickbars bound to the controller D-pad. The first bar can be accessed by hitting the D-pad directly , the second bar can be accessed by holding the left trigger and hitting the D-pad. G.U.I.D.E will prioritize the second bar over the first bar if both are pressed at the same time.
- `combine_contexts` - Shows how to combine multiple mapping contexts that map to the same actions. Both keyboard and controller inputs are enabled simultaneously, allowing seamless input from multiple sources without needing to switch contexts. See also `input_scheme_switching` which shows a different approach where you switch between input schemes instead of combining them.
- `combos` - Shows the built-in combo trigger. Players can double-tap to perform a dash or use a sequence of inputs to perform a special fireball attack.
- `input_contexts` - Shows using multiple mapping contexts at the same time. In the example the player uses one set of action mappings to control a character and switches to another set of action mappings when controlling a boat. This allows to trigger different actions with the same input controls.
- `input_scheme_switching` - Shows how to switch between different input schemes. In the example the player can switch between a keyboard and a controller input scheme while the game is running. See also `combine_contexts` which shows a different approach where both input schemes are active simultaneously instead of switching between them.
- `mouse_position_2d` - Shows the built-in _mouse position_ input in combination with the _canvas coordinates_ modifier to get the mouse position in world space directly from the input system.
- `mouse_position_3d` - Shows the built-in _mouse position_ input in combination with the _3d coordinates_ modifier to get the mouse position in 3D world space directly from the input system. Also shows how to use chorded triggers to rotate the camera with mouse movement while the right mouse button is held.
- `quick_start` - This is the example that is also shown in the [Quick Start Guide]({{ site.baseurl }}/quick-start). It shows how to create a simple 2D character controller with G.U.I.D.E.
- `remapping` - Shows how to use the built-in remapping system to allow players to remap their controls with a dialog.
- `simple_input` - a very barebones example that shows how to create a simple input action and bind it to a key press.
- `tap_and_hold` - Shows the built-in _tap_ and _hold_ trigger. Players can tap a button to jump or hold it to perform a somersault.
- `top_down_shooter` - Shows how to handle input from controller or mouse to rotate a the player in a top-down shooter game. The demo shows two control schemes: one for controller, where the player aims with a stick and one for keyboard & mouse, where the player aims with the mouse and how these two schemes can be supported at the same time with very little code involved.
- `touch` - Shows how to use the touch inputs and triggers to detect screen drags, taps, long-presses, pinch/zoom and rotation gestures with one or multiple fingers.
- `two_joysticks` - Shows how to do local multiplayer with two joysticks. Each player has their own joystick and can move around independently while both players use the same script to handle input.
- `virtual_cursor` - Shows how to control a cursor with a gamepad or keyboard and interact with UI elements using the virtual cursor utilities.
- `virtual_sticks` - Shows on-screen virtual joysticks and buttons for touch devices, including custom renderers and configuration.