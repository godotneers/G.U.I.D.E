@tool
extends Window

const ClassScanner = preload("../class_scanner.gd")
const Utils = preload("../utils.gd")

signal input_selected(input:GUIDEInput)

@onready var _input_display = %InputDisplay
@onready var _available_types:Container = %AvailableTypes
@onready var _none_available:Control = %NoneAvailable
@onready var _some_available:Control = %SomeAvailable
@onready var _select_bool_button:Button = %SelectBoolButton
@onready var _select_1d_button:Button = %Select1DButton
@onready var _select_2d_button:Button = %Select2DButton
@onready var _select_3d_button:Button = %Select3DButton
@onready var _instructions_label:Label = %InstructionsLabel
@onready var _accept_detection_button:Button = %AcceptDetectionButton
@onready var _cancel_detection_button = %CancelDetectionButton
@onready var _input_detector:GUIDEInputDetector = %InputDetector
@onready var _detect_bool_button:Button = %DetectBoolButton
@onready var _detect_1d_button:Button = %Detect1DButton
@onready var _detect_2d_button:Button = %Detect2DButton
@onready var _detect_3d_button:Button = %Detect3DButton

var _scanner:ClassScanner
var _last_detected_input:GUIDEInput
var _detection_cancelled: bool = false

	
func initialize(scanner:ClassScanner):
	_scanner = scanner
	_setup_dialog()
	
func _setup_dialog():
	# we need to bind this here. if we bind it in the editor, the editor
	# will crash when opening the scene because it will delete the node it
	# just tries to edit.
	focus_exited.connect(_on_close_requested)
	
	_show_inputs_of_value_type(GUIDEAction.GUIDEActionValueType.BOOL)
	_instructions_label.text = tr("Press one of the buttons above to detect an input.")
	_accept_detection_button.visible = false
	_cancel_detection_button.visible = false

	

func _on_close_requested():
	hide()
	queue_free()


func _show_inputs_of_value_type(type:GUIDEAction.GUIDEActionValueType) -> void:
	var items:Array[GUIDEInput] = []
	
	_select_bool_button.set_pressed_no_signal(type == GUIDEAction.GUIDEActionValueType.BOOL)
	_select_1d_button.set_pressed_no_signal(type == GUIDEAction.GUIDEActionValueType.AXIS_1D)
	_select_2d_button.set_pressed_no_signal(type == GUIDEAction.GUIDEActionValueType.AXIS_2D)
	_select_3d_button.set_pressed_no_signal(type == GUIDEAction.GUIDEActionValueType.AXIS_3D)
	
	var all_inputs = _scanner.find_inheritors("GUIDEInput")
	for script in all_inputs.values():
		var dummy:GUIDEInput = script.new()
		if dummy._native_value_type() == type:
			items.append(dummy)
			
	_some_available.visible = not items.is_empty()
	_none_available.visible = items.is_empty()
	
	if items.is_empty():
		return
		
	items.sort_custom(func(a,b): return a._editor_name().nocasecmp_to(b._editor_name()) < 0)
	Utils.clear(_available_types)
	
	for item in items:
		var button = Button.new()
		button.text = item._editor_name()
		button.tooltip_text = item._editor_description()
		button.pressed.connect(_deliver.bind(item))	
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		
		_available_types.add_child(button)	
		
	
func _deliver(input:GUIDEInput):
	input_selected.emit(input)
	hide()
	queue_free()


func _on_select_bool_button_pressed():
	_show_inputs_of_value_type(GUIDEAction.GUIDEActionValueType.BOOL)


func _on_select_1d_button_pressed():
	_show_inputs_of_value_type(GUIDEAction.GUIDEActionValueType.AXIS_1D)


func _on_select_2d_button_pressed():
	_show_inputs_of_value_type(GUIDEAction.GUIDEActionValueType.AXIS_2D)


func _on_select_3d_button_pressed():
	_show_inputs_of_value_type(GUIDEAction.GUIDEActionValueType.AXIS_3D)


func _on_input_detector_detection_started():
	_instructions_label.text = tr("Actuate the input now...")


func _on_input_detector_input_detected(input:GUIDEInput):
	if input == null or _detection_cancelled:
		_detection_cancelled = false
		return

	_instructions_label.visible = false
	_input_display.visible = true
	_input_display.input = input
	_accept_detection_button.visible = true
	_cancel_detection_button.visible = false
	_last_detected_input = input


func _begin_detect_input(type:GUIDEAction.GUIDEActionValueType):
	_last_detected_input = null
	_instructions_label.visible = true
	_instructions_label.text = tr("Get ready...")
	_accept_detection_button.visible = false
	_cancel_detection_button.visible = true
	_input_display.visible = false
	_input_detector.detect(type)
	
func _end_detect_input():
	_input_detector.abort_detection()
	_detection_cancelled = true
	_instructions_label.text = tr("Press one of the buttons above to detect an input.")

func _on_detect_bool_button_pressed():
	_detect_bool_button.release_focus()
	_begin_detect_input(GUIDEAction.GUIDEActionValueType.BOOL)


func _on_detect_1d_button_pressed():
	_detect_1d_button.release_focus()
	_begin_detect_input(GUIDEAction.GUIDEActionValueType.AXIS_1D)


func _on_detect_2d_button_pressed():
	_detect_2d_button.release_focus()
	_begin_detect_input(GUIDEAction.GUIDEActionValueType.AXIS_2D)


func _on_detect_3d_button_pressed():
	_detect_3d_button.release_focus()
	_begin_detect_input(GUIDEAction.GUIDEActionValueType.AXIS_3D)
	

func _on_accept_detection_button_pressed():
	input_selected.emit(_last_detected_input)
	hide()
	queue_free
