@tool
@icon("../style.svg")
## A render style for the touch renderer.
class_name GUIDETouchRenderStyle
extends Resource

## An icon indicating touch with one finger.
@export var one_finger:Texture2D

## An icon indicating touch with two fingers.
@export var two_fingers:Texture2D

## An icon indicating touch with three fingers.
@export var three_fingers:Texture2D

## An icon indicating touch with four fingers.
@export var four_fingers:Texture2D

## An icon indicating a rotating gesture.
@export var rotate:Texture2D

## An icon indicating a zoom gesture.
@export var zoom:Texture2D


@export_category("Directions")

## An icon indicating horizontal movement.
@export var horizontal:Texture2D

## An icon indicating vertical movement.
@export var vertical:Texture2D

## An icon indicating both horizontal and vertical movement.
@export var both:Texture2D
