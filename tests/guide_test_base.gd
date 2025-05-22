class_name GUIDETestBase
extends GdUnitTestSuite

#------------------- Lifecycle ---------------------------------------------
var start_frame:int = 0

func after_test():
	# Clear all mapping contexts after each test
	for context in GUIDE._active_contexts:
		GUIDE.disable_mapping_context(context)

func before_test():
	start_frame = Engine.get_process_frames()
	GUIDE._input_state._clear()
	_setup()	
	print("-----------------------------------")
	
func _setup():
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
	
func input_touch_axis_1d(axis:GUIDEInputTouchAxis1D.GUIDEInputTouchAxis) -> GUIDEInputTouchAxis1D:
	var result := GUIDEInputTouchAxis1D.new()
	result.axis = axis
	return result
	
func input_touch_axis_2d() -> GUIDEInputTouchAxis2D:
	return GUIDEInputTouchAxis2D.new()
	

func input_touch_position(index:int = 0, finger_count:int = 1)-> GUIDEInputTouchPosition:
	var result := GUIDEInputTouchPosition.new()
	result.finger_count = finger_count
	result.finger_index = index
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

func modifier_accumulator(start_value:float = 0.0, \
		end_value:float = 1.0, \
		time:float = 1.0, \
		decrease_multiplier:float = 1.0, \
		decrease_condition:GUIDEModifierAccumulator.DecreaseCondition = GUIDEModifierAccumulator.DecreaseCondition.DECREASE_ON_RELEASE, \
		ready_condition:GUIDEModifierAccumulator.ReadyCondition = GUIDEModifierAccumulator.ReadyCondition.ALWAYS, \
		input_axis:GUIDEModifierAccumulator.InputAxis = GUIDEModifierAccumulator.InputAxis.X, \
		x:GUIDEModifierAccumulator.AxisRole = GUIDEModifierAccumulator.AxisRole.VALUE, \
		y:GUIDEModifierAccumulator.AxisRole = GUIDEModifierAccumulator.AxisRole.UNCHANGED, \
		z:GUIDEModifierAccumulator.AxisRole = GUIDEModifierAccumulator.AxisRole.UNCHANGED, \
		apply_clamp:bool = true
		) -> GUIDEModifierAccumulator:
	var result := GUIDEModifierAccumulator.new()
	result.start_value = start_value
	result.end_value = end_value
	result.time = time
	result.input_axis = input_axis
	result.decrease_multiplier = decrease_multiplier
	result.ready_condition = ready_condition
	result.decrease_condition = decrease_condition
	result.x = x
	result.y = y
	result.z = z
	result.apply_clamp = apply_clamp
	return result

func trigger_down() -> GUIDETriggerDown:
	return GUIDETriggerDown.new()
	
		
@warning_ignore("shadowed_variable")
func map(context:GUIDEMappingContext, action:GUIDEAction, input:GUIDEInput, \
	modifiers:Array[GUIDEModifier] = [], triggers:Array[GUIDETrigger] = []):
	var action_mapping:GUIDEActionMapping = null
	
	for mapping in context.mappings:
		if mapping.action == action:
			action_mapping = mapping
			break
			
	if action_mapping == null:
		action_mapping = GUIDEActionMapping.new()
		action_mapping.action = action
		context.mappings.append(action_mapping)	
	
	var input_mapping = GUIDEInputMapping.new()
	input_mapping.input = input
	input_mapping.modifiers = modifiers
	input_mapping.triggers = triggers
	
	action_mapping.input_mappings.append(input_mapping)
		
	
#------------------ Input simulation ----------------------------------------

func mouse_down(button:MouseButton, wait:bool =  true) -> void:
	var input := InputEventMouseButton.new()
	input.button_index = button
	input.pressed= true
	Input.parse_input_event(input)
	print_f("Mouse down %s" % button)
	if wait:
		await wait_f(2)


func mouse_up(button:MouseButton, wait:bool =  true) -> void:
	var input = InputEventMouseButton.new()
	input.button_index = button
	input.pressed= false
	Input.parse_input_event(input)
	print_f("Mouse up %s" % button)
	if wait:
		await wait_f(2)


func tap_mouse(button:MouseButton) -> void:
	await mouse_down(button)
	await mouse_up(button)		

		
func key_down(key:Key, wait:bool = true) -> void:
	var input = InputEventKey.new()
	input.physical_keycode = key
	input.pressed = true
	Input.parse_input_event(input)
	print_f("Key down %s" % OS.get_keycode_string(DisplayServer.keyboard_get_label_from_physical(key)))
	if wait:
		await wait_f(2)
	
func key_up(key:Key, wait:bool = true) -> void:
	var input = InputEventKey.new()
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
	
func mouse_move(delta:Vector2, wait:bool = true) -> void:
	var event := InputEventMouseMotion.new()
	event.relative = delta
	print_f("Mouse move %s" % delta)
	Input.parse_input_event(event)
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
	print_f("Joy axis %s" % axis)
	if wait:
		await wait_f(2)
		
func finger_down(index:int, position:Vector2, wait:bool = true) -> void:
	var input := InputEventScreenTouch.new()
	input.index = index
	input.pressed = true
	input.position = position
	Input.parse_input_event(input)
	print_f("Finger down %s" % index)
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
	print_f("Finger move %s" % to)
	Input.parse_input_event(input)
	if wait:
		await wait_f(2)

#------------------ Custom asserts -------------------------------------------

@warning_ignore("shadowed_variable")
func assert_triggered(action:GUIDEAction):
	await assert_signal(action) \
		.append_failure_message("Action should be triggered but is not.") \
		.is_emitted("triggered")
	
@warning_ignore("shadowed_variable")
func assert_not_triggered(action:GUIDEAction):
	await assert_signal(action) \
		.append_failure_message("Action should not be triggered but is.") \
		.is_not_emitted("triggered")


#------------------ Other stuff -------------------------------------------
@warning_ignore("shadowed_variable")
func log_signals(action:GUIDEAction):
	action.triggered.connect(print_f.bind("action triggered: '%s'" % action.name))
	action.cancelled.connect(print_f.bind("action cancelled: '%s'" % action.name))
	action.completed.connect(print_f.bind("action completed: '%s'" % action.name))
	action.started.connect(print_f.bind("action started: '%s'" % action.name))
	action.ongoing.connect(print_f.bind("action ongoing: '%s'" % action.name))

func wait_f(frames:int):
	var start = get_f()
	while start + frames > get_f():
		var tree = get_tree()
		assert_object(tree)\
			.is_not_null()\
			.append_failure_message("Got no tree. Did you forget to add an await somewhere?")
		
		await get_tree().process_frame

func wait_seconds(seconds:float):
	await get_tree().create_timer(seconds).timeout

func print_f(text:Variant = ""):
	print("[%s] %s" % [get_f(), text])

func get_f() -> int:
	return Engine.get_process_frames() - start_frame
