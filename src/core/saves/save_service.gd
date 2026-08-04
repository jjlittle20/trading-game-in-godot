extends RefCounted


const JsonFileService = preload(
	"res://src/core/data/json_file_service.gd"
)

const PlayerState = preload(
	"res://src/domains/player/player_state.gd"
)


var default_save_path: String
var user_save_path: String


func _init(
	default_path: String,
	save_path: String
) -> void:
	default_save_path = default_path
	user_save_path = save_path


func load_player_state():
	var path := _get_load_path()
	var loaded_data = JsonFileService.read_json(path)

	if loaded_data == null:
		push_error(
			"SaveService could not load player data from: %s" % path
		)
		return null

	if not loaded_data is Dictionary:
		push_error(
			"Player save root must be a Dictionary: %s" % path
		)
		return null

	var state = PlayerState.from_dictionary(loaded_data)

	print("Loaded player state from: ", path)

	return state


func save_player_state(player_state) -> bool:
	if player_state == null:
		push_error("Cannot save a null PlayerState")
		return false

	var save_data: Dictionary = player_state.to_dictionary()

	var saved := JsonFileService.write_json(
		user_save_path,
		save_data
	)

	if not saved:
		push_error(
			"SaveService could not write player data to: %s"
			% user_save_path
		)
		return false

	return true


func save_exists() -> bool:
	return FileAccess.file_exists(user_save_path)


func delete_save() -> bool:
	if not save_exists():
		return true

	var absolute_path := ProjectSettings.globalize_path(
		user_save_path
	)

	var error := DirAccess.remove_absolute(absolute_path)

	if error != OK:
		push_error(
			"Could not delete save file. Error code: %s"
			% error
		)
		return false

	return true


func _get_load_path() -> String:
	if save_exists():
		return user_save_path

	return default_save_path