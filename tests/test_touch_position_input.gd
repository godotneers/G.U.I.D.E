extends GUIDETestBase


var _context:GUIDEMappingContext
var _action:GUIDEAction

func _setup() -> void:
	_context = mapping_context()
	_action = action_2d()

func test_touch_position_input() -> void:
	var input := input_touch_position()
	map(_context, _action, input)

	GUIDE.enable_mapping_context(_context)
	var watched := watch(_action)

	# WHEN
	# I put my finger on the screen
	await finger_down(0, Vector2(50, 50))

	# THEN
	# the action is triggered
	await watched.assert_triggered()
	
	assert_vector(_action.value_axis_2d).is_equal(Vector2(50, 50))
	
func test_touch_position_input_uses_rank_not_raw_finger_index() -> void:
	var input := input_touch_position(0, 1)
	map(_context, _action, input)

	GUIDE.enable_mapping_context(_context)
	var watched := watch(_action)

	# WHEN
	# finger 0 never reaches GUIDE (e.g. consumed by a virtual stick)
	# and I put finger 1 on the screen
	await finger_down(1, Vector2(70, 80))

	# THEN
	# the action is triggered, as this is the first finger GUIDE sees
	await watched.assert_triggered()

	assert_vector(_action.value_axis_2d).is_equal(Vector2(70, 80))


func test_touch_position_input_with_multiple_fingers() -> void:
	var input := input_touch_position(2, 3)
	map(_context, _action, input)

	GUIDE.enable_mapping_context(_context)
	var watched := watch(_action)

	# WHEN
	# I put 3 fingerrs on the screen
	await finger_down(0, Vector2(50, 50))
	await finger_down(1, Vector2(150, 50))
	await finger_down(2, Vector2(300, 50))

	# THEN
	# the action is triggered
	await watched.assert_triggered()
	
	# and i get the third finger's value
	assert_vector(_action.value_axis_2d).is_equal(Vector2(300, 50))
	
func test_touch_position_input_with_multiple_fingers_doesnt_trigger_if_not_enough_fingers() -> void:
	var input := input_touch_position(2, 3)
	map(_context, _action, input)

	GUIDE.enable_mapping_context(_context)
	var watched := watch(_action)

	# WHEN
	# I put 2 fingerrs on the screen
	await finger_down(0, Vector2(50, 50))
	await finger_down(1, Vector2(150, 50))

	# THEN
	# the action is not triggered
	watched.assert_not_triggered()
	
	

func test_touch_position_input_with_multiple_fingers_calculates_average() -> void:
	var input := input_touch_position(-1, 3)
	map(_context, _action, input)

	GUIDE.enable_mapping_context(_context)
	var watched := watch(_action)

	# WHEN
	# I put 3 fingerrs on the screen
	await finger_down(0, Vector2(0, 0))
	await finger_down(1, Vector2(-100, 100))
	await finger_down(2, Vector2(100, 200))

	# THEN
	# the action is triggered
	await watched.assert_triggered()
	
	# and the value is the average of the three fingers
	assert_vector(_action.value_axis_2d).is_equal(Vector2(0, 100))


func test_touch_position_input_rank_follows_non_contiguous_raw_indices() -> void:
	var input := input_touch_position(1, 2)
	map(_context, _action, input)

	GUIDE.enable_mapping_context(_context)
	var watched := watch(_action)

	# WHEN
	# two fingers with raw indices 1 and 3 touch the screen
	await finger_down(1, Vector2(10, 10))
	await finger_down(3, Vector2(30, 30))

	# THEN
	# the action is triggered
	await watched.assert_triggered()

	# and the second finger by touch-down order is reported
	assert_vector(_action.value_axis_2d).is_equal(Vector2(30, 30))


func test_touch_position_input_does_not_trigger_if_rank_is_out_of_range() -> void:
	var input := input_touch_position(1, 1)
	map(_context, _action, input)

	GUIDE.enable_mapping_context(_context)
	var watched := watch(_action)

	# WHEN
	# only finger 1 is on the screen (finger 0 never reaches GUIDE)
	await finger_down(1, Vector2(70, 80))

	# THEN
	# there is no second finger, so the action is not triggered
	watched.assert_not_triggered()


func test_touch_position_input_rank_shifts_when_first_finger_lifts() -> void:
	var input := input_touch_position(0, 1)
	map(_context, _action, input)

	GUIDE.enable_mapping_context(_context)
	var watched := watch(_action)

	# WHEN
	# two fingers touch the screen and the first one lifts
	await finger_down(0, Vector2(10, 10))
	await finger_down(1, Vector2(20, 20))
	await finger_up(0)

	# THEN
	# the action is triggered
	await watched.assert_triggered()

	# and the remaining finger is now the first finger
	assert_vector(_action.value_axis_2d).is_equal(Vector2(20, 20))


func test_touch_position_input_repressed_finger_moves_to_the_back() -> void:
	var input := input_touch_position(1, 2)
	map(_context, _action, input)

	GUIDE.enable_mapping_context(_context)
	var watched := watch(_action)

	# WHEN
	# two fingers touch the screen, the first one lifts and touches again
	# (the platform reuses the raw index 0 for it)
	await finger_down(0, Vector2(10, 10))
	await finger_down(1, Vector2(20, 20))
	await finger_up(0)
	await finger_down(0, Vector2(40, 40))

	# THEN
	# the action is triggered
	await watched.assert_triggered()

	# and the re-pressed finger is now the second finger
	assert_vector(_action.value_axis_2d).is_equal(Vector2(40, 40))


func test_touch_position_input_average_with_non_contiguous_raw_indices() -> void:
	var input := input_touch_position(-1, 2)
	map(_context, _action, input)

	GUIDE.enable_mapping_context(_context)
	var watched := watch(_action)

	# WHEN
	# two fingers with raw indices 1 and 3 touch the screen
	await finger_down(1, Vector2(0, 0))
	await finger_down(3, Vector2(100, 200))

	# THEN
	# the action is triggered
	await watched.assert_triggered()

	# and the value is the average of both fingers
	assert_vector(_action.value_axis_2d).is_equal(Vector2(50, 100))
