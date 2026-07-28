# Tests the input formatter.
extends GUIDETestBase

# we make a high priority default provider so it doesn't matter which device
# is currently connected, we always get the default strings.	
class DefaultProvider:
	extends GUIDEInputFormatter.DefaultTextProvider
	
	func _init() -> void:
		super()
		priority = -100	
	
var _context:GUIDEMappingContext
var _action:GUIDEAction
var _formatter:GUIDEInputFormatter


func _setup() -> void:
	_formatter = GUIDEInputFormatter.for_active_contexts()
	GUIDEInputFormatter.add_text_provider(DefaultProvider.new())
	_context = mapping_context()
	_action = action_bool()	
	
	
func _filter_keyboard() -> void:
	_formatter.formatting_options.input_filter = func(context:GUIDEInputFormatter.FormattingContext) -> bool:
		# only show keyboard input
		return context.input.device_type & GUIDEInput.DeviceType.KEYBOARD > 0

func _filter_joy() -> void:
	_formatter.formatting_options.input_filter = func(context:GUIDEInputFormatter.FormattingContext) -> bool:
		# only show keyboard input
		return context.input.device_type & GUIDEInput.DeviceType.JOY > 0
	
func test_simple_input() -> void:
	map(_context, _action, input_key(KEY_A))
	GUIDE.enable_mapping_context(_context)
	
	var result:String = _formatter.action_as_text(_action)
	assert_str(result).is_equal("[A]")
	
	
func test_multi_binding() -> void:
	map(_context, _action, input_key(KEY_A))
	map(_context, _action, input_key(KEY_B))
	
	GUIDE.enable_mapping_context(_context)
	
	var result:String = _formatter.action_as_text(_action)
	assert_str(result).is_equal("[A], [B]")

func test_combo() -> void:
	var combo_a := action_bool()
	var combo_b := action_bool()
	map(_context, combo_a, input_key(KEY_A))
	map(_context, combo_b, input_key(KEY_B))
	map(_context, _action, null, [], [trigger_combo([combo_a, combo_b])])

	GUIDE.enable_mapping_context(_context)
		
	var result:String = _formatter.action_as_text(_action)
	assert_str(result).is_equal("[A] > [B]")
	
func test_chorded() -> void:
	var chord := action_bool()
	map(_context, chord, input_key(KEY_A))
	map(_context, _action, input_key(KEY_B), [], [trigger_chorded_action(chord)])
	
	GUIDE.enable_mapping_context(_context)
	
	var result:String = _formatter.action_as_text(_action)
	assert_str(result).is_equal("[A] + [B]")


# a mapping can consist of chorded actions only, without an own input
# (e.g. "stop" = "left" + "right"). the chord is then all there is to render.
func test_chorded_without_own_input() -> void:
	var left := action_bool()
	var right := action_bool()
	map(_context, left, input_key(KEY_A))
	map(_context, right, input_key(KEY_B))
	map(_context, _action, null, [], [trigger_chorded_action(left), trigger_chorded_action(right)])

	GUIDE.enable_mapping_context(_context)

	var result:String = _formatter.action_as_text(_action)
	assert_str(result).is_equal("[A] + [B]")


# https://github.com/godotneers/G.U.I.D.E/issues/175 - if the mapping has an own
# input and that input is filtered out, the whole mapping is discarded because it
# could never trigger.
func test_chorded_with_filtered_out_own_input_is_discarded() -> void:
	var chord := action_bool()
	map(_context, chord, input_key(KEY_SHIFT))
	map(_context, _action, input_joy_button(JOY_BUTTON_B), [], [trigger_chorded_action(chord)])

	GUIDE.enable_mapping_context(_context)
	_filter_keyboard()

	var result:String = _formatter.action_as_text(_action)
	assert_str(result).is_equal("")


func test_type_filter_simple() -> void:
	map(_context, _action, input_key(KEY_A))
	map(_context, _action, input_joy_button(JOY_BUTTON_B))
	GUIDE.enable_mapping_context(_context)
	
	var result:String = _formatter.action_as_text(_action)
	assert_str(result).is_equal("[A], [Joy 1]")
	
	_filter_keyboard()
	
	result = _formatter.action_as_text(_action)
	assert_str(result).is_equal("[A]")

	_filter_joy()
	
	result = _formatter.action_as_text(_action)
	assert_str(result).is_equal("[Joy 1]")


func test_type_filter_chord() -> void:
	var chord := action_bool()
	map(_context, chord, input_key(KEY_SHIFT))
	map(_context, chord, input_joy_button(JOY_BUTTON_LEFT_SHOULDER))
	
	
	map(_context, _action, input_key(KEY_A), [], [trigger_chorded_action(chord)])
	map(_context, _action, input_joy_button(JOY_BUTTON_B), [], [trigger_chorded_action(chord)])
	GUIDE.enable_mapping_context(_context)
	
	var result:String = _formatter.action_as_text(_action)
	assert_str(result).is_equal("[Shift], [Joy 9] + [A], [Shift], [Joy 9] + [Joy 1]")
	
	_filter_keyboard()
	
	result = _formatter.action_as_text(_action)
	assert_str(result).is_equal("[Shift] + [A]")

	_filter_joy()
	
	result = _formatter.action_as_text(_action)
	assert_str(result).is_equal("[Joy 9] + [Joy 1]")



func test_type_filter_empty() -> void:
	map(_context, _action, input_key(KEY_A))
	GUIDE.enable_mapping_context(_context)

	_filter_joy()
	
	var result:String = _formatter.action_as_text(_action)
	assert_str(result).is_equal("")
