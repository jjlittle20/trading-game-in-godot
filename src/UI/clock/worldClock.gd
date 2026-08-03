extends Node

signal time_changed()
signal day_started(day: int)
signal time_scale_changed(time_scale: float)

@export var real_seconds_per_game_hour: float = 2.0

var day: int
var hour: int
var minute: int

var travelling: bool = false
var time_scale: float = 1.0

var _time_accumulator: float = 0.0


func _ready() -> void:
	var time = Utils.getTime()
	day = time.day
	hour = time.hour
	minute = time.minute
	time_changed.emit()


func _process(delta: float) -> void:
	if not travelling:
		return

	# Multiply delta by time_scale.
	# 1x = normal time
	# 2x = twice as fast
	# 4x = four times as fast
	_time_accumulator += delta * time_scale

	var seconds_per_game_minute := real_seconds_per_game_hour / 60.0

	while _time_accumulator >= seconds_per_game_minute:
		_time_accumulator -= seconds_per_game_minute
		_add_minutes(1)


func set_travelling(value: bool) -> void:
	travelling = value


func set_time_scale(value: float) -> void:
	time_scale = clampf(value, 1.0, 8.0)
	time_scale_changed.emit(time_scale)


func toggle_fast_forward() -> void:
	if time_scale == 1.0:
		set_time_scale(4.0)
	else:
		set_time_scale(1.0)


func _add_minutes(amount: int) -> void:
	minute += amount

	while minute >= 60:
		minute -= 60
		hour += 1

	while hour >= 24:
		hour -= 24
		day += 1
		day_started.emit(day)

	time_changed.emit()


func get_time_text() -> String:
	return "Day %d - %02d:%02d" % [day, hour, minute]


func get_speed_text() -> String:
	return "%dx" % int(time_scale)


func get_time_int() -> Dictionary:
	return {
		"day": day,
		"hour": hour,
		"minute": minute,
	}


func get_day_progress() -> float:
	return float(hour * 60 + minute) / 1440.0


func is_night() -> bool:
	return hour >= 20 or hour < 6
