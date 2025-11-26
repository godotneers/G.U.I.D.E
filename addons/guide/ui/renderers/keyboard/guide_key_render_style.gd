@tool
@icon("../style.svg")
## An style used by the key renderer.
class_name GUIDEKeyRenderStyle
extends Resource

## Texture to use for the keycaps.
@export var keycaps:Texture2D


## The region of the texture to use. If this rect has no size, it will be ignored.
@export var region_rect:Rect2 = Rect2()

@export_group("Patch margin", "patch_margin")
@export_range(0, 100, 1, "or_greater") var patch_margin_left:int = 0
@export_range(0, 100, 1, "or_greater") var patch_margin_top:int = 0 
@export_range(0, 100, 1, "or_greater") var patch_margin_right:int = 0
@export_range(0, 100, 1, "or_greater") var patch_margin_bottom:int = 0

## The font to use for the key label.
@export var font:Font

## The color to use for the font.
@export var font_color:Color = Color(0.843, 0.843, 0.843)

## The font size to use in px.
@export var font_size:int = 45
