@icon("res://addons/guide/guide_internal.svg")
@tool
## A mapping from actuated input to a trigger result
class_name GUIDEInputMapping
extends Resource

## Whether the remapping configuration in this input mapping
## should override the configuration of the bound action. Enable
## this, to give a key a custom name or category for remapping.
@export var override_action_settings:bool = false:
	set(value):
		if override_action_settings == value:
			return
		override_action_settings = value
		emit_changed()

## If true, players can remap this input mapping. Note that the 
## action to which this input is bound also needs to be remappable
## for this setting to have an effect.
@export var is_remappable:bool = false:
	set(value):
		if is_remappable == value:
			return
		is_remappable = value
		emit_changed()
		
## The display name of the input mapping shown to the player. If empty,
## the display name of the action is used.
@export var display_name:String = "":
	set(value):
		if display_name == value:
			return
		display_name = value
		emit_changed()

## The display category of the input mapping. If empty, the display name of the
## action is used.
@export var display_category:String = "":
	set(value):
		if display_category == value:
			return
		display_category = value
		emit_changed()
		

@export_group("Mappings")
## The input to be actuated
@export var input:GUIDEInput:
	set(value):
		if value == input:
			return
		input = value
		emit_changed()


## A list of modifiers that preprocess the actuated input before
## it is fed to the triggers.
@export var modifiers:Array[GUIDEModifier] = []:
	set(value):
		if value == modifiers:
			return
		modifiers = value
		emit_changed()


## A list of triggers that could trigger the mapped action.
@export var triggers:Array[GUIDETrigger] = []:
	set(value):
		if value == triggers:
			return
		triggers = value
		emit_changed()

## Hint for how long the input must remain actuated (in seconds) before the mapping triggers.
## If the mapping has no hold trigger it will be -1. If it has multiple hold triggers
## the shortest hold time will be used.
var _trigger_hold_threshold:float = -1.0

var _state:GUIDETrigger.GUIDETriggerState = GUIDETrigger.GUIDETriggerState.NONE
var _value:Vector3 = Vector3.ZERO

var _trigger_list:Array[GUIDETrigger] = []
var _implicit_count:int = 0
var _explicit_count:int = 0

## Called when the mapping is started to be used by GUIDE. Calculates 
## the number of implicit and explicit triggers so we don't need to do this
## per frame. Also creates a default trigger when none is set.
func _initialize() -> void :
	_trigger_list.clear()
	
	_implicit_count = 0
	_explicit_count = 0
	_trigger_hold_threshold = -1.0
	
	if triggers.is_empty():
		# make a default trigger and use that
		var default_trigger = GUIDETriggerDown.new()
		default_trigger.actuation_threshold = 0
		_explicit_count = 1
		_trigger_list.append(default_trigger)
		return
	
	for trigger in triggers:
		match trigger._get_trigger_type():
			GUIDETrigger.GUIDETriggerType.EXPLICIT:
				_explicit_count += 1
			GUIDETrigger.GUIDETriggerType.IMPLICIT:
				_implicit_count += 1
		_trigger_list.append(trigger)

		# prevents the mapping from triggering if the input is held while
		# the mapping becomes active.
		if trigger is GUIDETriggerPressed:
			trigger._last_value = Vector3.ONE
		
		# collect the hold threshold for hinting the UI about how long
		# the input must be held down. This is only relevant for hold triggers
		if trigger is GUIDETriggerHold:
			if _trigger_hold_threshold == -1:
				_trigger_hold_threshold = trigger.hold_treshold
			else:
				_trigger_hold_threshold = min(_trigger_hold_threshold, trigger.hold_treshold)
		
		

func _update_state(delta:float, value_type:GUIDEAction.GUIDEActionValueType):
	# Collect the current input value
	var input_value:Vector3 = input._value if input != null else Vector3.ZERO
	
	# Run it through all modifiers
	for modifier:GUIDEModifier in modifiers:
		input_value = modifier._modify_input(input_value, delta, value_type)
		
	_value = input_value
	
	var triggered_implicits:int = 0
	var triggered_explicits:int = 0
	var triggered_blocked:int = 0
	
	# Run over all triggers
	var result:int = GUIDETrigger.GUIDETriggerState.NONE
	for trigger:GUIDETrigger in _trigger_list:
		var trigger_result:GUIDETrigger.GUIDETriggerState = trigger._update_state(_value, delta, value_type)
		trigger._last_value = _value
		
		var trigger_type = trigger._get_trigger_type()
		if trigger_result == GUIDETrigger.GUIDETriggerState.TRIGGERED:
			match trigger_type:
				GUIDETrigger.GUIDETriggerType.EXPLICIT:
					triggered_explicits += 1
				GUIDETrigger.GUIDETriggerType.IMPLICIT:
					triggered_implicits += 1
				GUIDETrigger.GUIDETriggerType.BLOCKING:
					triggered_blocked += 1
			
		# we only care about the nuances of explicit triggers. implicits and blocking
		# can only really return yes or no, so they have no nuance		
		if trigger_type == GUIDETrigger.GUIDETriggerType.EXPLICIT: 
			# Higher value results take precedence over lower value results
			result = max(result, trigger_result)
	
	# final collection
	if triggered_blocked > 0:
		# some blocker triggered which means that this cannot succeed
		_state = GUIDETrigger.GUIDETriggerState.NONE
		return
	
	if triggered_implicits < _implicit_count:
		# not all implicits triggered, which also fails this binding
		_state = GUIDETrigger.GUIDETriggerState.NONE
		return
	
	if _explicit_count == 0 and _implicit_count > 0:
		# if no explicits exist, its enough when all implicits trigger
		_state = GUIDETrigger.GUIDETriggerState.TRIGGERED
		return
		
	# return the best result
	_state = result

	
