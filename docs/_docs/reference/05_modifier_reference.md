---
layout: page
title: Modifier Reference
permalink: /reference/modifiers
description: "A reference for all built-in modifiers."
---

## Introduction
G.U.I.D.E ships with a selection of modifiers for many use cases. This is a list of all built-in modifiers and their configuration settings:

## 3D Coordinates
This modifier converts a 2D mouse position (from the _Mouse Position_ input) into 3D world coordinates. It does this by performing a raycast into the game world using the currently active 3D camera. Use this to find out "where in my 3D world did the player just click". It has the following settings:

|Setting|Description|
|---|---|
|_Max Depth_| The maximum depth for the ray cast in units. |
|_Collide with areas_| Whether the raycast should collide with areas. |
|_Collision mask_ | A mask used for the ray cast. This should be set up so the collision layers that make up your "world" are selected for collision. |

The modifier sets the action value to the 3D world position of the raycast hit. If the raycast hits nothing, the modifier sets the action value to `Vector3.INF`.

## 8-way direction
This is a filtering modifier that checks whether 2D input points into one of 8 directions. If the input points into this direction, sets the action value to `(1,0,0)` otherwise to `(0,0,0)`. Can be used to get discrete directions from analog input. It has the following setings:

| Setting             | Description                                                                                                                       |
|---------------------|-----------------------------------------------------------------------------------------------------------------------------------|
| _Direction_         | The direction for which the modifier should filter.                                                                               |

## Canvas coordinates
This modifier converts a 2D mouse position (from the the _Mouse Position_ input) into 2D world coordinates (canvas coordinates) for the currently active viewport. This modifier takes into account the current scaling mode and any changes (zoom, offset) applied by a Camera2D in the currently active viewport. Use this to quickly find out "where in my 2D world did the player just click". This modifier has no settings.


## Curve
This modifier applies a separate curve to each input axis.  Input values are assumed to fall in the range of `0` to `1`. You can use the _Map Range_ modifier to convert your value into this range, if needed. It has the following settings:

| Setting | Description                      |
|---------|----------------------------------|
| _Curve_ | The curve to apply.              |
| _X_     | Apply the modifier to the X axis |
| _Y_     | Apply the modifier to the Y axis |
| _Z_     | Apply the modifier to the Z axis |


## Deadzone
This modifier applies a deadzone to 1D, 2D or 3D axis input. You can specify a minimum and maximum value. Every input outside the minimum and maximum will be clamped while all the values between the minimum and maximum will be scaled to a range between 0 and 1. This modifier has the following settings:

| Setting           | Description                                                                         |
|-------------------|-------------------------------------------------------------------------------------|
| _Lower threshold_ | The lower threshold for the input. All values below this value will be mapped to 0. |
| _Upper threshold_ | The upper threshold for the input. All values above this value will be mapped to 1. |

## Input swizzle
This modifier rearranges the x,y and z components of the current input value. This is useful if you want to bind keys to multiple axes or otherwise want to modify the input vector to do any operations on it. This modifier is often combined with the _Negate_ modifier. It has the following settings:

| Setting | Description                        |
|---------|------------------------------------|
| _Order_ | The new order of the input vector. |


## Map Range
This modifier maps the input value through an input and output range and optionally clamps the output. Can be used to scale and translate at the same time.  (For example, mapping a `0` to `1` range to a `-1` to `1` range.) It has the following settings:

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
This modifier negates one or more axes of the input vector. Useful to map key inputs to negative values or to realize inverted controls for joysticks. It has the following settings:


| Setting | Description                                          |
|---------|------------------------------------------------------|
| _X_     | Whether the `x`-axis of the input should be negated. |
| _Y_     | Whether the `y`-axis of the input should be negated. |
| _Z_     | Whether the `z`-axis of the input should be negated. |


## Positive/Negative
Limits inputs to positive or negative values. Values which do not match will be clamped to zero. Useful if you want to bind different halves of an axis to different actions. This modifier has the following settings:


| Setting | Description                                                             |
|---------|-------------------------------------------------------------------------|
| _Range_ | Whether the the input should be limited to positive or negative values. |
| _X_     | Whether the `x`-axis of the input should be affected.                   |
| _Y_     | Whether the `y`-axis of the input should be affected.                   |
| _Z_     | Whether the `z`-axis of the input should be affected.                   |

## Scale
Multiplies the input with the given Vector3. Useful to  control things like input sensitivity or to convert input into a more useful range (e.g. radians from 0-1). Input can also be multiplied with delta time (to limit input over time). The modifier has the following settings:

| Setting | Description                                            |
|---------|--------------------------------------------------------|
| _Scale_ | A `Vector3` which is multiplied with the input vector. |
| _Apply delta time_ |If checked, the input is additionally multiplied with the current delta time. |

## Window relative
Treats the input vector as a mouse position difference in pixels (e.g. from the _Mouse_ input) and converts it into a range from `(0,0)` to `(1,1)` relative to the current window size. Useful to get resolution-independent mouse differences. This modifier has no settings.
