extends Node


var playerData: Dictionary = {}


func _ready() -> void:
	if Game.player == null:
		push_error("Game.player was not initialised before Utils")
		return

	_sync_legacy_player_data()


func load_player_data() -> void:
	push_warning(
		"Utils.load_player_data() is deprecated. "
		+ "Player data is loaded by Game."
	)

	_sync_legacy_player_data()


func save_player_data() -> bool:
	push_warning(
		"Utils.save_player_data() is deprecated. "
		+ "Use Game.player.save()."
	)

	var saved: bool = Game.player.save()

	if saved:
		_sync_legacy_player_data()

	return saved


func updatePlayerPos(x: float, y: float) -> void:
	push_warning(
		"Utils.updatePlayerPos() is deprecated. "
		+ "Use Game.player.set_location()."
	)

	var saved: bool = Game.player.set_location(
		Vector2(x, y)
	)

	if saved:
		_sync_legacy_player_data()


func getPlayerPos() -> Vector2:
	push_warning(
		"Utils.getPlayerPos() is deprecated. "
		+ "Use Game.player.get_location()."
	)

	return Game.player.get_location()


func updateTime(new_time: Dictionary) -> void:
	push_warning(
		"Utils.updateTime() is deprecated. "
		+ "Use Game.clock.set_time()."
	)

	var saved: bool = Game.clock.set_time(new_time)

	if saved:
		_sync_legacy_player_data()


func getTime() -> Dictionary:
	push_warning(
		"Utils.getTime() is deprecated. "
		+ "Use Game.clock.get_time()."
	)

	return Game.clock.get_time()


func reset_player_data() -> void:
	var reset_successful: bool = Game.reset_game()

	if reset_successful:
		_sync_legacy_player_data()


func _sync_legacy_player_data() -> void:
	if Game.player == null:
		playerData = {}
		return

	var player_state = Game.player.get_state()

	if player_state == null:
		playerData = {}
		return

	playerData = player_state.to_dictionary()