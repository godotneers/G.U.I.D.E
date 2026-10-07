extends GUIDETestBase


var _context:GUIDEMappingContext
var _action:GUIDEAction

func _setup() -> void:
	_context = mapping_context()
	_action = action_2d()

func test_touch_axis_2d_input() -> void:
	var input := input_touch_axis_2d()
	map(_context, _action, input)
	
	GUIDE.enable_mapping_context(_context)
	var watched := watch(_action)

	# WHEN
	# I move my finger on the screen
	await finger_down(0, Vector2(50, 50))
	await finger_move(0, Vector2(100, 0))

	# THEN
	# the action is triggered
	await watched.assert_triggered()


func test_touch_axis_2d_input_with_first_visible_finger_not_having_raw_index_0() -> void:
	var input := input_touch_axis_2d()
	map(_context, _action, input)

	GUIDE.enable_mapping_context(_context)
	var watched := watch(_action)

	var holder:Array[Vector2] = [Vector2.ZERO]
	_action.triggered.connect(func() -> void: holder[0] = _action.value_axis_2d)

	# WHEN
	# finger 0 never reaches GUIDE (e.g. consumed by a virtual stick)
	# and I move finger 1 on the screen
	await finger_down(1, Vector2(50, 50))
	await finger_move(1, Vector2(100, 0))

	# THEN
	# the action is triggered
	await watched.assert_triggered()

	# and it reports the movement of that finger
	assert_vector(holder[0]).is_equal(Vector2(50, -50))
