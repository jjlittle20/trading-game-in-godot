extends Control

signal time_changed(day: int, hour: int, minute: int)
signal day_started(day: int)

var day: int = 1
var hour: int = 8
var minute: int = 0


func _ready() -> void:
	var saved_time: Dictionary = Game.clock.get_time()

	day = int(saved_time.get("day", 1))
	hour = int(saved_time.get("hour", 8))
	minute = int(saved_time.get("minute", 0))

	Game.clock.time_changed.connect(_on_clock_time_changed)

	Game.clock.day_started.connect(_on_clock_day_started)

	time_changed.emit(day, hour, minute)


func _process(delta: float) -> void:
	if not Game.clock.travelling:
		return

	var real_seconds_per_game_hour: float = (Game.clock.real_seconds_per_game_hour)

	if real_seconds_per_game_hour <= 0.0:
		return

	var time_scale: float = Game.clock.get_time_scale()

	if time_scale <= 0.0:
		return

	var seconds_per_game_minute: float = (real_seconds_per_game_hour / 60.0)

	var time_accumulator: float = (Game.clock.get_time_accumulator())

	time_accumulator += delta * time_scale

	while time_accumulator >= seconds_per_game_minute:
		time_accumulator -= seconds_per_game_minute

		Game.clock.advance_minutes(1, false)

	Game.clock.set_time_accumulator(time_accumulator)


func _on_clock_time_changed(new_day: int, new_hour: int, new_minute: int) -> void:
	day = new_day
	hour = new_hour
	minute = new_minute

	time_changed.emit(day, hour, minute)


func _on_clock_day_started(new_day: int) -> void:
	day_started.emit(new_day)
