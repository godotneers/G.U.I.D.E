@tool

const ClassScanner = preload("class_scanner.gd")


static var _regex:RegEx

static func _static_init():
	_regex = RegEx.new()
	_regex.compile("gd_resource.*?script_class=\"([^\"]+)\"")			

## Finds all resources in the editor that are of the given type.
## Returns a list of full path names of the found resources.
static func find_resources_of_type(type_name:StringName) -> Array[String]:
	var begin := Time.get_ticks_usec()
	var result:Array[String] = []
	var inheritors:Array = [ type_name ] + ClassScanner.find_inheritors(type_name).keys()
	
	_find_resources_of_type_in(EditorInterface.get_resource_filesystem().get_filesystem(), inheritors, result)
	var end := Time.get_ticks_usec()
#	print("Scan took ", (end - begin) , "us.")
	return result

static func _find_resources_of_type_in(directory: EditorFileSystemDirectory, inheritors:Array, result:Array[String]):
	for i in directory.get_subdir_count():
		_find_resources_of_type_in(directory.get_subdir(i), inheritors, result)
		pass
	
	for i in directory.get_file_count():
		var path:String = directory.get_file_path(i)	
		var engine_type:StringName = directory.get_file_type(i)
		var actual_type:StringName = engine_type
		if engine_type == "Resource":
			var resource_script_class := _get_resource_script_class(path)
			if resource_script_class != "":
				actual_type = resource_script_class
				
		# print(path, " -> ", engine_type, "-->" ,actual_type)
		
		if inheritors.has(actual_type):
			result.append(path)

		
static func _get_resource_script_class(path:String) -> String:
	if not path.ends_with(".tres"):
		return ""

	# this is really shoddy as it causes a lot of IO. but the get_resource_script_class is not exposed
	# on EditorFileSystemDirectory, so we gotta make do with this.
	var content	= FileAccess.get_file_as_string(path)
	if content == "":
		return ""
		
	var re_match:RegExMatch = _regex.search(content)
	if re_match == null:
		return ""
		
	return re_match.get_string(1)
