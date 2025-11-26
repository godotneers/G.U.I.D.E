@tool
extends Node

const CACHE_DIR:String = "user://_guide_cache"

@onready var _sub_viewport:SubViewport = %SubViewport
@onready var _root:Node2D = %Root
@onready var _scene_holder:Sprite2D = %SceneHolder

var _pending_requests:Array[Job] = []
var _current_request:Job = null
var _fetch_image:bool = false

func _ready() -> void:
	# keep working when game is paused
	process_mode = Node.PROCESS_MODE_ALWAYS
	# don't needlessly eat performance
	if _pending_requests.is_empty():
		set_process(false)

	
func clear_cache() -> void:
	var files := DirAccess.get_files_at(CACHE_DIR)
	for file in files:
		DirAccess.remove_absolute(CACHE_DIR + "/" + file)

## Makes an icon for the given input and returns a Texture2D with the icon. Icons
## are cached on disk so subsequent calls for the same input will be faster.
func make_icon(input:GUIDEInput, renderer:GUIDEIconRenderer, \
		height_px:int, options:GUIDEInputFormattingOptions) -> Texture2D:
	DirAccess.make_dir_recursive_absolute(CACHE_DIR)
	var cache_key := (str(height_px) + renderer.cache_key(input, options)).sha256_text()
	var cache_path := "user://_guide_cache/" + cache_key + ".res"
	if ResourceLoader.exists(cache_path):
		return ResourceLoader.load(cache_path, "Texture2D") 
	
	var job := Job.new()
	job.height = height_px
	job.input = input
	job.options = options
	job.renderer = renderer
	_pending_requests.append(job)
	set_process(true)
	
	await job.done
	
	var image_texture := ImageTexture.create_from_image(job.result)
	ResourceSaver.save(image_texture, cache_path)
	image_texture.take_over_path(cache_path)
	
	return image_texture
		
	

func _process(_delta:float) -> void:
	if _current_request == null and _pending_requests.is_empty():
		# nothing more to do..
		set_process(false)
		return 
		
	# nothing in progress, so pick the next request
	if _current_request == null:
		_current_request = _pending_requests.pop_front()
		var renderer := _current_request.renderer
		_root.add_child(renderer)
		
		renderer.render(_current_request.input, _current_request.options)
		await get_tree().process_frame
		
		var actual_size := renderer.get_rect().size
		var scale := float(_current_request.height) / float(actual_size.y)
		_root.scale = Vector2.ONE * scale
		_sub_viewport.size = actual_size  * scale
			
		_sub_viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
			
		# give the renderer some time to update itself. 3 frames seem
		# to work nicely and keep things speedy.	
		await get_tree().process_frame
		await get_tree().process_frame
		await get_tree().process_frame
			
		_fetch_image = true
		return
		
	# fetch the image after the renderer is done	
	if _fetch_image:
		# we're done. make a copy of the viewport texture
		var image := _scene_holder.texture.get_image()
		_current_request.result = image
		_current_request.done.emit()
		_current_request = null
		# remove the renderer
		_root.remove_child(_root.get_child(0))
		_sub_viewport.render_target_update_mode = SubViewport.UPDATE_DISABLED
		_fetch_image = false			
		
class Job:
	signal done()
	var height:int
	var input:GUIDEInput
	var renderer:GUIDEIconRenderer
	var options:GUIDEInputFormattingOptions
	var result:Image
	
	
