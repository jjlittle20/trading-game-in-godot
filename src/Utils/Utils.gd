extends Node

const DEFAULT_PLAYER_DATA_PATH := "res://data/playerData.json"
const SAVE_PLAYER_DATA_PATH := "user://playerData.json"

var playerData: Dictionary = { }


func _ready() -> void:
	print("User data folder: ", ProjectSettings.globalize_path("user://"))
	load_player_data()


func load_player_data() -> void:
	var path := SAVE_PLAYER_DATA_PATH

	if not FileAccess.file_exists(path):
		path = DEFAULT_PLAYER_DATA_PATH

	var file := FileAccess.open(path, FileAccess.READ)

	if file == null:
		push_error("Could not open player data file: " + path)
		return

	var json_text := file.get_as_text()
	file.close()

	var parsed = JSON.parse_string(json_text)

	if parsed == null:
		push_error("Invalid JSON file: " + path)
		return

	playerData = parsed

	print("Loaded player data from: ", path)


func save_player_data() -> void:
	var file := FileAccess.open(SAVE_PLAYER_DATA_PATH, FileAccess.WRITE)

	if file == null:
		push_error("Could not save player data")
		return

	file.store_string(JSON.stringify(playerData, "\t"))
	file.close()


func updatePlayerPos(x, y) -> void:
	playerData["location"]["x"] = x
	playerData["location"]["y"] = y
	save_player_data()


func getPlayerPos() -> Vector2:
	return Vector2(
		playerData["location"]["x"],
		playerData["location"]["y"],
	)


func updateTime(time):
	playerData["time"] = time
	save_player_data()


func getTime():
	print(playerData)
	return playerData["time"]
