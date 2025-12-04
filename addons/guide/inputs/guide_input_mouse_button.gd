@tool
class_name GUIDEInputMouseButton
extends GUIDEInput

@export var button: MouseButton = MOUSE_BUTTON_LEFT:
	set(value):
		if value == button:
			return
		button = value
		emit_changed()

# The value that this input will be reset to at the end of the frame.
var _reset_to: Vector3
var _was_pressed_this_frame: bool


func _needs_reset() -> bool:
	# mouse wheel up and down can potentially send multiple inputs within a single frame
	# so we need to smooth this out a bit.
	return button == MOUSE_BUTTON_WHEEL_UP or button == MOUSE_BUTTON_WHEEL_DOWN


func _reset() -> void:
	_was_pressed_this_frame = false
	_value = _reset_to


func _begin_usage() -> void:
	# subscribe to mouse button events
	_state.mouse_button_state_changed.connect(_refresh)
	_refresh()


func _end_usage() -> void:
	# unsubscribe from mouse button events
	_state.mouse_button_state_changed.disconnect(_refresh)


func _refresh() -> void:
	var is_pressed: bool = _state.is_mouse_button_pressed(button)

	if _needs_reset():
		# we always reset to the last event we received in a frame
		# so after the frame is over we're still in sync.
		_reset_to.x =  1.0 if is_pressed else 0.0

		if is_pressed:
			_was_pressed_this_frame = true

		if not is_pressed and _was_pressed_this_frame:
			# keep pressed state for this frame
			return

	_value.x = 1.0 if is_pressed else 0.0


func is_same_as(other: GUIDEInput) -> bool:
	return other is GUIDEInputMouseButton and other.button == button


func _to_string() -> String:
	return "(GUIDEInputMouseButton: button=" + str(button) + ")"


func _editor_name() -> String:
	return "Mouse Button"


func _editor_description() -> String:
	return "A press of a mouse button. The mouse wheel is also a button."


func _native_value_type() -> GUIDEAction.GUIDEActionValueType:
	return GUIDEAction.GUIDEActionValueType.BOOL

func _device_type() -> DeviceType:
	return DeviceType.MOUSE
