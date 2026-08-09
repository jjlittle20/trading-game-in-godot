extends RefCounted

const PlayerState = preload("res://src/domains/player/player_state.gd")

var default_save_path: String
var user_save_path: String


func _init(default_path: String, save_path: String) -> void:
	default_save_path = default_path
	user_save_path = save_path


func _load_data(source):
	var path := get_load_path()
	var loaded_data = JsonFileService.read_json(path)

	if loaded_data == null:
		push_error("SaveService could not load %s data from: %s" % [source, path])
		return null

	if not loaded_data is Dictionary:
		push_error("%s save root must be a Dictionary: %s" % [source, path])
		return null
	print("Loaded %s state from: " % [source] + get_load_path())
	return loaded_data


func _save_data(destination, save_data):
	var saved := JsonFileService.write_json(user_save_path, save_data)

	if not saved:
		push_error("SaveService could not write %s data to: %s" % [destination, user_save_path])
		return false

	return true


func save_exists() -> bool:
	return FileAccess.file_exists(user_save_path)


func delete_save() -> bool:
	if not save_exists():
		return true

	var absolute_path := ProjectSettings.globalize_path(user_save_path)

	var error := DirAccess.remove_absolute(absolute_path)

	if error != OK:
		push_error("Could not delete save file. Error code: %s" % error)
		return false

	return true


func get_load_path() -> String:
	if save_exists():
		return user_save_path

	return default_save_path


# PLAYER
func load_player_state():
	var loaded_data = _load_data("Player")
	var state = PlayerState.from_dictionary(loaded_data)

	return state


func save_player_state(player_state) -> bool:
	if player_state == null:
		push_error("Cannot save a null PlayerState")
		return false
	return _save_data("Player", player_state.to_dictionary())
# POIs


func load_poi_data() -> Dictionary:
	var loaded_data = _load_data("POI")

	return loaded_data


func save_poi_data(poi_data: Dictionary) -> bool:
	print(poi_data)
	if poi_data == null:
		push_error("Cannot save a null POIdata")
		return false
	return _save_data("POI", poi_data)
