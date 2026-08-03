extends Control

var stock = [{ "id": 1, "name": "Wagon", "cost": 200, "maxDurability": 100, "currentDurability": 78 }]
const itemButton := preload("res://src/world/POIs/POIInternals/interactions/shops/itemButton.tscn")


func _ready() -> void:
	for item in stock:
		var child = itemButton.instantiate()
		child.setup(
			item["name"],
		)
		add_child(child)
