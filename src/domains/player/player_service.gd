extends RefCounted


signal location_changed(new_location: Vector2)
signal time_changed(new_time: Dictionary)


var _player_state = null
var _save_service = null


func _init(player_state, save_service) -> void:
	_player_state = player_state
	_save_service = save_service


func get_location() -> Vector2:
	if _player_state == null:
		push_error("PlayerService has no PlayerState")
		return Vector2.ZERO

	return _player_state.get_location()


func set_location(new_location: Vector2) -> bool:
	if _player_state == null:
		push_error("PlayerService has no PlayerState")
		return false

	_player_state.set_location(new_location)

	var saved := save()

	if saved:
		location_changed.emit(new_location)

	return saved


func get_time() -> Dictionary:
	if _player_state == null:
		push_error("PlayerService has no PlayerState")
		return {}

	return _player_state.get_time()


func set_time(new_time: Dictionary) -> bool:
	if _player_state == null:
		push_error("PlayerService has no PlayerState")
		return false

	_player_state.set_time(new_time)

	var saved := save()

	if saved:
		time_changed.emit(_player_state.get_time())

	return saved


func get_state():
	return _player_state


func save() -> bool:
	if _save_service == null:
		push_error("PlayerService has no SaveService")
		return false

	if _player_state == null:
		push_error("PlayerService has no PlayerState")
		return false

	return _save_service.save_player_state(_player_state)