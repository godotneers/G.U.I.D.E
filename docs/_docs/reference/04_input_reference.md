---
layout: page
title: Input Reference
permalink: /reference/inputs
description: "A reference for all built-in inputs."
---

## Introduction
G.U.I.D.E ships with a selection of inputs for all kinds of input devices. This is a list of all built-in inputs and their settings:

## Action

This input takes a `GUIDEAction` and returns the current value of the action. This way you can use an action value as input for another action. The input will actively track the state of the action and update the value accordingly. This means the input works independently of whether the action is currently bound to an active mapping context and it also works independently of the order in which the action in bound in a mapping context. This input will always mirror the full Vector3 of the action value (even if the action only uses parts of it). The input has the following settings:

| Setting  | Description                             |
|----------|-----------------------------------------|
| _Action_ | The action that the input should track. |

## Any
This input returns `(1,0,0)` if any input of the selected types is received, and `(0,0,0)` otherwise. This is useful to switch input schemes when you detect controller input from a certain device (e.g. switch to a controller or touch input scheme when receiving controller or touch input). Can also be used to realize things like "press any key to continue". The input has the following settings:

| Setting                               | Description                                                                        |
|---------------------------------------|------------------------------------------------------------------------------------|
| _Mouse Buttons_                       | Detect input from mouse buttons.                                                   |
| _Mouse Motion_                        | Detect mouse motion.                                                               |
| _Minimum Mouse Movement Distance_     | The minimum distance the mouse must move to be considered actuated.                |
| _Joy Buttons_                         | Detect input from joystick / joypad  buttons.                                      |
| _Joy Axes_                            | Detect input from joystick / joypad axes.                                          |
| _Minimum Joy Axis Actuation Strength_ | The minimum strength the joystick axis must be actuated to be considered actuated. |
| _Keyboard_                            | Detect input from the keyboard                                                     |
| _Touch_                               | Detect touch input                                                                 |

## Joy Axis 1D

This input returns the value of a 1D axis of a joystick in the `x` component of the input value. The input is restricted to the range of `(-1, 0, 0)` to `(1, 0, 0)`, while usually being `(0,0,0)` when the axis is not actuated. Note that some joy axes only use positive values (e.g. controller triggers). The input has the following settings:

| Setting | Description                                       |
|---------|---------------------------------------------------|
| _Axis_  | The joy axis that should be tracked by the input. |



## Joy Axis 2D
This input returns the value of a 2D axis of a joystick in the `x` and `y` components of the input value. The input is restricted to the range of `(-1, -1, 0)` to `(1, 1, 0)`, while usually being `(0,0,0)` when the axis is not actuated. The input has the following settings:

| Setting | Description                                                             |
|---------|-------------------------------------------------------------------------|
| _X_     | The joy axis that should be tracked by the input for the `x` component. |
| _Y_     | The joy axis that should be tracked by the input for the `y` component. |


## Joy Button
This input returns `(1,0,0)` if the selected joystick button is pressed, and `(0,0,0)` otherwise. The input has the following settings:

| Setting  | Description                                         |
|----------|-----------------------------------------------------|
| _Button_ | The joy button that should be tracked by the input. |


## Joy Direction

This input returns `(1,0,0)` if the selected joy axis is actuated in the configured direction and its absolute value meets or exceeds the actuation threshold, and `(0,0,0)` otherwise. This is useful for mapping a single direction of an axis to a boolean action, for example treating "stick pushed left" and "stick pushed right" as two separate inputs. The input has the following settings:

| Setting               | Description                                                                                                   |
|-----------------------|---------------------------------------------------------------------------------------------------------------|
| _Axis_                | The joy axis that should be tracked by the input.                                                             |
| _Direction_           | The direction the axis must be pushed in order to actuate the input (`Positive` or `Negative`).               |
| _Actuation Threshold_ | The minimum absolute axis value that must be reached to consider the input actuated. Defaults to `0.5`.       |


## Key

This input returns `(1,0,0)` if the selected key is pressed, and `(0,0,0)` otherwise. If modifiers are given, then both the key and all selected modifiers must be pressed in order for this input to return the actuated value of `(1,0,0)`. The input has the following settings:

| Setting                      | Description                                                                                                                                                                                                                                                                                                                                                                                                                                                                    |
|------------------------------|--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| _Key_                        | The key that should be tracked by the input.  This is expected to be a physical key code, so that the physical location of the key in the keyboard stays the same no matter which locale the keyboard is operating in.                                                                                                                                                                                                                                                         |
| _Shift_                      | Whether the `Shift` modifier key must be pressed in addition to the main key.                                                                                                                                                                                                                                                                                                                                                                                                  | 
| _Control_                    | Whether the `Ctrl` modifier key must be pressed in adition to the main key.                                                                                                                                                                                                                                                                                                                                                                                                    |
| _Alt_                        | Whether the `Alt` modifier key must be pressed in addition to the main key.                                                                                                                                                                                                                                                                                                                                                                                                    |
| _Meta_                       | Whether the `Meta` modifier key (`Windows` key on Windows, `Cmd` on OSX) must be pressed in addition to the main key.                                                                                                                                                                                                                                                                                                                                                          |
| _Allow additional modifiers_ | If true, the key input will actuate if modifiers in additional to the enabled ones are pressed. Let's assume you set up the key to `D` and disable _Shift_, _Control_, _Alt_ and _Meta_ and also disable _Allow additional modifiers_. Now the input will only actuate while the `D` key is pressed alone, but will not  actuate when any modifier key is pressed in addition to `D`. Usually this is not what you want, so _Allow additional modifiers_ is `true` by default. |                                                                                                                                                                      



## Mouse Axis 1D

This input returns changes in mouse position along a single axis in the `x` component of the input value (e.g. `(x, 0, 0)`). The input is given in pixels per frame. You can use a _Screen Relative_ modifier to convert this into a value from -1 to 1 that is independent of the screen resolution. The input has the following settings:

| Setting | Description                                         |
|---------|-----------------------------------------------------|
| _Axis_  | The mouse axis that should be tracked by the input. |

## Mouse Axis 2D

This input returns changes in mouse position compared to the previous frame along two axes in the `x` and `y` components of the input value (e.g. `(x, y, 0)`). This is useful for first-person shooter mouse aiming. On most systems this value is given in raw mouse units, so it is resolution independent. Depending on the underlying operating system and whether the mouse cursor is currently visible, you may get viewport pixels. You can use the _Screen Relative_ modifier to convert the value to be resolution independent in this case.

## Mouse Button

This input returns `(1,0,0)` if the selected mouse button is pressed, and `(0,0,0)` otherwise. Note, that Godot also treats the mouse wheel as buttons. If you need an axis from the wheel, you can
map _Wheel Up_ + a _Negate Modifier_ and _Wheel Down_ to a 1-dimensional action. The input has the following settings:

| Setting  | Description                                           |
|----------|-------------------------------------------------------|
| _Button_ | The mouse button that should be tracked by the input. |


## Mouse Position

This input returns the current mouse position in pixels relative to the top left corner of the window in the `x` and `y` components of the input value (e.g. `(x, y, 0)`). You an use a _Canvas Coordinates_ modifier to convert this into a value into 2D world coordinates for the currently active viewport or a _3D Coordinates_ modifier to convert this into 3D world coordinates (e.g. for object picking). This input has no settings.


## Touch Angle

This input tracks changes in the angle between two touching fingers. This is mostly useful to detect rotation gestures. When the user touches the screen with two fingers the input will return `(0,0,0)`. If the user subsequently performs a rotation gesture, the input will return the angle changes since the beginning of the touch (e.g. `(<angle>,0,0)`). Once the user releases the touch, the input will return to `(0,0,0)`.  Note that when you use this input to rotate elements, that the input will retain the angle for as long as the fingers are touched. You should therefore save the starting rotation angle when the rotation begins and then apply the angle from the input on the starting value to show the user a preview of the rotation. Once the rotation ends, you can commit the value. This input has the following settings:

| Setting | Description                                                   |
|---------|---------------------------------------------------------------|
| _Unit_  | The unit in which the angle is reported (degrees or radians). |


## Touch Axis 1D

This input treats touch input like an axis, similar to the _Mouse Axis 1D_ input. When the user begins to touch the screen, and then drags, this input will return the delta value in pixels compared to the previous frame. You can use a _Screen Relative_ modifier to convert this into a value from -1 to 1 that is independent of the screen resolution. The value is returned in the `x` component of the input vector (e.g. `(<value>, 0, 0)`). If the user does not touch the screen this will return `(0, 0, 0)`.  This input has the following settings:

| Setting        | Description                                                                                                                                                                                                            |
|----------------|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| _Axis_         | The axis that should be tracked by the input (_X_ or _Y_).                                                                                                                                                             |
| _Finger Count_ | The amount of fingers that must be on the screen for this  input to react. The finger count must match exactly (e.g. if finger count is 2 then this input will only react while exactly 2 fingers are placed).         |
| _Finger Index_ | The position of which finger should be used for calculating the offset. Use `0` for  the first finger, `1` for the second, and so on. You can also use `-1` which will use the average position of all active fingers. |

## Touch Axis 2D

Similar to _Touch Axis 1D_  but returns input returns changes in touch position along two axes in the `x` and `y` components of the input value (e.g. `(x, y, 0)`). The input is given in pixels relative to the previous frame. You can use a _Screen Relative_ modifier to convert this into a value from -1 to 1 that is independent of the screen resolution. This input has the following settings:

| Setting        | Description                                                                                                                                                                                                            |
|----------------|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| _Finger Count_ | The amount of fingers that must be on the screen for this  input to react. The finger count must match exactly (e.g. if finger count is 2 then this input will only react while exactly 2 fingers are placed).         |
| _Finger Index_ | The position of which finger should be used for calculating the offset. Use `0` for  the first finger, `1` for the second, and so on. You can also use `-1` which will use the average position of all active fingers. |

## Touch Distance

This input will track distance changes between two fingers. This is mostly useful to detect pinch/zoom gestures. When the user touches the screen with two fingers the input will return `(1,0,0)`. If the user subsequently performs a pinch or zoom gesture, the input will return a ratio of the current finger distance compared to the distance at the beginning of the touch (e.g. `(<distance ratio>, 0 ,0)`). At the beginning, this ratio is `1`. If the user makes a pinch gesture, the ratio become smaller, e.g. if the fingers distance is halved, the ratio will be `0.5`. If the user performs a zoom gesture, the ratio will grow, e.g. if the finger distance is doubled, the ratio will be `2.0`. Once the user releases the touch, the input will return to `(0,0,0)`.  

Like with the _Touch Angle_ input, the input will retain the ratio for as long as the fingers are touched. You should therefore save the starting zoom/scale when the distance change begins and then apply the ratio from the input on the starting value to show the user a preview of the scale. Once the distance change ends, you can commit the value. This input has no settings.


## Touch Position

This input returns the current position of a touching finger in pixels relative to the top left corner of the screen in the `x` and `y` components of the input value (e.g. `(x, y, 0)`). You an use a _Canvas Coordinates_ modifier to convert this into a value into 2D world coordinates for the currently active viewport or a _3D Coordinates_ modifier to convert this into 3D world coordinates (e.g. for object picking). If no finger is currently touching or the amount of touching fingers does not match _Finger Count_, the input is `(INF, INF, INF)`. You can use Godot's `is_finite()` method to check if the input is currently valid. G.U.I.D.E's triggers will treat this value as "not actuated". This input has the following settings:

| Setting        | Description                                                                                                                                                                                                    |
|----------------|----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| _Finger Count_ | The amount of fingers that must be on the screen for this  input to react. The finger count must match exactly (e.g. if finger count is 2 then this input will only react while exactly 2 fingers are placed). |
| _Finger Index_ | The position of which finger should be reported. Use `0` for  the first finger, `1` for the second, and so on. You can also use `-1` which will use the average position of all active fingers.                |

