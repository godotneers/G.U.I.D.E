## Base class for text providers. A text provider provides a textual representation
## of an input which is displayed to the user.
## scripts.
@tool
class_name GUIDETextProvider

## The priority of this text provider. The built-in text provider uses priority 0.
## The smaller the number the higher the priority.
@export var priority:int = 0

## Whether or not this provider can provide a text for this input.
func supports(input:GUIDEInput, options:GUIDEInputFormattingOptions) -> bool:
	return false
	
## Provides the text for the given input. Will only be called when the 
## input is supported by this text provider. Note that for key input
## this is not supposed to look at the modifiers. This function will
## be called separately for each modifier.
func get_text(input:GUIDEInput, options:GUIDEInputFormattingOptions) -> String:
	return "not implemented"
 

