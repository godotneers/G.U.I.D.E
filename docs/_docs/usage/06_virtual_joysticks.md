---
layout: page
title: "Virtual Joysticks"
permalink: /usage/virtual-joysticks
description: "How to use virtual joysticks with G.U.I.D.E"
---

## Overview

Virtual joysticks allow you to create on-screen controls that can be used to interact with your game. This is often used in mobile games where the player usually cannot use physical controllers and only has a touchscreen. If you want to see this in action, check out the `virtual_sticks` example scene that ships with G.U.I.D.E.

## Adding a virtual joystick to your scene

Virtual joysticks and buttons are UI components. Usually they are overlaid on top of your game scene. It is recommended that you use a `CanvasLayer` as the root node for your virtual joysticks and buttons. Then you can use Godot's anchoring system to position and anchor them to the screen, so they work with any resolution.

{% include video.html path="assets/img/manual/manual_add_virtual_joys.mp4" %}

You will notice that by default, nothing is visible when you add a virtual joystick or button. This is because how the joystick looks is very dependent on the game that you are making. That's why there is a separate component for rendering joysticks and joy buttons. We'll get to that in a minute. Both the joystick and the joy button have a debug mode which will show you the size of the joystick or button on screen, and you can use that to position them at the right position for your game.

After adding a joystick or button to your scene, you can configure various options. Adjust its size and decide whether it works with a mouse, touch or both. Also, choose which virtual device the button or joystick should belong to. This will become important later when we try to map the virtual joystick in our G.U.I.D.E mapping context.

### Input mode

Virtual joysticks and joy buttons can work in three different input modes:

- _Mouse_ - the joystick or button will respond to mouse input.
- _Touch_ - the joystick or button will respond to touch input.
- _Mouse and touch_ - the joystick or button will respond to both mouse and touch input.

If you use _Mouse and touch_ as input mode, make sure that Godot's _Emulate mouse from touch_ and _Emulate touch from mouse_ options are disabled, otherwise you will get unexpected behavior. Also note, that when using _Mouse_ you can only ever use one joystick or button at a time, as there is only a single mouse cursor. 

## Rendering virtual joysticks and joy buttons

Because the style of your virtual joysticks and joy buttons should match the style of your game, G.U.I.D.E allows you to fully control how this is rendered on screen. The rendering is controlled by two custom nodes:

- `GUIDEVirtualStickRenderer` - controls the appearance of the joystick
- `GUIDEVirtualButtonRenderer` - controls the appearance of the joy button

Both of these nodes come with a default implementation which uses textures to render the stick and the button. So a simple way to get started is to use these default renderers and change the textures to match your game. To do this, add the matching renderer node as a child of the virtual stick or virtual button. It will then automatically update when the stick or button changes its state.

{% include video.html path="assets/img/manual/manual_virtual_stick_default_renderers.mp4" %}

You can customize the textures in the inspector of each renderer.

## Using virtual joysticks in G.U.I.D.E mapping contexts.

Virtual joysticks send `InputEventJoypadMotion` while virtual joy buttons send `InputEventJoypadButton` events to the input system. They use virtual device ids between -2 and -6 to avoid conflicts with real joysticks. This means that you can use virtual joysticks in the same way as real joysticks, so you will map them to `GUIDEInputJoyAxis2D` and `GUIDEInputJoyButton` inputs. The only difference is that you select the virtual joystick in the input mapping context.

![Using virtual joys in the mapping context]({{site.baseurl}}/assets/img/manual/virtual_joy_mapping_context.png)

## Creating custom renderers
If the built-in default renderer, which uses textures, is not enough for your game, you can create your own renderers and fully control the rendering process. So if you want to use a fancy shader or animations, you can totally do this.

### Creating a custom virtual stick renderer

To create a custom virtual stick renderer, create a new script and derive it from the `GUIDEVirtualStickRenderer` class. Virtual stick renderers are controls, and they are supposed to live below the virtual stick node, which is a center container node. This means you don't need to care about positioning your controls as long as they are children of the renderer. They will get positioned automatically, even if the virtual stick changes its position. The `GUIDEVirtualStickRenderer` base class will provide you with two methods, which you can override to update your renderer whenever the stick changes its position or its setup.

```gdscript
class_name MyCustomVirtualStickRenderer
extends GUIDEVirtualStickRenderer

## This is called when the virtual stick changes its configuration, e.g. size.
func _on_configuration_changed() -> void:
    # Called when the virtual stick changes its configuration, e.g. size.

    # you can get the new configuration from
    # the base class' properties:
    var new_stick_radius = stick_radius
    var new_max_actuation_radius = max_actuation_radius
    
    # update custom UI elements or shaders here
    ...

## This is called when the virtual stick changes its position or actuation status.
func _update(joy_position: Vector2, joy_offset:Vector2, is_actuated:bool) -> void:
    # joy_position is the position of the joystick
    # relative to the center of the virtual stick in
    # world coordinates.
    # joy_offset is the position of the joystick
    # relative to the center of the virtual stick
    # in a normalized coordinate system (e.g from (-1, -1) to (1, 1)).
    # is_actuated is true if the joystick is actuated.
    
    # update custom UI elements or shaders here
    ...
```

You can study the built-in default virtual stick renderer to see a working example. If you'd like to see a more complex example, check out the `virtual_sticks` example scene that ships with G.U.I.D.E. This uses a custom virtual stick renderer to render a virtual joystick with a shader.

### Creating a custom virtual button renderer
A virtual button renderer works similarly to a virtual stick renderer. You can create a custom virtual button renderer by deriving from the `GUIDEVirtualButtonRenderer` class.

```gdscript
class_name MyCustomVirtualButtonRenderer
extends GUIDEVirtualButtonRenderer

## This is called when the virtual button changes its configuration, e.g. size.
func _on_configuration_changed() -> void:
    # Called when the virtual button changes its configuration, e.g. size.
   var new_button_radius = button_radius 

func _update(is_actuated:bool) -> void:
    # is_actuated is true when the button is actuated,
    # false otherwise
    
    # update custom UI elements or shaders here.
```

