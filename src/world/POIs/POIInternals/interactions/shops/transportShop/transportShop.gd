extends Node



@export var button: Button

@onready var canvas_layer: CanvasLayer = $CanvasLayer




func setup(text) -> void:
	print(text)
	button.text = str(text)


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func _on_button_pressed() -> void:
	if(canvas_layer.visible):
		canvas_layer.hide()
		
	else:
		canvas_layer.show()
		
	
