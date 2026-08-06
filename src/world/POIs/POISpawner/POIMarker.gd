extends Area2D

signal enterPOI
@export var poiID = ""
@onready var poiLabel = $Label
@onready var poiButton = $EnterButton

@export var circle_radius: float = 20.0
@export var collision_padding: float = 4.0
@export var circle_colour: Color = Color.CORNFLOWER_BLUE


func _draw() -> void:
	# Draws the visible circle from the centre of this node.
	draw_circle(Vector2.ZERO, circle_radius, circle_colour)


func _create_collision() -> void:
	var collision_shape := CollisionShape2D.new()
	var circle_shape := CircleShape2D.new()

	# The collision area is slightly larger than the visible circle.
	circle_shape.radius = circle_radius + collision_padding

	collision_shape.shape = circle_shape
	add_child(collision_shape)


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var poi_name = Game.world.get_poi_name(poiID)
	# var poiName = PoiManager.getPOIName(poiID)
	poiLabel.text = poi_name
	poiButton.text = "Enter " + poi_name
	poiButton.hide()
	circle_radius = getPOIIconSize()
	_create_collision()
	queue_redraw()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func getPOIIconSize() -> int:
	var iconSizeDictionary: Dictionary = {
		"xxs": 10,
		"xs": 30,
		"small": 60,
		"medium": 100,
		"large": 200,
		"xl": 300,
		"xxl": 500,
		"collosal": 1000,
	}
	return iconSizeDictionary["xxs"]


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		if not body.can_trigger_poi:
			return

		body.stop_at_poi()
		poiButton.show()


func _on_enter_button_pressed() -> void:
	enterPOI.emit(poiID)


func _on_body_exited(body: Node2D) -> void:
	if body is CharacterBody2D:
		poiButton.hide()
