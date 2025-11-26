@tool
extends GUIDEIconRenderer

func supports(input:GUIDEInput, options:GUIDEInputFormattingOptions) -> bool:
	return input is GUIDEInputAction
	
func render(input:GUIDEInput, options:GUIDEInputFormattingOptions) -> void:
	pass
 
func cache_key(input:GUIDEInput, options:GUIDEInputFormattingOptions) -> String:
	return "0ecd6608-ba3c-4fc2-83f7-ad61736f1106"  # we only have one output, so same cache key
