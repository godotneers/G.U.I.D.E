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
	
	# WHEN
	# I put my finger on the screen
	await finger_down(0, Vector2(50, 50))
	
	# THEN
	# the action is triggered
	await assert_triggered(_action)
	
	assert_vector(_action.value_axis_2d).is_equal(Vector2(50, 50))
	
func test_touch_position_input_with_multiple_fingers() -> void:
	var input := input_touch_position(2, 3)
	map(_context, _action, input)
	
	GUIDE.enable_mapping_context(_context)
	
	# WHEN
	# I put 3 fingerrs on the screen
	await finger_down(0, Vector2(50, 50))
	await finger_down(1, Vector2(150, 50))
	await finger_down(2, Vector2(300, 50))
	
	# THEN
	# the action is triggered
	await assert_triggered(_action)
	
	# and i get the third finger's value
	assert_vector(_action.value_axis_2d).is_equal(Vector2(300, 50))
	
func test_touch_position_input_with_multiple_fingers_doesnt_trigger_if_not_enough_fingers() -> void:
	var input := input_touch_position(2, 3)
	map(_context, _action, input)
	
	GUIDE.enable_mapping_context(_context)
	
	# WHEN
	# I put 2 fingerrs on the screen
	await finger_down(0, Vector2(50, 50))
	await finger_down(1, Vector2(150, 50))
	
	# THEN
	# the action is not triggered
	await assert_not_triggered(_action)
	
	

func test_touch_position_input_with_multiple_fingers_calculates_average() -> void:
	var input := input_touch_position(-1, 3)
	map(_context, _action, input)
	
	GUIDE.enable_mapping_context(_context)
	
	# WHEN
	# I put 3 fingerrs on the screen
	await finger_down(0, Vector2(0, 0))
	await finger_down(1, Vector2(-100, 100))
	await finger_down(2, Vector2(100, 200))
	
	# THEN
	# the action is triggered
	await assert_triggered(_action)
	
	# and the value is the average of the three fingers
	assert_vector(_action.value_axis_2d).is_equal(Vector2(0, 100))
