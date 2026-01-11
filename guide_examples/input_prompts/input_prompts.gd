extends Node2D

const InstructionsLabel = preload("../shared/instructions_label.gd")
const DeviceType = GUIDEInput.DeviceType
const JoyRendering = GUIDEInputFormattingOptions.JoyRendering
const JoyType = GUIDEInputFormattingOptions.JoyType

@export var mapping_context:GUIDEMappingContext
@export var fire:GUIDEAction
@export var controller_activated:GUIDEAction
@export var mouse_activated:GUIDEAction
@export var keyboard_activated:GUIDEAction

@onready var label: InstructionsLabel = %Label
@onready var gpu_particles_2d: GPUParticles2D = %GPUParticles2D

var _render_all_devices:bool = true
var _current_device_type:DeviceType = DeviceType.MOUSE 
var _formatter:GUIDEInputFormatter

func _ready() -> void:
	GUIDE.enable_mapping_context(mapping_context)
	# get the formatter from the label. technically a hack, but this is just an example
	# on how to use the formatter
	_formatter = label._formatter
	label._update_instructions()
	
	controller_activated.triggered.connect(_on_device_activated.bind(DeviceType.JOY))
	mouse_activated.triggered.connect(_on_device_activated.bind(DeviceType.MOUSE))
	keyboard_activated.triggered.connect(_on_device_activated.bind(DeviceType.KEYBOARD))
	fire.triggered.connect(func() -> void: gpu_particles_2d.emitting = true)
	fire.completed.connect(func() -> void: gpu_particles_2d.emitting = false)
	
	
## Called when the device selection is changed. Shows either input for all devices
## or the last activated device, depending on selection.
func _on_device_selection_item_selected(index: int) -> void:
	# option button only has 2 entries, so if it's the second one we limit the 
	# device type
	if index == 0:
		_formatter.formatting_options.input_filter = GUIDEInputFormattingOptions.INPUT_FILTER_SHOW_ALL
		_render_all_devices = true
	else:
		_formatter.formatting_options.input_filter = _filter_current_device_type
		_render_all_devices = false
	label._update_instructions()

## Called when the controller type is changed. Shows either detected controller icons or
## forced controller icons depending on selection.
func _on_controller_type_override_item_selected(index: int) -> void:
	match index:
		0:
			_formatter.formatting_options.joy_rendering = JoyRendering.DEFAULT
		1:
			_formatter.formatting_options.joy_rendering = JoyRendering.FORCE_JOY_TYPE
			_formatter.formatting_options.preferred_joy_type = JoyType.MICROSOFT_CONTROLLER
		2:
			_formatter.formatting_options.joy_rendering = JoyRendering.FORCE_JOY_TYPE
			_formatter.formatting_options.preferred_joy_type = JoyType.NINTENDO_CONTROLLER
		3:
			_formatter.formatting_options.joy_rendering = JoyRendering.FORCE_JOY_TYPE
			_formatter.formatting_options.preferred_joy_type = JoyType.SONY_CONTROLLER
		4:
			_formatter.formatting_options.joy_rendering = JoyRendering.FORCE_JOY_TYPE
			_formatter.formatting_options.preferred_joy_type = JoyType.STEAM_DECK_CONTROLLER		
	label._update_instructions()
			
			
## Called when a certain device is activated. Depending on the mode
## updates the rendering to only show the last activated device.	
func _on_device_activated(type:DeviceType) -> void:
	_current_device_type = type
	if not _render_all_devices:
		_formatter.formatting_options.input_filter = _filter_current_device_type
	
	label._update_instructions()

## Filter function which filters the input and only shows input from the current
## device type.
func _filter_current_device_type(context:GUIDEInputFormatter.FormattingContext) -> bool:
	# check if there is an overlap between the input device type and the current device type
	return context.input.device_type & _current_device_type > 0
