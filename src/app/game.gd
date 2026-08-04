extends Node


const SaveService = preload(
	"res://src/core/saves/save_service.gd"
)

const PlayerState = preload(
	"res://src/domains/player/player_state.gd"
)

const PlayerService = preload(
	"res://src/domains/player/player_service.gd"
)

const GameClockService = preload(
	"res://src/domains/time/game_clock_service.gd"
)


const DEFAULT_PLAYER_DATA_PATH := "res://data/playerData.json"
const SAVE_PLAYER_DATA_PATH := "user://playerData.json"


var player = null
var clock = null

var _save_service = null


func _ready() -> void:
	_initialise_services()


func _initialise_services() -> void:
	_save_service = SaveService.new(
		DEFAULT_PLAYER_DATA_PATH,
		SAVE_PLAYER_DATA_PATH
	)

	var player_state = _save_service.load_player_state()

	if player_state == null:
		push_error(
			"Could not load PlayerState. Using emergency defaults."
		)

		player_state = PlayerState.new()

	_create_runtime_services(player_state)

	print("Game services initialised")


func _create_runtime_services(player_state) -> void:
	player = PlayerService.new(
		player_state,
		_save_service
	)

	clock = GameClockService.new(
		player_state,
		_save_service
	)


func reset_game() -> bool:
	if _save_service == null:
		push_error("Game has no SaveService")
		return false

	var deleted: bool = _save_service.delete_save()

	if not deleted:
		return false

	var player_state = _save_service.load_player_state()

	if player_state == null:
		player_state = PlayerState.new()

	_create_runtime_services(player_state)

	return true