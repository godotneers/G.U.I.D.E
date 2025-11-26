@tool
extends GUIDEIconRenderer

func _init() -> void:
	priority = 100

func supports(input:GUIDEInput, options:GUIDEInputFormattingOptions) -> bool:
	return true
	
func render(input:GUIDEInput, options:GUIDEInputFormattingOptions) -> void:
	pass
 
func cache_key(input:GUIDEInput, options:GUIDEInputFormattingOptions) -> String:
	return "2e130e8b-d5b3-478c-af65-53415adfd6bb"  # we only have one output, so same cache key
