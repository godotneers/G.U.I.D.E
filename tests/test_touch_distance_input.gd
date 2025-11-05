extends GUIDETestBase


var _context:GUIDEMappingContext
var _action:GUIDEAction

func _setup() -> void:
	_context = mapping_context()
	_action = action_1d()

func test_touch_distance_input_triggers_on_fingers_moving_closer() -> void:
	var input := input_touch_distance()
	map(_context, _action, input)
	
	GUIDE.enable_mapping_context(_context)
	
	# WHEN
	# I move fingers toward each toher
	await finger_down(0, Vector2(0, 0))
	await finger_down(1, Vector2(200, 200))
	await finger_move(1, Vector2(100, 100))
	
	# THEN
	# the action is triggered
	await assert_triggered(_action)
	
func test_touch_distance_input_on_fingers_moving_apart() -> void:
	var input := input_touch_distance()
	map(_context, _action, input)
	
	GUIDE.enable_mapping_context(_context)
	
	# WHEN
	# I move fingers away from each other
	await finger_down(0, Vector2(0, 0))
	await finger_down(1, Vector2(100, 100))
	await finger_move(1, Vector2(200, 200))
	
	# THEN
	# the action is triggered
	await assert_triggered(_action)
	

func test_touch_distance_input_doesnt_trigger_on_fingers_standing_still() -> void:
	var input := input_touch_distance()
	map(_context, _action, input)
	
	GUIDE.enable_mapping_context(_context)
	
	# WHEN
	# I keep fingers still
	await finger_down(0, Vector2(0, 0))
	await finger_down(1, Vector2(200, 200))
	
	# THEN
	# the action is not triggered
	await assert_not_triggered(_action)
