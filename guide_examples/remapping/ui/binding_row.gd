extends HBoxContainer


signal rebind(item:GUIDERemapper.ConfigItem)

@onready var _action_name:Button = %ActionName
@onready var _action_binding:RichTextLabel = %ActionBinding

var _formatter:GUIDEInputFormatter = GUIDEInputFormatter.new(48)
var _item:GUIDERemapper.ConfigItem

func initialize(item:GUIDERemapper.ConfigItem, input:GUIDEInput) -> void:
	_item = item
	_action_name.text = item.display_name
	_item.changed.connect(_show_input)
	_show_input(input)
	
	
func _on_action_name_pressed() -> void:
	if _item != null:
		rebind.emit(_item)


func _show_input(input:GUIDEInput) -> void:
	if input != null:
		var text := await _formatter.input_as_richtext_async(input)
		_action_binding.parse_bbcode(text)	
	else:
		_action_binding.parse_bbcode("<not bound>")
