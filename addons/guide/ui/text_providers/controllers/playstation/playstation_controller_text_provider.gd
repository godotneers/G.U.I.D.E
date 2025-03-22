extends "res://addons/guide/ui/text_providers/controllers/controller_text_provider.gd"

func _controller_names() -> Array[String]:
	return ["DualSense Wireless Controller", "Playstation", "PS3", "PS4", "PS5"]	
	
func _a_button_name() -> String:
	return "Cross"

func _b_button_name() -> String:
	return "Circle"

func _x_button_name() -> String:
	return "Square"

func _y_button_name() -> String:
	return "Triangle"

func _left_bumper_name() -> String:
	return "L1"

func _right_bumper_name() -> String:
	return "R1"

func _left_trigger_name() -> String:
	return "L2"

func _right_trigger_name() -> String:
	return "R2"

func _back_button_name() -> String:
	return "Share"

func _misc_1_button_name() -> String:
	return "Microphone"

func _start_button_name() -> String:
	return "Options"
