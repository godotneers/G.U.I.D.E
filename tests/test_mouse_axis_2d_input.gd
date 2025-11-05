extends GUIDETestBase


var _context:GUIDEMappingContext
var _action:GUIDEAction

func _setup() -> void:
	_context = mapping_context()
	_action = action_1d()

func test_mouse_axis2d_input() -> void:
	var input := input_mouse_axis_2d()
	map(_context, _action, input)
	
	GUIDE.enable_mapping_context(_context)
	
	# WHEN
	# i move the mouse
	await mouse_move_by(Vector2(20, 20))
	
	# THEN
	# the action should be triggered
	await assert_triggered(_action)

