extends Label


func _ready() -> void:
	var current_time: Dictionary = Game.clock.get_time()

	_update_text(
		int(current_time.get("day", 1)),
		int(current_time.get("hour", 8)),
		int(current_time.get("minute", 0)),
	)

	WorldClock.time_changed.connect(_on_time_changed)


func _on_time_changed(day: int, hour: int, minute: int) -> void:
	_update_text(day, hour, minute)


func _update_text(day: int, hour: int, minute: int) -> void:
	text = "Day %d - %02d:%02d" % [day, hour, minute]
