class_name GUIDEInputFormattingOptions

## Device types. Can be used to only render output for certain devices.
enum DeviceType {
	KEYBOARD = 1,
	MOUSE = 2,
	JOY = 4,
	TOUCH = 8,
	ALL = 15,
}

## Options for rendering joy icons. 
enum JoyRendering {
	## Renders by detecting the joy type and uses the appropriate icon set for this joy type.  
	DEFAULT = 0,
	
	## Renders by detecting the joy type but uses the preferred joy type, if it cannot be detected. 
	PREFER_JOY_TYPE = 1,
	
	## Always renders joy input using the preferred joy type, no matter which type is detected.
	FORCE_JOY_TYPE = 2,
}

## Supported joy types
enum JoyType {
	## Used for joysticks which are not controllers or as a fallback if no controller
	## type can be determined.
	GENERIC_JOY = 0,
	## Used for Microsoft controllers (e.g. XBox). 
	MICROSOFT_CONTROLLER = 1,
	## Used for Nintendo controllers (e.g. Switch). 
	NINTENDO_CONTROLLER = 2,
	## Used for Sony controllers (e.g. PlayStation). 
	SONY_CONTROLLER = 3
}


## Limits for which devices input is rendered. By default renders input for all device types. You 
## can combine the device types using bitwise operation.
##
## [codeblock]
## var options := GUIDEInputFormattingOptions.new()
## options.only_device_types = \
##     GUIDEInputFormattingOptions.KEYBOARD | GUIDEInputFormattingOptions.MOUSE
## [/codeblock]
var only_device_types:DeviceType = DeviceType.ALL

## Determines how joy icons are rendered. 
var joy_rendering:JoyRendering = JoyRendering.DEFAULT

## The preferred Joy type for rendering Joy input. This setting only has effect if the 
## joy_rendering setting is set to something different than [code]DEFAULT[/code].  
var preferred_joy_type:JoyType = JoyType.GENERIC_JOY

