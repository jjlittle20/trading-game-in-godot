extends CharacterBody2D

@export var speed: float = 20.0

var can_accept_input := false
var can_trigger_poi := false
var move_direction: Vector2 = Vector2.ZERO

@onready var degreeLabel: Label = $Label


func _ready() -> void:
	await get_tree().process_frame
	can_accept_input = true

	await get_tree().create_timer(0.2).timeout
	can_trigger_poi = true


func _unhandled_input(event: InputEvent) -> void:
	if not can_accept_input:
		return

	if event.is_action_pressed("ui_accept") or (
		event is InputEventMouseButton
		and event.button_index == MOUSE_BUTTON_LEFT
		and event.pressed
	):
		var mouse_position := get_global_mouse_position()
		move_direction = global_position.direction_to(mouse_position)

		WorldClock.set_travelling(true)
		can_trigger_poi = true

	#if event.is_action_pressed("fast_forward"):
		#WorldClock.cycle_time_scale()


func _physics_process(_delta: float) -> void:
	look_at(get_global_mouse_position())

	degreeLabel.text = str(round(global_rotation_degrees)) + "°"

	var current_speed = speed * WorldClock.time_scale

	velocity = move_direction * current_speed
	move_and_slide()


func stop_at_poi() -> void:
	move_direction = Vector2.ZERO
	velocity = Vector2.ZERO

	WorldClock.set_travelling(false)
	WorldClock.set_time_scale(1.0)
