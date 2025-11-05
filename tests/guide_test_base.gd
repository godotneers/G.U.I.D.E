class_name GUIDETestBase
extends GdUnitTestSuite

#------------------- Lifecycle ---------------------------------------------
var start_frame:int = 0
var runner:GdUnitSceneRunner

func after_test() -> void:
	print_f("Cleanup phase")
	# Clear all mapping contexts after each test
	# since this will modify the dictionary in GUIDE, we make a copy
	var contexts:Array = GUIDE._active_contexts.keys()
	for context:GUIDEMappingContext in contexts:
		GUIDE.disable_mapping_context(context)
		
	GUIDEInputFormatter.cleanup()


func before_test() -> void:
	print("-----------------------------------")
	start_frame = Engine.get_process_frames()
	print_f("Setup phase")
	runner = scene_runner(auto_free(Node.new()))
	GUIDE._input_state._clear()
	_setup()
	print_f("Test phase")
	
func _setup() -> void:
	pass

#------------------- Setup -------------------------------------------------

func mapping_context() -> GUIDEMappingContext:
	return GUIDEMappingContext.new()


@warning_ignore("shadowed_variable_base_class")
func action(name:String, value_type:GUIDEAction.GUIDEActionValueType) -> GUIDEAction:
	var result := GUIDEAction.new()
	result.name = name
	result.action_value_type = value_type
	monitor_signals(result)
	return result


@warning_ignore("shadowed_variable_base_class")
func action_bool(name:String = "action") -> GUIDEAction:
	return action(name, GUIDEAction.GUIDEActionValueType.BOOL)


@warning_ignore("shadowed_variable_base_class")
func action_1d(name:String = "action") -> GUIDEAction:
	return action(name, GUIDEAction.GUIDEActionValueType.AXIS_1D)


@warning_ignore("shadowed_variable_base_class")
func action_2d(name:String = "action") -> GUIDEAction:
	return action(name, GUIDEAction.GUIDEActionValueType.AXIS_2D)


@warning_ignore("shadowed_variable_base_class")
func action_3d(name:String = "action") -> GUIDEAction:
	return action(name, GUIDEAction.GUIDEActionValueType.AXIS_3D)

@warning_ignore("shadowed_variable")
func input_action(action:GUIDEAction) -> GUIDEInputAction:
	var result := GUIDEInputAction.new()
	result.action = action
	monitor_signals(result)
	return result
	
	
	
func input_key(key:Key) -> GUIDEInputKey:
	var result := GUIDEInputKey.new()
	result.key = key
	return result
	
	
func input_any() -> GUIDEInputAny:
	var result := GUIDEInputAny.new()
	return result

func input_mouse_button(button:MouseButton = MOUSE_BUTTON_LEFT) -> GUIDEInputMouseButton:	
	var result:GUIDEInputMouseButton = GUIDEInputMouseButton.new()
	result.button = button
	return result

func input_mouse_axis_1d(axis:GUIDEInputMouseAxis1D.GUIDEInputMouseAxis) -> GUIDEInputMouseAxis1D:	
	var result := GUIDEInputMouseAxis1D.new()
	result.axis = axis
	return result

func input_mouse_axis_2d() -> GUIDEInputMouseAxis2D:
	return GUIDEInputMouseAxis2D.new()

func input_mouse_position() -> GUIDEInputMousePosition:
	return GUIDEInputMousePosition.new()
	
func input_joy_button(button:JoyButton) -> GUIDEInputJoyButton:
	var result := GUIDEInputJoyButton.new()
	result.button = button
	return result

func input_joy_axis_1d(axis:JoyAxis) -> GUIDEInputJoyAxis1D:
	var result := GUIDEInputJoyAxis1D.new()
	result.axis = axis
	return result
	
func input_joy_axis_2d(x:JoyAxis, y:JoyAxis) -> GUIDEInputJoyAxis2D:
	var result := GUIDEInputJoyAxis2D.new()
	result.x = x
	result.y = y
	return result
	
func input_touch_axis_1d(axis:GUIDEInputTouchAxis1D.GUIDEInputTouchAxis, finger_index:int = 0) -> GUIDEInputTouchAxis1D:
	var result := GUIDEInputTouchAxis1D.new()
	result.axis = axis
	result.finger_index = finger_index
	return result
	
func input_touch_axis_2d(finger_index:int = 0) -> GUIDEInputTouchAxis2D:
	var result := GUIDEInputTouchAxis2D.new()
	result.finger_index = finger_index
	return result

func input_touch_position(finger_index:int = 0, finger_count:int = 1)-> GUIDEInputTouchPosition:
	var result := GUIDEInputTouchPosition.new()
	result.finger_count = finger_count
	result.finger_index = finger_index
	return result
	
func input_touch_distance()-> GUIDEInputTouchDistance:
	return GUIDEInputTouchDistance.new()

func input_touch_angle()-> GUIDEInputTouchAngle:
	return GUIDEInputTouchAngle.new()
	
func modifier_virtual_cursor(initial_position:Vector2 = Vector2(0.5, 0.5), \
		speed:Vector3=Vector3.ONE, \
		screen_scale:GUIDEModifierVirtualCursor.ScreenScale = GUIDEModifierVirtualCursor.ScreenScale.LONGER_AXIS, \
		apply_delta_time:bool = true
		) -> GUIDEModifierVirtualCursor:
	var result := GUIDEModifierVirtualCursor.new()
	result.initial_position = initial_position
	result.speed = speed
	result.screen_scale = screen_scale
	result.apply_delta_time = apply_delta_time
	return result
	
	
func modifier_input_swizzle(operation:GUIDEModifierInputSwizzle.GUIDEInputSwizzleOperation = \
		GUIDEModifierInputSwizzle.GUIDEInputSwizzleOperation.YXZ) -> GUIDEModifierInputSwizzle:
	var result := GUIDEModifierInputSwizzle.new()
	result.order = operation
	return result
	
	
func modifier_negate(x:bool = true, y:bool = true, z:bool = true) -> GUIDEModifierNegate:
	var result := GUIDEModifierNegate.new()
	result.x = x
	result.y = y
	result.z = z
	return result

	
func modifier_map_range(imin:float, imax:float, omin:float, omax:float, x:bool = true, y:bool = true, z:bool = true) -> \
	GUIDEModifierMapRange:
	var result := GUIDEModifierMapRange.new()
	result.input_min = imin
	result.input_max = imax
	result.output_min = omin
	result.output_max = omax
	result.x = x
	result.y = y
	result.z = z
	return result

func trigger_down() -> GUIDETriggerDown:
	return GUIDETriggerDown.new()
	
	
func trigger_pressed() -> GUIDETriggerPressed:
	return GUIDETriggerPressed.new()
	
@warning_ignore("shadowed_variable")
func trigger_chorded_action(action:GUIDEAction) -> GUIDETriggerChordedAction:
	var result := GUIDETriggerChordedAction.new()		
	result.action = action
	return result
		
		
@warning_ignore("shadowed_variable")
func map(context:GUIDEMappingContext, action:GUIDEAction, input:GUIDEInput, \
	modifiers:Array[GUIDEModifier] = [], triggers:Array[GUIDETrigger] = []) -> void:
	var action_mapping:GUIDEActionMapping = null
	
	for mapping in context.mappings:
		if mapping.action == action:
			action_mapping = mapping
			break
			
	if action_mapping == null:
		action_mapping = GUIDEActionMapping.new()
		action_mapping.action = action
		context.mappings.append(action_mapping)	
	
	var input_mapping := GUIDEInputMapping.new()
	input_mapping.input = input
	input_mapping.modifiers = modifiers
	input_mapping.triggers = triggers
	
	action_mapping.input_mappings.append(input_mapping)


#------------------ Input simulation ----------------------------------------

func mouse_down(button:MouseButton, wait:bool =  true) -> void:
	var input := InputEventMouseButton.new()
	input.button_index = button
	input.pressed= true
	input.position = get_viewport().get_mouse_position()
	Input.parse_input_event(input)
	print_f("Mouse down %s" % button)
	if wait:
		await wait_f(2)


func mouse_up(button:MouseButton, wait:bool =  true) -> void:
	var input := InputEventMouseButton.new()
	input.button_index = button
	input.pressed= false
	input.position = get_viewport().get_mouse_position()
	Input.parse_input_event(input)
	print_f("Mouse up %s" % button)
	if wait:
		await wait_f(2)


func tap_mouse(button:MouseButton) -> void:
	await mouse_down(button)
	await mouse_up(button)		

func tap_mouse_at(button:MouseButton, position:Vector2) -> void:
	await mouse_move_to(position)
	await tap_mouse(button)
		
func key_down(key:Key, wait:bool = true) -> void:
	var input := InputEventKey.new()
	input.physical_keycode = key
	input.pressed = true
	Input.parse_input_event(input)
	print_f("Key down %s" % OS.get_keycode_string(DisplayServer.keyboard_get_label_from_physical(key)))
	if wait:
		await wait_f(2)
	
func key_up(key:Key, wait:bool = true) -> void:
	var input := InputEventKey.new()
	input.physical_keycode = key
	input.pressed = false
	Input.parse_input_event(input)
	print_f("Key up %s" % OS.get_keycode_string(DisplayServer.keyboard_get_label_from_physical(key)))
	if wait:
		await wait_f(2)

func keys_down(keys:Array[Key], wait:bool = true) -> void:
	for key in keys:
		key_down(key, false)
		
	if wait:
		await wait_f(2)

func keys_up(keys:Array[Key], wait:bool = true) -> void:
	for key in keys:
		key_up(key, false)
		
	if wait:
		await wait_f(2)
	
	
func tap_key(key:Key) -> void:
	await key_down(key)
	await key_up(key)
	
	
func tap_keys(keys:Array[Key]) -> void:
	await keys_down(keys)
	await keys_up(keys)
	
	
func mouse_move_by(delta:Vector2, wait:bool = true) -> void:
	var pos := get_viewport().get_mouse_position() + delta
	
	if wait:
		await mouse_move_to(pos, true)
	else:
		mouse_move_to(pos, false)
		
		
		
## Moves the mouse to the given position in world coordinates.		
func mouse_move_to(position:Vector2, wait:bool = true) -> void:
	print_f("Mouse move to %s (from %s)" % [position, runner.get_global_mouse_position()])
	
	runner.simulate_mouse_move(position)
	
	if wait:
		await wait_f(2)

func joy_button_down(button:JoyButton, wait:bool = true) -> void:
	var input := InputEventJoypadButton.new()
	input.button_index = button
	input.pressed = true
	Input.parse_input_event(input)
	print_f("Joy button down %s" % button)
	if wait:
		await wait_f(2)
	
func joy_button_up(button:JoyButton, wait:bool = true) -> void:
	var input := InputEventJoypadButton.new()
	input.button_index = button
	input.pressed = false
	Input.parse_input_event(input)
	print_f("Joy button up %s" % button)
	if wait:
		await wait_f(2)
		
func tap_joy_button(button:JoyButton) -> void:
	await joy_button_down(button)
	await joy_button_up(button)
	
	
func joy_axis(axis:JoyAxis, value:float, wait:bool = true) -> void:
	var input := InputEventJoypadMotion.new()
	input.axis = axis
	input.axis_value = value
	Input.parse_input_event(input)
	print_f("Joy axis %s: %s" % [axis, value])
	if wait:
		await wait_f(2)
		
func finger_down(index:int, position:Vector2, wait:bool = true) -> void:
	var input := InputEventScreenTouch.new()
	input.index = index
	input.pressed = true
	input.position = position
	Input.parse_input_event(input)
	print_f("Finger down %s (%s)" % [index, position])
	if wait:
		await wait_f(2)
		
func finger_up(index:int, wait:bool = true) -> void:
	var input := InputEventScreenTouch.new()
	input.index = index
	input.pressed = false
	Input.parse_input_event(input)
	print_f("Finger up %s" % index)
	if wait:
		await wait_f(2)
		
		
func tap_finger(index:int, position:Vector2) -> void:
	await finger_down(index, position)
	await finger_up(index)
	
	
func finger_move(index:int, to:Vector2, wait:bool = true) -> void:
	var input := InputEventScreenDrag.new()
	input.index = index
	input.position = to
	print_f("Finger move %s (%s)" % [index, to])
	Input.parse_input_event(input)
	if wait:
		await wait_f(2)
	
		
func world_to_viewport(global_position:Vector2) -> Vector2:
	var final_transform := get_viewport().get_final_transform()
	return final_transform.basis_xform(global_position) + final_transform.origin

#------------------ Custom asserts -------------------------------------------

## Asserts that the given action has been triggered (emitted "triggered" signal).
@warning_ignore("shadowed_variable")
func assert_triggered(action:GUIDEAction) -> void:
	await assert_signal(action) \
		.append_failure_message("Action should be triggered but is not.") \
		.is_emitted("triggered")

	
## Asserts that the given action is currently reporting as triggered.
@warning_ignore("shadowed_variable")
func assert_is_triggered(action:GUIDEAction) -> void:
	assert_bool(action.is_triggered()) \
		.append_failure_message("Action should be triggered but is not.") \
		.is_true()


## Asserts that the given action has NOT been triggered (did NOT emit "triggered" signal).	
@warning_ignore("shadowed_variable")
func assert_not_triggered(action:GUIDEAction) -> void:
	await assert_signal(action) \
		.append_failure_message("Action should not be triggered but is.") \
		.is_not_emitted("triggered")
		

## Asserts that the given action is currently not reporting as triggered.
@warning_ignore("shadowed_variable")
func assert_is_not_triggered(action:GUIDEAction) -> void:
	assert_bool(action.is_triggered()) \
		.append_failure_message("Action should not be triggered but is.") \
		.is_false()


## Asserts that the given action has been completed (emitted "completed" signal).
@warning_ignore("shadowed_variable")
func assert_completed(action:GUIDEAction) -> void:
	await assert_signal(action) \
		.append_failure_message("Action should be triggered but is not.") \
		.is_emitted("completed")
	
	
## Asserts that the given action has NOT been completed (did NOT emit "completed" signal).	
@warning_ignore("shadowed_variable")
func assert_not_completed(action:GUIDEAction) -> void:
	await assert_signal(action) \
		.append_failure_message("Action should not be triggered but is.") \
		.is_not_emitted("completed")


## Asserts that the given action has the given axis 1D value.
@warning_ignore("shadowed_variable")
func assert_axis_1d(action:GUIDEAction, expected_value:float, deviation:float = 0.1) -> void:
	assert_float(action.value_axis_1d) \
		.append_failure_message("Action axis 1D value is not the expected value.") \
		.is_equal_approx(expected_value, deviation) 
		
		
## Asserts that the given action has the given axis 2D value.
@warning_ignore("shadowed_variable")
func assert_axis_2d(action:GUIDEAction, expected_value:Vector2, deviation:Vector2 = Vector2(1.0, 1.0)) -> void:
	assert_vector(action.value_axis_2d) \
		.append_failure_message("Action axis 2D value is not the expected value.") \
		.is_equal_approx(expected_value, deviation)


#------------------ Other stuff -------------------------------------------
func reset_signal_watcher(emitter:Variant) -> void:
	var collector := GdUnitThreadManager.get_current_context().get_signal_collector()
	var _collected_signals := collector._collected_signals
	if _collected_signals.has(emitter):
		var signals_by_emitter :Dictionary = _collected_signals[emitter]
		for signl:Variant in signals_by_emitter.keys():
			_collected_signals[emitter][signl] = []

@warning_ignore("shadowed_variable")
func log_signals(action:GUIDEAction) -> void:
	action.triggered.connect(func() -> void: print_f("action triggered: '%s' (%s)" % [action.name, action._value]))
	action.cancelled.connect(func() -> void: print_f("action cancelled: '%s'" % action.name))
	action.completed.connect(func() -> void: print_f("action completed: '%s'" % action.name))
	action.started.connect(func() -> void: print_f("action started: '%s'" % action.name))
	action.ongoing.connect(func() -> void: print_f("action ongoing: '%s'" % action.name))

func wait_f(frames:int) -> void:
	var start := get_f()
	while start + frames > get_f():
		var tree := get_tree()
		assert_object(tree)\
			.is_not_null()\
			.append_failure_message("Got no tree. Did you forget to add an await somewhere?")
		
		await get_tree().process_frame

func wait_seconds(seconds:float) -> void:
	await get_tree().create_timer(seconds).timeout

func print_f(text:Variant = "") -> void:
	print("[%s (%s)] %s" % [get_f(), Engine.get_process_frames(), text])

func get_f() -> int:
	return Engine.get_process_frames() - start_frame


