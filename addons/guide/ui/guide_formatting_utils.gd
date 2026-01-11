@tool
## Helper functions for icon renderers and text providers

## Supported controller types.
enum ControllerType {
	UNKNOWN = 0,
	MICROSOFT = 1,
	NINTENDO = 2,
	SONY = 3,
	STEAM_DECK = 4,
}

## Detection strings for the controller types. The key is the controller type, the value is an 
## array of detection strings. All detection strings are case-insensitive. 
static var _controller_detection_strings:Dictionary = {
	ControllerType.MICROSOFT: ["XBox", "XInput"],
	ControllerType.NINTENDO: ["Nintendo Switch"],
	ControllerType.SONY : ["DualSense", "DualShock", "PlayStation", "PS3", "PS4", "PS5"],
	ControllerType.STEAM_DECK: ["Steam Deck"]
} 


## Determines the effective controller type from the input and formatting options.
static func effective_controller_type(input:GUIDEInput, options:GUIDEInputFormattingOptions) -> ControllerType:
	# only joy input can be a controller input
	if not (input is GUIDEInputJoyBase):
		return ControllerType.UNKNOWN

	# If the options force a specific joy type, we use that. 
	if options.joy_rendering == GUIDEInputFormattingOptions.JoyRendering.FORCE_JOY_TYPE:
		return _controller_type_from_joy_type(options.preferred_joy_type)

	# If the options use a fallback, then we try to detect and only use the fallback 
	# if we couldn't detect the controller type. 			
	var controller_type = _detect_controller_type(input)

	if options.joy_rendering == GUIDEInputFormattingOptions.JoyRendering.PREFER_JOY_TYPE:
		if controller_type == ControllerType.UNKNOWN:
			return _controller_type_from_joy_type(options.preferred_joy_type)

	# otherwise return what we have detected
	return controller_type

## Detects the actual controller type of the controller related to the given input. 
## Uses the controller detection strings.
static func _detect_controller_type(input:GUIDEInput) -> ControllerType:
	var haystack = _joy_name_for_input(input).to_lower()
	
	if haystack == "":
		return ControllerType.UNKNOWN
			
	for type:ControllerType in _controller_detection_strings.keys():
		var strings:Array = _controller_detection_strings[type]
		for needle:String in strings:
			if haystack.contains(needle.to_lower()):
				return type
				
	return ControllerType.UNKNOWN


## Returns the matching controller type from the given joy type. 
static func _controller_type_from_joy_type(joy_type:GUIDEInputFormattingOptions.JoyType) -> ControllerType:
	match joy_type:
		GUIDEInputFormattingOptions.JoyType.MICROSOFT_CONTROLLER:
			return ControllerType.MICROSOFT
		GUIDEInputFormattingOptions.JoyType.NINTENDO_CONTROLLER:
			return ControllerType.NINTENDO
		GUIDEInputFormattingOptions.JoyType.SONY_CONTROLLER:
			return ControllerType.SONY
		GUIDEInputFormattingOptions.JoyType.STEAM_DECK_CONTROLLER:
			return ControllerType.STEAM_DECK
		
			
	return ControllerType.UNKNOWN


## Returns the name of the associated joystick/pad of the given input.
## If the input is no joy input or the device name cannot be determined
## returns an empty string. 
static func _joy_name_for_input(input:GUIDEInput) -> String:
	if not input is GUIDEInputJoyBase:
		return ""
	
	var joypads:Array[int] = Input.get_connected_joypads()
	var joy_index:int = input.joy_index
	if joy_index < 0:
		# pick the first one
		joy_index = 0
	
	# We don't have such a controller, so bail out.
	if joypads.size() <= joy_index:
		return "" 
		
	var id := joypads[joy_index]
	return Input.get_joy_name(id)	
