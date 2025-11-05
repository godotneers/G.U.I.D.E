## Scanner to find inheriting classes. Used to detect inheritors of
## modifiers and triggers. Ideally this would be built into the editor
## but sometimes one has to hack their way around the limitations.
## This only scans to the extent needed to drive the UI, it's not a general
## purpose implementation.
@tool

const GUIDESet = preload("../guide_set.gd")

var _dirty:bool = true

# looks like we only get very limited access to the script's inheritance tree,
# so we need to do a little caching ourselves
var _script_lut:Dictionary = {}

func _init():
	EditorInterface.get_resource_filesystem().script_classes_updated.connect(_mark_dirty)


func _mark_dirty():
	_dirty = true

## Returns all classes that directly or indirectly inherit from the 
## given class. Only works for scripts in the project, e.g. doesn't
## scan the whole class_db. Key is class name, value is the Script instance
func find_inheritors(clazz_name:StringName) -> Dictionary:
	var result:Dictionary = {}

	var root := EditorInterface.get_resource_filesystem().get_filesystem()
	
	# rebuild the LUT when needed
	if _dirty:
		_script_lut.clear()
		_scan(root)
		_dirty = false
		
	
	var open_set:GUIDESet = GUIDESet.new()
	# a closed set just to avoid infinite loops, we'll never
	# look at the same class more than once.
	var closed_set:GUIDESet = GUIDESet.new()
	
	open_set.add(clazz_name)
	
	while not open_set.is_empty():
		var next = open_set.pull()
		closed_set.add(next)
		if not _script_lut.has(next):
			# we don't know this script, ignore, move on
			continue
		
		# now find all scripts that extend the one we 
		# are looking at
		for item:ScriptInfo in _script_lut.values():
			if item.extendz == next:
				# put them into the result
				result[item.clazz_name] = item.clazz_script
				# and put their class in the open set
				# unless we already looked at it.
				if not closed_set.has(item.clazz_name):
					open_set.add(item.clazz_name)
		
	return result


func _scan(folder:EditorFileSystemDirectory) -> void:
	for i in folder.get_file_count():
		var script_clazz := folder.get_file_script_class_name(i)
		if script_clazz != "":
			var info := _script_lut.get(script_clazz)
			if info == null:
				info = ScriptInfo.new()
				info.clazz_name = script_clazz
				info.clazz_script = ResourceLoader.load(folder.get_file_path(i))
				_script_lut[script_clazz] = info
				
			var script_extendz := folder.get_file_script_class_extends(i)
			info.extendz = script_extendz
			
	for i in folder.get_subdir_count():
		_scan(folder.get_subdir(i))		
					
	
class ScriptInfo:
	var clazz_name:StringName
	var extendz:StringName	
	var clazz_script:Script
	
	func _to_string() -> String:
		return clazz_name + ":" + extendz
	
