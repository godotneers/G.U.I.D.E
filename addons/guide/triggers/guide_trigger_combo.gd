@tool
class_name GUIDETriggerCombo
extends GUIDETrigger

enum ActionEventType {
	TRIGGERED = 1,
	STARTED = 2,
	ONGOING = 4,
	CANCELLED = 8,
	COMPLETED = 16
}

## If set to true, the combo trigger will print information
## about state changes to the debug log.
@export var enable_debug_print:bool = false
@export var steps:Array[GUIDETriggerComboStep] = []
@export var cancellation_actions:Array[GUIDETriggerComboCancelAction] = []

var _current_step:int = -1
var _remaining_time:float = 0

func is_same_as(other:GUIDETrigger) -> bool:
	if not other is GUIDETriggerCombo:
		return false
	if steps.size() != other.steps.size():
		return false
	if cancellation_actions.size() != other.cancellation_actions.size():
		return false
		
	for i in range(steps.size()):
		if not steps[i].is_same_as(other.steps[i]):
			return false
			
	for i in range(cancellation_actions.size()):
		if not cancellation_actions[i].is_same_as(other.cancellation_actions[i]):
			return false

	return true

## Creates a clone with properly duplicated step and cancellation action arrays.
## Each array element is shallow-copied to preserve action references.
func clone() -> GUIDETrigger:
	var copy:GUIDETriggerCombo = duplicate()

	# Duplicate array structures while preserving action references
	copy.steps = []
	for step:GUIDETriggerComboStep in steps:
		copy.steps.append(step.duplicate())

	copy.cancellation_actions = []
	for action:GUIDETriggerComboCancelAction in cancellation_actions:
		copy.cancellation_actions.append(action.duplicate())

	return copy

func _update_state(input:Vector3, delta:float, value_type:GUIDEAction.GUIDEActionValueType) -> GUIDETriggerState:
	if steps.is_empty():
		push_warning("Combo with no steps will never fire.")
		return GUIDETriggerState.NONE

	# initial setup
	if _current_step == -1:
		for step in steps:
			step._prepare()
		for action in cancellation_actions:
			action._prepare()
		_reset()
		
		
	var current_action := steps[_current_step].action
	if current_action == null:
		push_warning("Step ", _current_step , " has no action ", resource_path)
		return GUIDETriggerState.NONE
		
	# check if any of our cancellation actions fired
	for action in cancellation_actions:
		# if the action is the current action we don't count its firing as cancellation
		if action.action == current_action:
			continue
			
		if action._has_fired:
			if enable_debug_print:
				print("Combo cancelled by action '", action.action._editor_name(), "'.")
			_reset()
			return GUIDETriggerState.NONE
	
	# check if any of the steps has fired out of order
	for step in steps:
		if step.action == current_action:
			continue
			
		if step._has_fired:
			if enable_debug_print:
				print("Combo out of order step by action '", step.action._editor_name(), "'.")
			_reset()
			return GUIDETriggerState.NONE
			
	# check if we took too long (unless we're in the first step)
	if _current_step > 0:
		_remaining_time -= delta
		if _remaining_time <= 0.0:
			if enable_debug_print:
				print("Step time for step ", _current_step , " exceeded.")
			_reset()
			return GUIDETriggerState.NONE

	# if the current action was fired, if so advance to the next
	if steps[_current_step]._has_fired:
		# reset this step, so it will not count as misfired next round
		steps[_current_step]._has_fired = false
		if _current_step + 1 >= steps.size():
			# we finished the combo
			if enable_debug_print:
				print("Combo fired.")
			_reset()
			return GUIDETriggerState.TRIGGERED
			
		# otherwise, pick the next step
		_current_step += 1
		if enable_debug_print:
			print("Combo advanced to step " , _current_step, ".")
		_remaining_time = steps[_current_step].time_to_actuate
		
		# Reset all steps and cancellation actions to "not fired" in 
		# case they were triggered by this action. Otherwise a double-tap 
		# would immediately fire for both taps once the first is through
		for step in steps:
			step._has_fired = false
		for action in cancellation_actions:
			action._has_fired = false
	
	# and in any case we're still processing.
	return GUIDETriggerState.ONGOING		
	
		
func _reset():
	if enable_debug_print:
		print("Combo reset.")
	_current_step = 0
	_remaining_time = steps[0].time_to_actuate
	for step in steps:
		step._has_fired = false
	for action in cancellation_actions:
		action._has_fired = false	

func _editor_name() -> String:
	return "Combo"

func _editor_description() -> String:
	return "Fires, when the input exceeds the actuation threshold."

