---
layout: page
title: Modifier Reference
permalink: /reference/modifiers
description: "A reference for all built-in modifiers."
---

## Introduction

G.U.I.D.E ships with a selection of modifiers for many use cases. This is a list of all built-in modifiers and their
configuration settings:

## 3D Coordinates

This modifier converts a 2D mouse position (from the _Mouse Position_ input) into 3D world coordinates. It does this by
performing a raycast into the game world using the currently active 3D camera. Use this to find out "where in my 3D
world did the player just click". It has the following settings:

| Setting              | Description                                                                                                                       |
|----------------------|-----------------------------------------------------------------------------------------------------------------------------------|
| _Max Depth_          | The maximum depth for the ray cast in units.                                                                                      |
| _Collide with areas_ | Whether the raycast should collide with areas.                                                                                    |
| _Collision mask_     | A mask used for the ray cast. This should be set up so the collision layers that make up your "world" are selected for collision. |

The modifier sets the action value to the 3D world position of the raycast hit. If the raycast hits nothing, the
modifier sets the action value to `Vector3.INF`.

## 8-way direction

This is a filtering modifier that checks whether 2D input points into one of 8 directions. If the input points into this
direction, sets the action value to `(1,0,0)` otherwise to `(0,0,0)`. Can be used to get discrete directions from analog
input. It has the following setings:

| Setting     | Description                                         |
|-------------|-----------------------------------------------------|
| _Direction_ | The direction for which the modifier should filter. |

## Canvas coordinates

This modifier converts a 2D pixel coordinate (from the _Mouse Position_, _Touch Position_ or _Touch Axis_ inputs) into
2D world coordinates (canvas coordinates) for the currently active viewport. This modifier takes into account the
current scaling mode and any changes (zoom, offset) applied by a Camera2D in the currently active viewport. Use this to
quickly find out "where in my 2D world did the player just click". This modifier has the following settings:

| Setting          | Description                                |
|------------------|--------------------------------------------|
| _Relative Input_ | Whether the input is absolute or relative. |

## Curve

This modifier applies a separate curve to each input axis. Input values are assumed to fall in the range of `0` to `1`.
You can use the _Map Range_ modifier to convert your value into this range, if needed. It has the following settings:

| Setting | Description                      |
|---------|----------------------------------|
| _Curve_ | The curve to apply.              |
| _X_     | Apply the modifier to the X axis |
| _Y_     | Apply the modifier to the Y axis |
| _Z_     | Apply the modifier to the Z axis |

## Deadzone

This modifier applies a deadzone to 1D, 2D or 3D axis input. You can specify a minimum and maximum value. Every input
outside the minimum and maximum will be clamped while all the values between the minimum and maximum will be scaled to a
range between 0 and 1. This modifier has the following settings:

| Setting           | Description                                                                         |
|-------------------|-------------------------------------------------------------------------------------|
| _Lower threshold_ | The lower threshold for the input. All values below this value will be mapped to 0. |
| _Upper threshold_ | The upper threshold for the input. All values above this value will be mapped to 1. |

## Input swizzle

This modifier rearranges the x,y and z components of the current input value. This is useful if you want to bind keys to
multiple axes or otherwise want to modify the input vector to do any operations on it. This modifier is often combined
with the _Negate_ modifier. It has the following settings:

| Setting | Description                        |
|---------|------------------------------------|
| _Order_ | The new order of the input vector. |

## Magnitude

This modifier outputs the magnitude (length) of the current input vector. The result is a 1D value provided on the `x`-axis; the `y` and `z` components are set to `0`. It has no settings.

## Map Range

This modifier maps the input value through an input and output range and optionally clamps the output. Can be used to
scale and translate at the same time.  (For example, mapping a `0` to `1` range to a `-1` to `1` range.) It has the
following settings:

| Setting       | Description                                               |
|---------------|-----------------------------------------------------------|
| _Apply clamp_ | Whether the output should be clamped to the output range. |
| _Input min_   | The input minimum.                                        |
| _Input max_   | The input maximum.                                        |
| _Output min_  | The output minimum.                                       |
| _Output max_  | The output maximum.                                       |
| _X_           | Apply the modifier to the X axis                          |
| _Y_           | Apply the modifier to the Y axis                          |
| _Z_           | Apply the modifier to the Z axis                          |

## Negate

This modifier negates one or more axes of the input vector. Useful to map key inputs to negative values or to realize
inverted controls for joysticks. It has the following settings:

| Setting | Description                                          |
|---------|------------------------------------------------------|
| _X_     | Whether the `x`-axis of the input should be negated. |
| _Y_     | Whether the `y`-axis of the input should be negated. |
| _Z_     | Whether the `z`-axis of the input should be negated. |

## Normalize

This modifier normalizes the input vector (e.g. keeps the direction but changes the length to 1). It has no settings.

## Positive/Negative

Limits inputs to positive or negative values. Values which do not match will be clamped to zero. Useful if you want to
bind different halves of an axis to different actions. This modifier has the following settings:

| Setting | Description                                                             |
|---------|-------------------------------------------------------------------------|
| _Range_ | Whether the the input should be limited to positive or negative values. |
| _X_     | Whether the `x`-axis of the input should be affected.                   |
| _Y_     | Whether the `y`-axis of the input should be affected.                   |
| _Z_     | Whether the `z`-axis of the input should be affected.                   |

## Scale

Multiplies the input with the given Vector3. Useful to control things like input sensitivity or to convert input into a
more useful range (e.g. radians from 0-1). Input can also be multiplied with delta time (to limit input over time). The
modifier has the following settings:

| Setting            | Description                                                                   |
|--------------------|-------------------------------------------------------------------------------|
| _Scale_            | A `Vector3` which is multiplied with the input vector.                        |
| _Apply delta time_ | If checked, the input is additionally multiplied with the current delta time. |

## Virtual Cursor (experimental)

This modifier provides a virtual 2D cursor that can be controlled by any input. This is useful if you need to simulate
mouse input with a controller. The input will be treated as a 2D vector that moves the cursor around. The cursor will be
clamped to the window size. Output of this modifier is the cursor position in pixels (similiar to what the _Mouse
Position_ input returns). Use the _3D coordinates_ or _Canvas coordinates_ modifier to convert the cursor position into
3D or 2D world coordinates. This modifier has the following settings:

| Setting                                   | Description                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       |
|-------------------------------------------|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| _Initial position_                        | The initial position of the cursor in a range between 0 and 1. This will be automatically scaled to the actual window size.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       |
| _Initialize from mouse position_          | If enabled, the initial cursor position is taken from the current mouse position when the modifier is activated. This overrides _Initial position_. Note: Has no effect while the mouse is captured, since the mouse is fixed to the window center.                                                                                                                                                                                                                                                                                                                                                                                               |
| _Apply to mouse position on deactivation_ | When enabled, the current virtual cursor position is written back to the system mouse cursor when the modifier is deactivated. This helps avoid visible jumps when switching between a gamepad and a mouse. Note: Not supported while the mouse is captured.                                                                                                                                                                                                                                                                                                                                                                                      |
| _Speed_                                   | The cursor movement speed in pixels.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              |
| _Screen Scale_                            | Screen scaling to be applied to the cursor movement. This controls whether the cursor movement speed is resolution dependent. The following settings are possible: <ul><li>_None_ - no scaling according to the screen resolution is done. An input of `(1,1,0)` will move the cursor one pixel down and one to the right.</li><li>_Longer Axis_ - input will be scaled by the longer axis of the screen resolution (e.g. x-axis in landscape modes, y-axis in portrait modes).</li><li> _Shorter Axis_ - Input will be scaled by the shorter axis of the screen resolution (e.g. y-axis in landscape modes, x-axis in portrait modes).</li></ul> |
| _Apply delta time_                        | If checked, the input is additionally multiplied with the current delta time.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     |

## Window relative

Treats the input vector as a mouse position difference in pixels (e.g. from the _Mouse_ input) and converts it into a
range from `(0,0)` to `(1,1)` relative to the current window size. Useful to get resolution-independent mouse
differences. This modifier has no settings.

**Note**: Depending on the operating system and input device this modifier may not be required and will in fact make
your input resolution-dependent when applied.

You already get resolution-independent values when:

- using the mouse running on Linux
- using the mouse running on OSX
- using the mouse running on Windows with the mouse cursor captured

In these cases, the modifier should _not_ be applied.

You get resolution-dependent mouse values when:

- using the mouse running on Windows with the mouse cursor visible
- using touch input running on Android

In these cases the modifier can be applied. Other combinations have not been tested, so you may need to conduct your own
research here and report your findings, so they can be added to the documentation.

