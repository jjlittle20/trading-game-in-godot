extends Node2D

const POI_MARKER_SCENE := preload("res://src/presentation/world_map/poi_marker/poi_marker.tscn")

const PLAYER_SCENE := preload("res://src/presentation/player/player.tscn")


func _ready() -> void:
	_spawn_poi_markers()
	spawn_player_on_world_map()


func _spawn_poi_markers() -> void:
	var pois: Array[Dictionary] = Game.world.get_all_pois()

	for poi in pois:
		var poi_id: String = str(poi.get("id", ""))

		if poi_id.is_empty():
			push_error("Cannot spawn a POI marker without an id")
			continue

		var coords: Dictionary = poi.get("coords", { })

		if coords.is_empty():
			push_error("POI '%s' does not contain coordinates" % poi_id)
			continue

		var marker = POI_MARKER_SCENE.instantiate()

		marker.poiID = poi_id
		marker.position = Vector2(float(coords.get("x", 0.0)), float(coords.get("y", 0.0)))

		marker.enterPOI.connect(_on_area_2d_enter_poi)

		add_child(marker)


func _on_area_2d_enter_poi(poi_id: String) -> void:
	if not Game.world.has_poi(poi_id):
		push_error("Unknown POI: %s" % poi_id)
		return

	var scene_path: String = (Game.world.get_poi_scene_path(poi_id))

	if scene_path.is_empty():
		push_error("POI '%s' has no scene path" % poi_id)
		return

	Game.player.set_location(Game.world.get_poi_position(poi_id))

	Game.clock.save()

	var entered: bool = Game.world.enter_poi(poi_id)

	if not entered:
		return

	load_poi(scene_path)


func load_poi(file_path: String) -> void:
	SceneLoader.load_scene(file_path)


func spawn_player_on_world_map() -> void:
	var player_node = PLAYER_SCENE.instantiate()

	player_node.global_position = (Game.player.get_location())

	add_child(player_node)
