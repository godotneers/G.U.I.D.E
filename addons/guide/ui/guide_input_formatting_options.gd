class_name GUIDEInputFormattingOptions

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
	SONY_CONTROLLER = 3,
	## Used for Steam Deck controllers
	STEAM_DECK_CONTROLLER = 4,
}

## An input filter that shows all input. This is the default.
static var INPUT_FILTER_SHOW_ALL:Callable:
	# should be a const but Callables cannot be const, so we use a read-only static property.
	# Note: this is Variant here to avoid circular dependencies between GUIDEInputFormatter
	# and GUIDEInputFormattingOptions. Godot really doesn't like these.
	get: return func(_context:Variant) -> bool: return true

## A callable that allows for filtering which parts of an input are included in the
## formatted output. The callable takes a formatting context:
## [codeblock]
## options.input_filter = func(context:GUIDEInputFormatter.FormattingContext) -> bool:
##      # only show keyboard input
##     return context.input.device_type & GUIDEInput.DeviceType.KEYBOARD > 0
## [/codeblock]
## If the function returns true, then the given input will be shown in the formatted
## output, otherwise it will be ignored.
var input_filter:Callable = INPUT_FILTER_SHOW_ALL

## Determines how joy icons are rendered. 
var joy_rendering:JoyRendering = JoyRendering.DEFAULT

## The preferred Joy type for rendering Joy input. This setting only has effect if the 
## joy_rendering setting is set to something different than [code]DEFAULT[/code].  
var preferred_joy_type:JoyType = JoyType.GENERIC_JOY

