extends HBoxContainer

const SPEED_BUTTON_SCENE := preload("res://src/UI/gameSpeed/speedScaleButton.tscn")


var speed_buttons := [
	{
		"text": ">",
		"scale": 1.0,
	},
	{
		"text": ">>",
		"scale": 2.0,
	},
	{
		"text": ">>>",
		"scale": 4.0,
	},
	{
		"text": ">>>>",
		"scale": 8.0,
	},
]


func _ready() -> void:
	for button_data in speed_buttons:
		var child = SPEED_BUTTON_SCENE.instantiate()
		add_child(child)

		child.setup(
			button_data["text"],
			button_data["scale"],
		)
