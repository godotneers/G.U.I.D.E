extends GUIDETestBase

var _context:GUIDEMappingContext
var _action:GUIDEAction

func _setup() -> void:
	_context = mapping_context()
	_action = action_bool()

func test_missing_action_is_properly_handled() -> void:
	_context.resource_path = "dummy://test_context"
	var input := input_any()
	input.mouse = true
	map(_context, null, input) # action is missing
	
	# when we enable the mapping context, we see a warning
	await assert_error(func() -> void: 	GUIDE.enable_mapping_context(_context)) \
		.is_push_warning("Mapping at position 1 in context dummy://test_context has no action set. This mapping will be ignored.")

	
	
	
