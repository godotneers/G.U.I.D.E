extends GUIDETextProvider

var _is_on_desktop:bool = false

func _init():
	priority = 0
	_is_on_desktop = OS.has_feature("linuxbsd") or OS.has_feature("macos") or OS.has_feature("windows")
	
func supports(input:GUIDEInput) -> bool:
	return true
	

func _format(input:String) -> String:
	return "[%s]" % [input]

	
func get_text(input:GUIDEInput) -> String:
	if input is GUIDEInputKey:
		var result:PackedStringArray = []
		if input.control:
			var ctrl = GUIDEInputKey.new()
			ctrl.key = KEY_CTRL
			result.append(get_text(ctrl))
		if input.alt:
			var alt = GUIDEInputKey.new()
			alt.key = KEY_ALT
			result.append(get_text(alt))
		if input.shift:
			var shift = GUIDEInputKey.new()
			shift.key = KEY_SHIFT
			result.append(get_text(shift))
		if input.meta:
			var meta = GUIDEInputKey.new()
			meta.key = KEY_META
			result.append(get_text(meta))
		
		var the_key = input.key
		
		# if we are on desktop, translate the physical keycode into the actual label
		# this is not supported on mobile, so we have to check		
		if _is_on_desktop:
			the_key = DisplayServer.keyboard_get_label_from_physical(input.key)
			
		
		result.append(_format(OS.get_keycode_string(the_key)))
		return "+".join(result) 
	
	if input is GUIDEInputMouseAxis1D:
		match input.axis:
			GUIDEInputMouseAxis1D.GUIDEInputMouseAxis.X:
				return _format(tr("Mouse Left/Right"))
			GUIDEInputMouseAxis1D.GUIDEInputMouseAxis.Y:
				return _format(tr("Mouse Up/Down"))

	if input is GUIDEInputMouseAxis2D:
		return _format(tr("Mouse"))
		
	if input is GUIDEInputMouseButton:
		match input.button:
			MOUSE_BUTTON_LEFT:
				return _format(tr("Left Mouse Button"))
			MOUSE_BUTTON_RIGHT:
				return _format(tr("Right Mouse Button"))
			MOUSE_BUTTON_MIDDLE:
				return _format(tr("Middle Mouse Button"))
			MOUSE_BUTTON_WHEEL_UP:
				return _format(tr("Mouse Wheel Up"))
			MOUSE_BUTTON_WHEEL_DOWN:
				return _format(tr("Mouse Wheel Down"))
			MOUSE_BUTTON_WHEEL_LEFT:
				return _format(tr("Mouse Wheel Left"))
			MOUSE_BUTTON_WHEEL_RIGHT:
				return _format(tr("Mouse Wheel Right"))
			MOUSE_BUTTON_XBUTTON1:
				return _format(tr("Mouse Side 1"))
			MOUSE_BUTTON_XBUTTON2:
				return _format(tr("Mouse Side 2"))

	if input is GUIDEInputJoyAxis1D:
		match input.axis:
			JOY_AXIS_LEFT_X:
				return _format(tr("Stick 1 Horizontal"))
			JOY_AXIS_LEFT_Y:
				return _format(tr("Stick 1 Vertical"))
			JOY_AXIS_RIGHT_X:
				return _format(tr("Stick 2 Horizontal"))
			JOY_AXIS_RIGHT_Y:
				return _format(tr("Stick 2 Vertical"))
			JOY_AXIS_TRIGGER_LEFT:
				return _format(tr("Axis 3"))
			JOY_AXIS_TRIGGER_RIGHT:
				return _format(tr("Axis 4"))
	
	if input is GUIDEInputJoyAxis2D:
		match input.x:
			JOY_AXIS_LEFT_X, JOY_AXIS_LEFT_Y:
				return _format(tr("Stick 1"))
			JOY_AXIS_RIGHT_X, JOY_AXIS_RIGHT_Y:
				return _format(tr("Stick 2"))
				
	if input is GUIDEInputJoyButton:
		return _format(tr("Joy %s") % [input.button])
		
		
	if input is GUIDEInputAction:
		return _format(tr("Action %s") % ["?" if input.action == null else input.action._editor_name()])

	if input is GUIDEInputAny:
		var parts:Array[String] = []
		if input.joy:
			parts.append(tr("Joy Button"))
		if input.mouse:
			parts.append(tr("Mouse Button"))
		if input.keyboard:
			parts.append(tr("Key"))
			
		return _format(tr("Any %s") % [ "/".join(parts) ] )
			
	if input is GUIDEInputMousePosition:
		return _format(tr("Mouse Position"))
		
	if input is GUIDEInputTouchPosition:
		return _format(tr("Touch Position %s") % [input.finger_index  if input.finger_index >= 0 else "Average"])

	if input is GUIDEInputTouchAngle:
		return _format(tr("Touch Angle"))
		
	if input is GUIDEInputTouchDistance:
		return _format(tr("Touch Distance"))

	if input is GUIDEInputTouchAxis1D:
		match input.axis:
			GUIDEInputTouchAxis1D.GUIDEInputTouchAxis.X:
				return _format(tr("Touch Left/Right %s") % [input.finger_index  if input.finger_index >= 0 else "Average"])
			GUIDEInputTouchAxis1D.GUIDEInputTouchAxis.Y:
				return _format(tr("Touch Up/Down %s") % [input.finger_index  if input.finger_index >= 0 else "Average"])
	
	if input is GUIDEInputTouchAxis2D:
		return _format(tr("Touch Axis 2D %s") % [input.finger_index  if input.finger_index >= 0 else "Average"])

	return _format("??")
