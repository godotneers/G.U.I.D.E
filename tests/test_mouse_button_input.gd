extends GUIDETestBase


var _context:GUIDEMappingContext
var _action:GUIDEAction

func _setup() -> void:
	_context = mapping_context()
	_action = action_bool()

func test_mouse_button_input() -> void:
	var input := input_mouse_button()
	map(_context, _action, input)

	GUIDE.enable_mapping_context(_context)
	var watched := watch(_action)

	# WHEN
	# i press the mouse button
	await tap_mouse(MOUSE_BUTTON_LEFT)

	# THEN
	# the action should be triggered
	await watched.assert_triggered()

