## Tracker that tracks input for a window and injects it into GUIDE.
## Will automatically keep track of sub-windows.
extends Node

## Instruments a sub-window so it forwards input events to GUIDE.
static func _instrument(viewport:Viewport):
	if viewport.has_meta("_x_guide_instrumented"):
		return
	
	var tracker = preload("guide_input_tracker.gd").new()
	tracker.process_mode = Node.PROCESS_MODE_ALWAYS
	viewport.add_child(tracker, false, Node.INTERNAL_MODE_BACK)
	viewport.gui_focus_changed.connect(tracker._control_focused)
	viewport.set_meta("_x_guide_instrumented", true)
	
## Catches unhandled input and forwards it to GUIDE
func _unhandled_input(event:InputEvent):
	GUIDE.inject_input(event)

## Some ... creative code ... to catch events from popup windows
## that are spawned by Godot's control nodes.
func _control_focused(control:Control):
	if control is OptionButton or control is ColorPickerButton \
			or control is MenuButton or control is TabContainer:
		var popup:Viewport = control.get_popup()
		if is_instance_valid(popup):
			_instrument(popup)	
	
	
