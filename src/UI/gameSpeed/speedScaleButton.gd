extends Control

@export var speedScale: float = 1.0

@onready var button: Button = $Button


func setup(button_text: String, new_speed_scale: float) -> void:
	speedScale = new_speed_scale

	if button == null:
		await ready

	button.text = button_text


func _ready() -> void:
	button.pressed.connect(_on_button_pressed)


func _on_button_pressed() -> void:
	WorldClock.set_time_scale(speedScale)
