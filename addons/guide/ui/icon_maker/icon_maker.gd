@tool
extends Node

const CACHE_DIR: String = "user://_guide_cache"

@onready var _sub_viewport: SubViewport = %SubViewport
@onready var _root: Node2D = %Root
@onready var _scene_holder = %SceneHolder

var _pending_requests: Array[Job] = []
var _current_request: Job = null
var _fetch_image: bool = false

func _ready():
	# keep working when game is paused
	process_mode = Node.PROCESS_MODE_ALWAYS
	# don't needlessly eat performance
	if _pending_requests.is_empty():
		set_process(false)


func clear_cache():
	var files = DirAccess.get_files_at(CACHE_DIR)
	for file in files:
		DirAccess.remove_absolute(CACHE_DIR + "/" + file)

## Makes an icon for the given input and returns a Texture2D with the icon. Icons
## are cached on disk so subsequent calls for the same input will be faster.
func make_icon(input: GUIDEInput, renderer: GUIDEIconRenderer, height_px: int) -> Texture2D:
	DirAccess.make_dir_recursive_absolute(CACHE_DIR)
	var cache_key = (str(height_px) + renderer.cache_key(input)).sha256_text()
	var cache_path = "user://_guide_cache/" + cache_key + ".res"
	if ResourceLoader.exists(cache_path):
		return ResourceLoader.load(cache_path, "Texture2D")

	var job = Job.new()
	job.height = height_px
	job.input = input
	job.renderer = renderer
	_pending_requests.append(job)
	set_process(true)

	await job.done

	var image_texture = ImageTexture.create_from_image(job.result)
	ResourceSaver.save(image_texture, cache_path)
	image_texture.take_over_path(cache_path)

	return image_texture

## Makes a composite icon using the provided hint and returns a Texture2D with the icon.
func make_icon_with_hint(input: GUIDEInput, composite_renderer: GUIDECompositeRenderer, hint: GUIDEIconHint, action_mapping: GUIDEActionMapping, height_px: int, available_renderers: Array[GUIDEIconRenderer]) -> Texture2D:
	DirAccess.make_dir_recursive_absolute(CACHE_DIR)
	var cache_key = (str(height_px) + "hint:" + hint.get_cache_key() + "mapping:" + _get_mapping_cache_key(action_mapping)).sha256_text()
	var cache_path = "user://_guide_cache/" + cache_key + ".res"
	if ResourceLoader.exists(cache_path):
		return ResourceLoader.load(cache_path, "Texture2D")

	var job = CompositeJob.new()
	job.height = height_px
	job.input = input
	job.composite_renderer = composite_renderer
	job.hint = hint
	job.action_mapping = action_mapping
	job.available_renderers = available_renderers
	_pending_requests.append(job)
	set_process(true)

	await job.done

	var image_texture = ImageTexture.create_from_image(job.result)
	ResourceSaver.save(image_texture, cache_path)
	image_texture.take_over_path(cache_path)

	return image_texture

func _get_mapping_cache_key(action_mapping: GUIDEActionMapping) -> String:
	var key = ""
	if action_mapping != null:
		for input_mapping in action_mapping.input_mappings:
			if input_mapping.input != null:
				key += input_mapping.input.resource_path + ";"
	return key

func _process(delta):
	if _current_request == null and _pending_requests.is_empty():
		# nothing more to do..
		set_process(false)
		return

	# nothing in progress, so pick the next request
	if _current_request == null:
		_current_request = _pending_requests.pop_front()

		if _current_request is CompositeJob:
			_handle_composite_job(_current_request)
		else:
			_handle_regular_job(_current_request)
		return

	# fetch the image after the renderer is done
	if _fetch_image:
		# we're done. make a copy of the viewport texture
		var image: Image = _scene_holder.texture.get_image()
		_current_request.result = image
		_current_request.done.emit()
		_current_request = null
		# remove the renderer
		_root.remove_child(_root.get_child(0))
		_sub_viewport.render_target_update_mode = SubViewport.UPDATE_DISABLED
		_fetch_image = false

func _handle_regular_job(job: Job):
	var renderer = job.renderer
	_root.add_child(renderer)

	renderer.render(job.input)
	await get_tree().process_frame

	var actual_size = renderer.get_rect().size
	var scale = float(job.height) / float(actual_size.y)
	_root.scale = Vector2.ONE * scale
	_sub_viewport.size = actual_size * scale

	_sub_viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS

	# give the renderer some time to update itself. 3 frames seem
	# to work nicely and keep things speedy.
	await get_tree().process_frame
	await get_tree().process_frame
	await get_tree().process_frame

	_fetch_image = true

func _handle_composite_job(job: CompositeJob):
	var renderer = job.composite_renderer.duplicate()
	_root.add_child(renderer)

	# Wait for render_with_hint to complete (it's async)
	renderer.render_with_hint(job.hint, job.action_mapping, job.available_renderers)

	# Give more time for composite rendering since it's async
	await get_tree().process_frame
	await get_tree().process_frame
	await get_tree().process_frame
	await get_tree().process_frame
	await get_tree().process_frame

	var actual_size = renderer.get_rect().size
	if actual_size == Vector2.ZERO:
		actual_size = renderer.custom_minimum_size
	if actual_size == Vector2.ZERO:
		actual_size = Vector2(64, 64) # fallback

	# Debug output to help diagnose issues
	print("Composite renderer size: ", actual_size, " for height: ", job.height)

	# Ensure we don't have invalid sizes
	if actual_size.x <= 0 or actual_size.y <= 0:
		push_warning("Invalid composite renderer size: ", actual_size)
		actual_size = Vector2(64, 64)

	# Prevent viewport from becoming too large
	var max_viewport_size = Vector2(2048, 2048)
	if actual_size.x > max_viewport_size.x or actual_size.y > max_viewport_size.y:
		var scale_factor = min(max_viewport_size.x / actual_size.x, max_viewport_size.y / actual_size.y)
		actual_size *= scale_factor
		print("Scaled down composite renderer to: ", actual_size)

	var scale = float(job.height) / float(actual_size.y)
	_root.scale = Vector2.ONE * scale
	_sub_viewport.size = actual_size * scale

	_sub_viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS

	# Give even more time for composite rendering to settle
	await get_tree().process_frame
	await get_tree().process_frame
	await get_tree().process_frame
	await get_tree().process_frame

	_fetch_image = true

class Job:
	signal done()
	var height: int
	var input: GUIDEInput
	var renderer: GUIDEIconRenderer
	var result: Image

class CompositeJob:
	extends Job
	var composite_renderer: GUIDECompositeRenderer
	var hint: GUIDEIconHint
	var action_mapping: GUIDEActionMapping
	var available_renderers: Array[GUIDEIconRenderer]
