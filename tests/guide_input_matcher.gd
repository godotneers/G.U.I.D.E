## This is an input matcher for matching G.U.I.D.E. inputs in signals.
class_name GUIDEInputMatcher
extends GdUnitArgumentMatcher

var _input: GUIDEInput
func _init(input:GUIDEInput) -> void:
	_input = input
	
func is_match(argument:Variant) -> bool:
	return _input == argument or _input.is_same_as(argument)
