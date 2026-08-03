extends CanvasModulate

@export var day_color: Color = Color(1.0, 1.0, 1.0)
@export var dawn_color: Color = Color(0.75, 0.65, 0.55)
@export var dusk_color: Color = Color(0.55, 0.45, 0.65)
@export var night_color: Color = Color(0.18, 0.22, 0.35)

@export var transition_speed: float = 2.0

var target_color: Color


func _ready() -> void:
	target_color = day_color

	if WorldClock.time_changed.is_connected(_on_time_changed) == false:
		WorldClock.time_changed.connect(_on_time_changed)

	_update_target_color(WorldClock.hour, WorldClock.minute)
	color = target_color


func _process(delta: float) -> void:
	color = color.lerp(target_color, delta * transition_speed)


func _on_time_changed() -> void:
	var time = WorldClock.get_time_int()
	_update_target_color(time["hour"], time["minute"])


func _update_target_color(hour: int, minute: int) -> void:
	var time := hour + float(minute) / 60.0

	if time >= 6.0 and time < 8.0:
		# Dawn: night -> dawn -> day
		var t := inverse_lerp(6.0, 8.0, time)
		target_color = night_color.lerp(day_color, t)

	elif time >= 8.0 and time < 18.0:
		# Full day
		target_color = day_color

	elif time >= 18.0 and time < 20.0:
		# Dusk: day -> night
		var t := inverse_lerp(18.0, 20.0, time)
		target_color = day_color.lerp(night_color, t)

	else:
		# Night
		target_color = night_color
