extends Node2D

# @export var poi_id: String = ""

const EXIT_BUTTON_SCENE := preload(
	"res://src/presentation/interactions/exit_to_world_map/exit_to_world_map_button.tscn"
)

const SHOP_INTERACTION_SCENE := preload(
	"res://src/presentation/interactions/shops/shop_interaction.tscn"
)


func _ready() -> void:
	var poi_id: String = Game.world.get_current_poi_id()

	if poi_id.is_empty():
		push_error("No current POI selected")
		return

	var interactions: Array = (Game.world.get_poi_interactions(poi_id))

	for interaction in interactions:
		if not interaction is Dictionary:
			push_warning("Invalid interaction data: %s" % str(interaction))
			continue

		var interaction_id: String = str(interaction.get("id", ""))

		match interaction_id:
			"EXIT_TO_WORLD_MAP":
				add_exit_button()

			"TRANSPORT_SHOP", "WEAPONS_SHOP", "ITEMS_SHOP", "RESOURCE_SHOP":
				add_interaction(SHOP_INTERACTION_SCENE, interaction)

			_:
				push_warning("Unknown interaction id: %s" % interaction_id)


func add_exit_button() -> void:
	var child = EXIT_BUTTON_SCENE.instantiate()
	add_child(child)


func add_interaction(scene: PackedScene, interaction_data: Dictionary) -> void:
	var interaction_node = scene.instantiate()

	interaction_node.setup(interaction_data.duplicate(true))

	add_child(interaction_node)
