@tool
@icon("../style.svg")
## This is style used by the controller renderer. 
class_name GUIDEControllerRenderStyle
extends Resource

## Texture for the bottom action button: Sony Cross, Xbox A, Nintendo B 
@export var a_button:Texture2D
## Texture for the right action button: Sony Circle, Xbox B, Nintendo A.
@export var b_button:Texture2D
## Texture for the left action button: Sony Square, Xbox X, Nintendo Y.
@export var x_button:Texture2D
## Texture for the top action button: Sony Triangle, Xbox Y, Nintendo X.
@export var y_button:Texture2D
## Texture for the left stick of the controller. 
@export var left_stick:Texture2D
## Texture for the left stick click button of the controller. 
@export var left_stick_click:Texture2D
## Texture for the right stick of the controller. 
@export var right_stick:Texture2D
## Texture for the right stick click button of the controller. 
@export var right_stick_click:Texture2D
## Texture for the  left shoulder button: Sony L1, Xbox LB button.
@export var left_bumper:Texture2D
## Texture for the right shoulder button: Sony R1, XBOX RB button.
@export var right_bumper:Texture2D
## Texture for the left trigger. 
@export var left_trigger:Texture2D
## Texture for the right trigger. 
@export var right_trigger:Texture2D
## Texture for the up direction on the directional pad. 
@export var dpad_up:Texture2D
## Texture for the left direction on the directional pad. 
@export var dpad_left:Texture2D
## Texture for the right direction on the directional pad. 
@export var dpad_right:Texture2D
## Texture for the down direction on the directional pad. 
@export var dpad_down:Texture2D
## Texture for the Start button: Sony Options, Xbox Menu, Nintendo + button 
@export var start:Texture2D
## Texture for the Miscellaneous 1 button: Xbox share , PS5 microphone , Nintendo Switch capture.
@export var misc1:Texture2D
## Texture for the back button:  Sony Select, Xbox Back, Nintendo - button
@export var back:Texture2D
## Texture for the touchpad.
@export var touch_pad:Texture2D


@export_category("Directions")
## An icon indicating horizontal movement.
@export var horizontal:Texture2D
## An icon indicating vertical movement.
@export var vertical:Texture2D
