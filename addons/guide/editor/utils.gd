## Removes and frees all children of a node.
static func clear(node:Node):
	if not is_instance_valid(node):
		return
	for child in node.get_children():
		node.remove_child(child)
		child.queue_free()


## Checks if the given resource is an inline resource. If so, returns a shallow copy,
## otherwise returns the resource. If the resource is null, returns null.
static func duplicate_if_inline(resource:Resource) -> Resource:
	if is_inline(resource):
		return resource.duplicate()
	return resource
	

## Checks if the given resource is an inline resource.
static func is_inline(resource:Resource) -> bool:
	if resource == null:
		return false
	return resource.resource_path.contains("::") or resource.resource_path == ""
	
	
## Checks if the given node is somewhere in the currently edited scene.	
static func is_node_in_edited_scene(node:Node) -> bool:
	if not Engine.is_editor_hint():
		return false
	
	if not is_instance_valid(node):
		return false
	
	var editor_interface := Engine.get_singleton("EditorInterface")
	if editor_interface == null:
		return false
	var scene_root:Node = editor_interface.get_edited_scene_root()
	if not is_instance_valid(scene_root):
		return false
		
	return (node == scene_root) or scene_root.is_ancestor_of(node)
