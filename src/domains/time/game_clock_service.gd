extends RefCounted

signal time_changed(day: int, hour: int, minute: int)
signal day_started(day: int)

var _player_state = null
var _save_service = null


func _init(player_state, save_service) -> void:
	_player_state = player_state
	_save_service = save_service


func get_time() -> Dictionary:
	if _player_state == null:
		push_error("GameClockService has no PlayerState")
		return { "day": 1, "hour": 8, "minute": 0 }

	return _player_state.get_time()


func set_time(new_time: Dictionary, save_immediately: bool = true) -> bool:
	if _player_state == null:
		push_error("GameClockService has no PlayerState")
		return false

	var previous_time: Dictionary = _player_state.get_time()

	_player_state.set_time(new_time)

	var current_time: Dictionary = _player_state.get_time()

	if save_immediately:
		var saved: bool = save()

		if not saved:
			return false

	_emit_time_events(previous_time, current_time)

	return true


func advance_minutes(amount: int, save_immediately: bool = true) -> bool:
	if amount < 0:
		push_error("advance_minutes() does not accept negative values")
		return false

	var current_time: Dictionary = get_time()

	var day: int = int(current_time.get("day", 1))
	var hour: int = int(current_time.get("hour", 8))
	var minute: int = int(current_time.get("minute", 0))

	minute += amount

	while minute >= 60:
		minute -= 60
		hour += 1

	while hour >= 24:
		hour -= 24
		day += 1

	return set_time({ "day": day, "hour": hour, "minute": minute }, save_immediately)


func save() -> bool:
	if _save_service == null:
		push_error("GameClockService has no SaveService")
		return false

	if _player_state == null:
		push_error("GameClockService has no PlayerState")
		return false

	return _save_service.save_player_state(_player_state)


func _emit_time_events(previous_time: Dictionary, current_time: Dictionary) -> void:
	var previous_day: int = int(previous_time.get("day", 1))

	var current_day: int = int(current_time.get("day", 1))

	var current_hour: int = int(current_time.get("hour", 8))

	var current_minute: int = int(current_time.get("minute", 0))

	if current_day > previous_day:
		for started_day in range(previous_day + 1, current_day + 1):
			day_started.emit(started_day)

	time_changed.emit(current_day, current_hour, current_minute)
