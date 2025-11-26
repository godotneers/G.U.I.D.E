@tool
class_name GUIDEControllerTextProvider
extends GUIDETextProvider

const GUIDEFormattingUtils = preload("../../guide_formatting_utils.gd")
const ControllerType = GUIDEFormattingUtils.ControllerType

## Label sets that are used for each controller type. Key is controller type,
## value is the label set.
static var _controller_label_sets:Dictionary = {
	ControllerType.MICROSOFT: preload("label_sets/microsoft.tres"),
	ControllerType.NINTENDO: preload("label_sets/nintendo.tres"),
	ControllerType.SONY: preload("label_sets/sony.tres"),
}

func _init():
	priority = -10
	
	
## Sets the label set that is used for providing texts of the given controller type. 
## Note that label sets are currently experimental and may disappear without notice.	
static func set_label_set(type:ControllerType, label_set:GUIDEControllerLabelSet) -> void:
	if not is_instance_valid(label_set):
		push_error("Label set must not be null.")
		return
	
	if type == ControllerType.UNKNOWN:
		push_error("Cannot set label set for the unknown controller. Use GUIDEInputFormattingOptions to set up how unknown controllers are rendered.")	
		return
		
	_controller_label_sets[type] = label_set
	
func supports(input:GUIDEInput, options:GUIDEInputFormattingOptions) -> bool:
	# we support rendering if the input effectively can be mapped to any known
	# controller type using the options
	return GUIDEFormattingUtils.effective_controller_type(input, options) != ControllerType.UNKNOWN


func _format(input:String) -> String:
	return "[%s]" % [input]

	
func get_text(input:GUIDEInput, options:GUIDEInputFormattingOptions) -> String:
	var controller_type := GUIDEFormattingUtils.effective_controller_type(input, options)
	
	var label_set:GUIDEControllerLabelSet = _controller_label_sets[controller_type]
	
	if input is GUIDEInputJoyAxis1D:
		match input.axis:
			JOY_AXIS_LEFT_X:
				return _format(tr(label_set.left_stick_horizontal_movement))
			JOY_AXIS_LEFT_Y:
				return _format(tr(label_set.left_stick_vertical_movement))
			JOY_AXIS_RIGHT_X:
				return _format(tr(label_set.right_stick_horizontal_movement))
			JOY_AXIS_RIGHT_Y:
				return _format(tr(label_set.right_stick_vertical_movement))
			JOY_AXIS_TRIGGER_LEFT:
				return _format(tr(label_set.left_trigger))
			JOY_AXIS_TRIGGER_RIGHT:
				return _format(tr(label_set.right_trigger))
	
	if input is GUIDEInputJoyAxis2D:
		match input.x:
			JOY_AXIS_LEFT_X, JOY_AXIS_LEFT_Y:
				return _format(tr(label_set.left_stick))
			JOY_AXIS_RIGHT_X, JOY_AXIS_RIGHT_Y:
				return _format(tr(label_set.right_stick))
				
	if input is GUIDEInputJoyButton:
		match input.button:
			JOY_BUTTON_A:
				return _format(tr(label_set.a_button))
			JOY_BUTTON_B:
				return _format(tr(label_set.b_button))
			JOY_BUTTON_X:
				return _format(tr(label_set.x_button))
			JOY_BUTTON_Y:
				return _format(tr(label_set.y_button))
			JOY_BUTTON_DPAD_LEFT:
				return _format(tr(label_set.dpad_left))
			JOY_BUTTON_DPAD_RIGHT:
				return _format(tr(label_set.dpad_right))
			JOY_BUTTON_DPAD_UP:
				return _format(tr(label_set.dpad_up))
			JOY_BUTTON_DPAD_DOWN:
				return _format(tr(label_set.dpad_down))
			JOY_BUTTON_LEFT_SHOULDER:
				return _format(tr(label_set.left_bumper))	
			JOY_BUTTON_RIGHT_SHOULDER:
				return _format(tr(label_set.right_bumper))	
			JOY_BUTTON_LEFT_STICK:
				return _format(tr(label_set.left_stick_click))	
			JOY_BUTTON_RIGHT_STICK:
				return _format(tr(label_set.right_stick_click))	
			JOY_BUTTON_BACK:
				return _format(tr(label_set.back))
			JOY_BUTTON_MISC1:
				return _format(tr(label_set.misc1))
			JOY_BUTTON_START:
				return _format(tr(label_set.start))	
			JOY_BUTTON_TOUCHPAD:
				return _format(tr(label_set.touch_pad))	

	return _format("??")
