extends Node2D

@export var poi_id: String = "home_town"

const EXIT_BUTTON_PATH := "res://src/world/POIs/Components/exitToWorldMapButton/ExitButton.tscn"
const TRANSPORT_SHOP_PATH := "res://src/world/POIs/POIInternals/interactions/shops/transportShop/transport_shop.tscn"


func _ready() -> void:
	var interactions = PoiManager.getPOIInteractions(poi_id)

	if interactions == null:
		push_warning("No interactions found for POI: " + poi_id)
		return

	for interaction in interactions:
		print(interaction)
		if not interaction is Dictionary:
			push_warning("Invalid interaction data: " + str(interaction))
			continue
		match interaction["id"]:
			"EXIT_TO_WORLD_MAP":
				add_exit_button(EXIT_BUTTON_PATH)
			"TRANSPORT_SHOP":
				add_interaction(TRANSPORT_SHOP_PATH,interaction)


func add_exit_button(path) -> void:
	if path == null:
		push_error("Failed to load: " + path)
		return
	var scene := load(path) as PackedScene
	var child = scene.instantiate()
	add_child(child)


func add_interaction(path,interaction) -> void:
	if path == null:
		push_error("Failed to load: " + path)
		return
		
	var scene := load(path) as PackedScene
	var child = scene.instantiate()
	child.setup(
			interaction["name"],
		)
	add_child(child)
