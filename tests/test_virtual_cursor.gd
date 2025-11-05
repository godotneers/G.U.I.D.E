extends GUIDETestBase

var _vc_action:GUIDEAction
var _virtual_cursor:GUIDEModifierVirtualCursor
var _mc:GUIDEMappingContext

func _setup() -> void:
	_mc = mapping_context()
	
	# Combine D and S into a single action where D moves right and S moves down
	var inputs := action_2d("inputs")
	var left := input_key(KEY_A)
	var right := input_key(KEY_D)
	var up := input_key(KEY_W)
	var down := input_key(KEY_S)
	var swizzle := modifier_input_swizzle()
	var negate := modifier_negate()

	map(_mc, inputs, left, [negate])
	map(_mc, inputs, right)
	map(_mc, inputs, up, [negate, swizzle])
	map(_mc, inputs, down, [swizzle])
	
	
	# Now use this action as input for the virtual cursor
	_vc_action = action_2d("virtual_cursor")
	var combined_input := input_action(inputs)
	_virtual_cursor = modifier_virtual_cursor(Vector2.ZERO)
	
	map(_mc, _vc_action, combined_input, [_virtual_cursor])
	


func test_cursor_speed_is_uniform() -> void:
	GUIDE.enable_mapping_context(_mc)
	
	# WHEN
	await tap_keys([KEY_S, KEY_D])
	
	# THEN
	var value := _vc_action.value_axis_2d
	assert_float(value.length()).is_greater(1.0).append_failure_message("Cursor didn't move")
	assert_float(value.x).is_equal(value.y).append_failure_message("Cursor moved non-uniformly")
	
	
func test_cursor_stays_in_frame() -> void:
	GUIDE.enable_mapping_context(_mc)
	
	# WHEN i press left
	await tap_key(KEY_A)
	
	# THEN i don't go further left
	assert_vector(_vc_action.value_axis_2d).is_equal(Vector2.ZERO)	
	
	# WHEN i press up
	await tap_key(KEY_W)
	
	# THEN i don't go further up
	assert_vector(_vc_action.value_axis_2d).is_equal(Vector2.ZERO)	
	
	# WHEN I hold down and right
	await keys_down([KEY_D, KEY_S])

	# for a while
	await wait_seconds(2)
	
	await keys_up([KEY_D, KEY_S])
	
	var size:Vector2 = get_window().size
	# then I'm at the window size
	assert_vector(_vc_action.value_axis_2d).is_equal(size)
	
	
	
func test_cursor_follows_mouse_position_when_flag_is_set() -> void:
	# WHEN: initializing the cursor from mouse position is enabled
	_virtual_cursor.initialize_from_mouse_position = true
	
	# i move the mouse to a random position of the screen
	var position:Vector2 = Vector2(get_window().size) * Vector2(randf(), randf()).round()
	await mouse_move_to(position)
	
	print(get_window().get_mouse_position())

	# and i enable the mapping context
	GUIDE.enable_mapping_context(_mc)
	
	# THEN the cursor is at the same position as the mouse position
	assert_vector(_vc_action.value_axis_2d).is_equal_approx(position, Vector2(0.01, 0.01))
