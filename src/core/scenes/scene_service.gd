extends Node

signal progress_changed(progress: float)
signal load_finished
signal load_failed(scene_path: String)

const WORLD_MAP_PATH := ("res://src/presentation/world_map/world_map.tscn")

const LOADING_SCREEN := preload("uid://ct4n20nt4t0py")

var _loaded_resource: PackedScene = null
var _scene_path: String = ""
var _progress: Array = []

var _use_sub_threads: bool = true
var _loading_screen_instance = null
var _is_loading: bool = false


func _ready() -> void:
	name = "SceneService"
	set_process(false)


func load_scene(scene_path: String) -> void:
	if _is_loading:
		push_warning("Scene load already in progress: %s" % _scene_path)
		return

	if scene_path.is_empty():
		push_error("Cannot load an empty scene path")
		return

	_scene_path = scene_path
	_is_loading = true
	_progress.clear()

	await _create_loading_screen()

	_start_load()


func load_world_map() -> void:
	load_scene(WORLD_MAP_PATH)


func is_loading() -> bool:
	return _is_loading


func get_current_load_path() -> String:
	return _scene_path


func set_use_sub_threads(value: bool) -> void:
	_use_sub_threads = value


func _create_loading_screen() -> void:
	_loading_screen_instance = (LOADING_SCREEN.instantiate())

	get_tree().root.add_child(_loading_screen_instance)

	progress_changed.connect(_loading_screen_instance._on_progress_changed)

	load_finished.connect(_loading_screen_instance._on_load_finished)

	await _loading_screen_instance.loading_screen_ready


func _start_load() -> void:
	var state: Error = (ResourceLoader.load_threaded_request(_scene_path, "", _use_sub_threads))

	if state != OK:
		_handle_load_failure()
		return

	set_process(true)


func _process(_delta: float) -> void:
	if not _is_loading:
		return

	var load_status: ResourceLoader.ThreadLoadStatus = (
		ResourceLoader.load_threaded_get_status(_scene_path, _progress)
	)

	if not _progress.is_empty():
		progress_changed.emit(float(_progress[0]))

	match load_status:
		ResourceLoader.THREAD_LOAD_INVALID_RESOURCE, \
				ResourceLoader.THREAD_LOAD_FAILED:
			_handle_load_failure()

		ResourceLoader.THREAD_LOAD_LOADED:
			_finish_load()


func _finish_load() -> void:
	set_process(false)

	_loaded_resource = (ResourceLoader.load_threaded_get(_scene_path))

	if _loaded_resource == null:
		_handle_load_failure()
		return

	var result: Error = (get_tree().change_scene_to_packed(_loaded_resource))

	if result != OK:
		push_error("Could not change scene to: %s" % _scene_path)

		_handle_load_failure()
		return

	_is_loading = false
	load_finished.emit()

	_cleanup_loading_state()


func _handle_load_failure() -> void:
	set_process(false)

	push_error("Failed to load scene: %s" % _scene_path)

	var failed_path: String = _scene_path

	_is_loading = false

	load_failed.emit(failed_path)

	_cleanup_loading_screen()
	_cleanup_loading_state()


func _cleanup_loading_screen() -> void:
	if _loading_screen_instance == null:
		return

	if progress_changed.is_connected(_loading_screen_instance._on_progress_changed):
		progress_changed.disconnect(_loading_screen_instance._on_progress_changed)

	if load_finished.is_connected(_loading_screen_instance._on_load_finished):
		load_finished.disconnect(_loading_screen_instance._on_load_finished)

	if is_instance_valid(_loading_screen_instance):
		_loading_screen_instance.queue_free()

	_loading_screen_instance = null


func _cleanup_loading_state() -> void:
	_scene_path = ""
	_progress.clear()
	_loaded_resource = null
