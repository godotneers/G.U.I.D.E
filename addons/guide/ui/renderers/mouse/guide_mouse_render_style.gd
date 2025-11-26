@tool
@icon("../style.svg")
## A render style for the mouse renderer.
class_name GUIDEMouseRenderStyle
extends Resource

## The mouse with no keys pressed.
@export var mouse_blank:Texture2D

## The mouse with the left key pressed.
@export var mouse_left:Texture2D

## The mouse with the right key pressed.
@export var mouse_right:Texture2D

## The mouse with the middle key pressed.
@export var mouse_middle:Texture2D

## The mouse with the A side key pressed.
@export var mouse_side_a:Texture2D

## The mouse with the B side key pressed.
@export var mouse_side_b:Texture2D

## The mouse cursor.
@export var mouse_cursor:Texture2D


@export_category("Directions")

## An icon indicating movement to the left.
@export var left:Texture2D

## An icon indicating movement to the right.
@export var right:Texture2D

## An icon indicating movement up.
@export var up:Texture2D

## An icon indicating movement down.
@export var down:Texture2D

## An icon indicating horizontal movement.
@export var horizontal:Texture2D

## An icon indicating vertical movement.
@export var vertical:Texture2D
