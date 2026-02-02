extends Node

@export var mapping_context: GUIDEMappingContext
@export var fire_action: GUIDEAction

@onready var visualizer: Control = %TriggerVisualizer

func _ready() -> void:
	if mapping_context:
		GUIDE.enable_mapping_context(mapping_context)

		# Set the action on the visualizer
		visualizer.fire_action = fire_action

		# Get the duplicated trigger from GUIDE's internals
		# Triggers are duplicated when contexts are enabled, so we need the runtime instance
		# You usually do not want to do this in your game, this is just so 
		# we can show the internals of GUIDE in the demo.
		for action_mapping in GUIDE._active_action_mappings:
			if action_mapping.action == fire_action:
				for input_mapping in action_mapping.input_mappings:
					if not input_mapping.triggers.is_empty():
						var trigger:GUIDETrigger = input_mapping.triggers[0]
						if trigger is GUIDETriggerHair:
							visualizer.hair_trigger = trigger
							break
