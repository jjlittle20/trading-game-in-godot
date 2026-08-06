extends Control

const ITEM_BUTTON := preload("res://src/world/POIs/POIInternals/interactions/shops/itemButton.tscn")


func _ready() -> void:
	var stock: Array[Dictionary] = (Game.shops.get_stock_items("TRANSPORT_SHOP", "BASIC"))
	for item in stock:
		print("Stocking: ", item.get("name", item.get("id", "Unknown")))
