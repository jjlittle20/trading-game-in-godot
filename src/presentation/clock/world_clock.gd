extends Control

signal time_changed(day: int, hour: int, minute: int)
signal day_started(day: int)

@export var real_seconds_per_game_hour: float = 2.0
@export var time_scale: float = 1.0

var day: int = 1
var hour: int = 8
var minute: int = 0

var travelling: bool = false
var _time_accumulator: float = 0.0


func _ready() -> void:
	var saved_time: Dictionary = Game.clock.get_time()

	day = int(saved_time.get("day", 1))
	hour = int(saved_time.get("hour", 8))
	minute = int(saved_time.get("minute", 0))

	Game.clock.time_changed.connect(_on_clock_time_changed)

	Game.clock.day_started.connect(_on_clock_day_started)

	time_changed.emit(day, hour, minute)


func _process(delta: float) -> void:
	if not travelling:
		return

	if real_seconds_per_game_hour <= 0.0:
		return

	if time_scale <= 0.0:
		return

	var seconds_per_game_minute: float = (real_seconds_per_game_hour / 60.0)

	_time_accumulator += delta * time_scale

	while _time_accumulator >= seconds_per_game_minute:
		_time_accumulator -= seconds_per_game_minute
		Game.clock.advance_minutes(1)


func set_travelling(is_travelling: bool) -> void:
	travelling = is_travelling


func get_time() -> Dictionary:
	return Game.clock.get_time()


func get_time_int() -> Dictionary:
	var time = Game.clock.get_time()
	return {
		"day": int(time.get("day", 0)),
		"hour": int(time.get("hour", 0)),
		"minute": int(time.get("minute", 0)),
	}


func _on_clock_time_changed(new_day: int, new_hour: int, new_minute: int) -> void:
	day = new_day
	hour = new_hour
	minute = new_minute

	time_changed.emit(day, hour, minute)


func _on_clock_day_started(new_day: int) -> void:
	day_started.emit(new_day)


func get_time_text() -> String:
	return "Day %d - %02d:%02d" % [day, hour, minute]


func set_time_scale(new_scale: float) -> void:
	time_scale = maxf(new_scale, 0.0)


func get_time_scale() -> float:
	return time_scale
