## This is an example for how input prompts can be shown to the player. 
extends RichTextLabel

## The instructions text. Should contain %s where the action text should go. 
@export_multiline var instructions_text:String
## The actions which should be used for rendering the instructions. One action for 
## each %s in the text.
@export var actions:Array[GUIDEAction] = []
## The icon size to be used for rendering.
@export var icon_size:int = 48

## If set, the label will only show when the given mapping context is active.
@export var limit_to_context:GUIDEMappingContext

# The formatter. This will do the actual work of formatting action inputs into prompts.
var _formatter:GUIDEInputFormatter

func _ready() -> void:
	bbcode_enabled = true
	fit_content = true
	scroll_active = false
	autowrap_mode = TextServer.AUTOWRAP_OFF
	
	# Subscribe to the input mappings change so we can update the prompts or hide the label
	# when any inputs change. This way the label can automatically update itself if we switch
	# from keyboard to controller input or rebind some keys.
	GUIDE.input_mappings_changed.connect(_update_instructions)
	_formatter = GUIDEInputFormatter.for_active_contexts(icon_size)
	
	
func _update_instructions() -> void:
	# If we only show for a certain context, hide if that context isn't active right now.
	if limit_to_context != null and not GUIDE.is_mapping_context_enabled(limit_to_context):
		visible = false
		return
		
	# if no mapping context is active, we'll not be able to show instructions, so bail out here.	
	if GUIDE.get_enabled_mapping_contexts().is_empty():
		visible = false
		return
		
	visible = true
	
	# Update the prompts.
	var replacements:Array[String] = []
	for action in actions:
		replacements.append(await _formatter.action_as_richtext_async(action))
	
	parse_bbcode(instructions_text % replacements)
	


