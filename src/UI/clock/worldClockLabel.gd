extends Label

func _ready() -> void:
	WorldClock.time_changed.connect(_on_time_changed)
	text = WorldClock.get_time_text()


func _on_time_changed() -> void:
	text = WorldClock.get_time_text()
