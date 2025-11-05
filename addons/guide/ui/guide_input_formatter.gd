@tool
## Helper class for formatting GUIDE input for the UI.
class_name GUIDEInputFormatter

const IconMaker = preload("icon_maker/icon_maker.gd")
const KeyRenderer:PackedScene = preload("renderers/keyboard/key_renderer.tscn")
const MouseRenderer:PackedScene = preload("renderers/mouse/mouse_renderer.tscn")
const TouchRenderer:PackedScene = preload("renderers/touch/touch_renderer.tscn")
const JoyRenderer:PackedScene = preload("renderers/joy/joy_renderer.tscn")
const XboxRenderer:PackedScene = preload("renderers/controllers/xbox/xbox_controller_renderer.tscn")
const PlayStationRenderer:PackedScene = preload("renderers/controllers/playstation/playstation_controller_renderer.tscn")
const SwitchRenderer:PackedScene = preload("renderers/controllers/switch/switch_controller_renderer.tscn")
const ActionRenderer:PackedScene = preload("renderers/misc/action_renderer.tscn")
const FallbackRenderer:PackedScene = preload("renderers/misc/fallback_renderer.tscn")
const DefaultTextProvider = preload("text_providers/default_text_provider.gd")
const XboxTextProvider = preload("text_providers/controllers/xbox/xbox_controller_text_provider.gd")
const PlayStationTextProvider = preload("text_providers/controllers/playstation/playstation_controller_text_provider.gd")
const SwitchTextProvider = preload("text_providers/controllers/switch/switch_controller_text_provider.gd")

# These are shared across all instances
static var _icon_maker:IconMaker
static var _icon_renderers:Array[GUIDEIconRenderer] = []
static var _text_providers:Array[GUIDETextProvider] = []
static var _is_ready:bool = false

## Separator to separate mixed input. 
static var mixed_input_separator:String = ", "
## Separator to separate chorded input.
static var chorded_input_separator:String = " + "
## Separator to separate combo input.
static var combo_input_separator:String = " > "

# These are per-instance
var _action_resolver:Callable
var _icon_size:int

static func _ensure_readiness() -> void:
	if _is_ready:
		return
		
	# reconnect to an icon maker that might be there
	var root = Engine.get_main_loop().root	
	for child in root.get_children():
		if child is IconMaker:
			_icon_maker = child
			
	if _icon_maker == null:
		_icon_maker = preload("icon_maker/icon_maker.tscn").instantiate()
		root.add_child.call_deferred(_icon_maker)
	
	add_icon_renderer(KeyRenderer.instantiate())
	add_icon_renderer(MouseRenderer.instantiate())
	add_icon_renderer(TouchRenderer.instantiate())
	add_icon_renderer(ActionRenderer.instantiate())
	add_icon_renderer(JoyRenderer.instantiate())
	add_icon_renderer(XboxRenderer.instantiate())
	add_icon_renderer(PlayStationRenderer.instantiate())
	add_icon_renderer(SwitchRenderer.instantiate())
	add_icon_renderer(FallbackRenderer.instantiate())
	
	add_text_provider(DefaultTextProvider.new())
	add_text_provider(XboxTextProvider.new())
	add_text_provider(PlayStationTextProvider.new())
	add_text_provider(SwitchTextProvider.new())
	
	_is_ready = true


## This will clean up the rendering infrastructure used for generating 
## icons. Note that in a normal game you will have no need to call this
## as the infrastructure is needed throughout the run of your game.
## It might be useful in tests though, to get rid of spurious warnings
## about orphaned nodes.
static func cleanup():
	_is_ready = false
		
	# free all the nodes to avoid memory leaks
	for renderer in _icon_renderers:
		renderer.queue_free()
		
	_icon_renderers.clear()
	
	_text_providers.clear()
	if is_instance_valid(_icon_maker):
		_icon_maker.queue_free()


func _init(icon_size:int = 32, resolver:Callable = func(action) -> GUIDEActionMapping: return null ):
	_icon_size = icon_size
	_action_resolver = resolver


## Adds an icon renderer for rendering icons.
static func add_icon_renderer(renderer:GUIDEIconRenderer) -> void:
	_icon_renderers.append(renderer)
	_icon_renderers.sort_custom(func(r1, r2): return r1.priority < r2.priority)
	
## Removes an icon renderer.
static func remove_icon_renderer(renderer:GUIDEIconRenderer) -> void:
	_icon_renderers.erase(renderer)
	
## Adds a text provider for rendering text.
static func add_text_provider(provider:GUIDETextProvider) -> void:
	_text_providers.append(provider)
	_text_providers.sort_custom(func(r1, r2): return r1.priority < r2.priority)

	
## Removes a text provider	
static func remove_text_provider(provider:GUIDETextProvider) -> void:
	_text_providers.erase(provider)


## Returns an input formatter that can format actions using the currently active inputs.
static func for_active_contexts(icon_size:int = 32) -> GUIDEInputFormatter:
	var resolver := func(action:GUIDEAction) -> GUIDEActionMapping:
		for mapping in GUIDE._active_action_mappings:
			if mapping.action == action:
				return mapping
		return null
	return GUIDEInputFormatter.new(icon_size, resolver)


## Returns an input formatter that can format actions using the given context.
static func for_context(context:GUIDEMappingContext, icon_size:int = 32) -> GUIDEInputFormatter:
	var resolver:Callable = func(action:GUIDEAction) -> GUIDEActionMapping:
		for mapping in context.mappings:
			if mapping.action == action:
				return  mapping
		return null
		
	return GUIDEInputFormatter.new(icon_size, resolver)
	
	
## Formats the action input as richtext with icons suitable for a RichTextLabel. This function
## is async as icons may need to be rendered in the background which can take a few frames, so 
## you will need to await on it.
func action_as_richtext_async(action:GUIDEAction) -> String:
	return await _materialized_as_richtext_async(_materialize_action_input(action))


## Formats the action input as plain text which can be used in any UI component. This is a bit
## more light-weight than formatting as icons and returns immediately.
func action_as_text(action:GUIDEAction) -> String:
	return _materialized_as_text(_materialize_action_input(action))

## Formats the input as richtext with icons suitable for a RichTextLabel. This function
## is async as icons may need to be rendered in the background which can take a few frames, so 
## you will need to await on it.
func input_as_richtext_async(input:GUIDEInput, materialize_actions:bool = true) -> String:
	return await _materialized_as_richtext_async(_materialize_input(input, materialize_actions))


## Formats the input as plain text which can be used in any UI component. This is a bit
## more light-weight than formatting as icons and returns immediately.
func input_as_text(input:GUIDEInput, materialize_actions:bool = true) -> String:
	return _materialized_as_text(_materialize_input(input, materialize_actions))	
	

## Renders materialized input as text.
func _materialized_as_text(input:MaterializedInput) -> String:
	_ensure_readiness()
	if input is MaterializedSimpleInput:
		var text:String = ""
		for provider in _text_providers:
			if provider.supports(input.input):
				text = provider.get_text(input.input)
				# first provider wins
				break
		if text == "":
			pass
			## push_warning("No formatter found for input ", input)
		return text

	var separator := _separator_for_input(input)
	if separator == "" or input.parts.is_empty():
		return ""
		
	var parts:Array[String] = []
	for part in input.parts:
		parts.append(_materialized_as_text(part))	
		
	return separator.join(parts)
			
## Renders materialized input as rich text.
func _materialized_as_richtext_async(input:MaterializedInput) -> String:
	_ensure_readiness()	
	if input is MaterializedSimpleInput:
		var icon:Texture2D = null
		for renderer in _icon_renderers:
			if renderer.supports(input.input):
				icon = await _icon_maker.make_icon(input.input, renderer, _icon_size)
				# first renderer wins
				break
		if icon == null:
			push_warning("No renderer found for input ", input)
			return ""
		
		return "[img]%s[/img]" % [icon.resource_path]
	

	var separator := _separator_for_input(input)
	if separator == "" or input.parts.is_empty():
		return ""
		
	var parts:Array[String] = []
	for part in input.parts:
		parts.append(await _materialized_as_richtext_async(part))	
		
	return separator.join(parts)
		

func _separator_for_input(input:MaterializedInput) -> String:
	if input is MaterializedMixedInput:
		return mixed_input_separator
	elif input is MaterializedComboInput:
		return combo_input_separator
	elif input is MaterializedChordedInput:
		return chorded_input_separator

	push_error("Unknown materialized input type")
	return ""
			

## Materializes action input.	
func _materialize_action_input(action:GUIDEAction) -> MaterializedInput:
	var result := MaterializedMixedInput.new()
	if action == null:
		push_warning("Trying to get inputs for a null action.")
		return result
	
	# get the mapping for this action
	var mapping:GUIDEActionMapping = _action_resolver.call(action)
	
	# if we have no mapping, well that's it, return an empty mixed input
	if mapping == null:
		return result
		
	# collect input mappings
	for input_mapping in mapping.input_mappings:
		var chorded_actions:Array[MaterializedInput] = []
		var combos:Array[MaterializedInput] = []
		
		for trigger in input_mapping.triggers:
			# if we have a combo trigger, materialize its input.
			if trigger is GUIDETriggerCombo:
				var combo := MaterializedComboInput.new()
				for step:GUIDETriggerComboStep in trigger.steps:
					combo.parts.append(_materialize_action_input(step.action))
				combos.append(combo)

			# if we have a chorded action, materialize its input
			if trigger is GUIDETriggerChordedAction:
				chorded_actions.append(_materialize_action_input(trigger.action))

		if not chorded_actions.is_empty():
			# if we have chorded action then the whole mapping is chorded.
			var chord := MaterializedChordedInput.new()
			for chorded_action in chorded_actions:
				chord.parts.append(chorded_action)
			for combo in combos:
				chord.parts.append(combo)
			if combos.is_empty():
				if input_mapping.input != null:
					chord.parts.append(_materialize_input(input_mapping.input))					
			result.parts.append(chord)
		else:
			for combo in combos:
				result.parts.append(combo)
			if combos.is_empty():
				if input_mapping.input != null:
					result.parts.append(_materialize_input(input_mapping.input))			
	return result
	
## Materializes direct input.
func _materialize_input(input:GUIDEInput, materialize_actions:bool = true) -> MaterializedInput:
	if input == null:
		push_warning("Trying to materialize a null input.")
		return MaterializedMixedInput.new()
	
	# if its an action input, get its parts
	if input is GUIDEInputAction:
		if materialize_actions:
			return _materialize_action_input(input.action)
		else:
			return MaterializedSimpleInput.new(input)
	
	# if its a key input, split out the modifiers
	if input is GUIDEInputKey:
		var chord := MaterializedChordedInput.new()
		if input.control:
			var ctrl := GUIDEInputKey.new()
			ctrl.key = KEY_CTRL
			chord.parts.append(MaterializedSimpleInput.new(ctrl))
		if input.alt:
			var alt := GUIDEInputKey.new()
			alt.key = KEY_ALT
			chord.parts.append(MaterializedSimpleInput.new(alt))
		if input.shift:
			var shift := GUIDEInputKey.new()
			shift.key = KEY_SHIFT
			chord.parts.append(MaterializedSimpleInput.new(shift))
		if input.meta:
			var meta := GUIDEInputKey.new()
			meta.key = KEY_META
			chord.parts.append(MaterializedSimpleInput.new(meta))
	
		# got no modifiers?
		if chord.parts.is_empty():
			return MaterializedSimpleInput.new(input)
			
		chord.parts.append(MaterializedSimpleInput.new(input))	
		return chord

	# everything else is just a simple input
	return MaterializedSimpleInput.new(input)
			
class MaterializedInput:
	pass
	
class MaterializedSimpleInput:
	extends MaterializedInput
	var input:GUIDEInput	
	
	func _init(input:GUIDEInput):
		self.input = input
	
class MaterializedMixedInput:
	extends MaterializedInput
	var parts:Array[MaterializedInput] = []
	
class MaterializedChordedInput:
	extends MaterializedInput
	var parts:Array[MaterializedInput] = []
	
class MaterializedComboInput:
	extends MaterializedInput
	var parts:Array[MaterializedInput] = []


## Returns the name of the associated joystick/pad of the given input.
## If the input is no joy input or the device name cannot be determined
## returns an empty string. 
static func _joy_name_for_input(input:GUIDEInput) -> String:
	if not input is GUIDEInputJoyBase:
		return ""
	
	var joypads:Array[int] = Input.get_connected_joypads()
	var joy_index := input.joy_index
	if joy_index < 0:
		# pick the first one
		joy_index = 0
	
	# We don't have such a controller, so bail out.
	if joypads.size() <= joy_index:
		return "" 
		
	var id := joypads[joy_index]
	return Input.get_joy_name(id)	
