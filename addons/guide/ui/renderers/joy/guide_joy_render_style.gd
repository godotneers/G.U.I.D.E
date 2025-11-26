@tool
@icon("../style.svg")
## An style used by the joy renderer.
class_name GUIDEJoyRenderStyle
extends Resource

## Texture to use for joy buttons.
@export var button:Texture2D

## Texture to use for joy sticks.
@export var stick:Texture2D

## The font to use for the label
@export var font:Font

## The color to use for the font.
@export var font_color:Color = Color(0.843, 0.843, 0.843)

## The font size to use in px.
@export var font_size:int = 50

@export_category("Directions")

## An icon indicating horizontal movement.
@export var horizontal:Texture2D

## An icon indicating vertical movement.
@export var vertical:Texture2D
